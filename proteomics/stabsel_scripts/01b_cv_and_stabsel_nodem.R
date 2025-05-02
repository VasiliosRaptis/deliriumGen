### libraries
.libPaths(c(.libPaths(), "/exports/eddie3_apps_local/apps/SL7/R/4.3.0/lib64/R/library"))
library("dplyr", warn.conflicts = F)
#library("stringr", warn.conflicts = F)
library("data.table", warn.conflicts = F) 
library("vroom", warn.conflicts = F)
library("ggplot2", warn.conflicts = F)
library(glmnet)
library(pROC)


### set wd 
wd = "/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/proteomics/delirium/lasso"
setwd(wd)
getwd()


### load phenotypes & proteomics data, 
# created using: /exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/jupiter-setup/Rnotebooks/proteomics/01_delirium_pwas_model1.ipynb
file <- "/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/proteomics/delirium/data/data_int_clean.csv"
data <- fread(file)


### QC & mean impute missing values
variables  <- c("IID", "delirium_incident", "sex", "age_at_collection", "BMI", "age", "e4_count") # non-protein columns
prot_names <- names(data)[!names(data) %in% variables] # protein names
n_prot     <- length(prot_names) # num. of proteins
## find proteins with < 80% nonmissing values
# produce table with % non-missing per protein
nmiss_prot <- data %>% select(all_of(prot_names)) %>% summarise(across(everything(), ~ sum(!is.na(.)) / n_prot)) 
# protein names with < 80% nonmissing values
low_nmiss_prot_names <-  names(nmiss_prot)[nmiss_prot <  0.8] 
cat("proteins with <80% non-missing rate to be excluded:", low_nmiss_prot_names, "\n")
# mean impute NAs in BMI & 
# mean impute NAs in remaining proteins &
# exlcude proteins with <80% non-missing rate 
data_qc <-
data %>% 
    mutate(BMI = ifelse(is.na(BMI), mean(BMI,na.rm = T), BMI)) %>%
    mutate(across(all_of(prot_names), ~ ifelse(is.na(.), mean(., na.rm = T), .) )) %>% 
    select(-c(all_of(low_nmiss_prot_names)))


### Make time to event variable for cox LASSO:
#see: https://glmnet.stanford.edu/articles/Coxnet.html
#y is an n×2 matrix, with a column "time" of failure/censoring times, and "status" a 0/1 indicator, with 1 meaning the time is a failure time, and 0 a censoring time.

## make time variable (assessment to first delirium incidence (cases) or censoring/death (controls))
## + status variable

# age = age of death for dead (without delirium)
# age = age of first delirium for delirium cases
# age = age of cencoring for all else
data_qc <-
data_qc %>% 
    mutate(time = (age - age_at_collection)) %>%    # time_to_event outcome
    mutate(status = ifelse(delirium_incident ==1, 1, 0)) %>%  # status: 1=event; 0=censored
    select('IID', 'delirium_incident', 'time', 'status','sex', 'age_at_collection', 'BMI', all_of(prot_names)) # drop variables not used

### Extract non-dementia cohort:
## load dementia status
file = "/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/pheno_covar_files/ukb_wb_del_cov_phe_dem_apoe.txt"
dem <- fread(file) %>% select(IID, dementia_status)
## extact no-dementia subset
data_qc_nodem <- 
    data_qc %>% 
    left_join(., dem, by='IID') %>%
    filter(dementia_status==0) %>% select(-c(dementia_status))
data_qc_nodem  %>% group_by(delirium_incident) %>% summarise(n=n())

### Split training (80%) and test set (20%) in a 5-fold CV scheme  
fold_i <- as.numeric(commandArgs(trailingOnly = TRUE)[1]) # pass from array job id; to be the test set in each iteration
## set random folds id for each individual
set.seed(1234)
foldid <- sample(1:5, size = nrow(data_qc_nodem), replace = TRUE)
#summary(as.factor(foldid))/nrow(data_qc)
## define test set: select individuals in fold "fold_i" 
test_idx           <- which(foldid==fold_i)
test_data_orig     <- data_qc_nodem %>% slice(test_idx)
## define training set: select individuals NOT in fold "fold_i"
training_idx       <- which(foldid!=fold_i)
training_data_orig <- data_qc_nodem %>% slice(training_idx)
#intersect(training_data_orig$IID, test_data_orig$IID) # test if there is overlap between test/training sets
## see cases / controls in sets
cat("Training set: ")
training_data_orig %>% group_by(delirium_incident) %>% summarise(n = n()) %>% mutate(freq = round(n/sum(n),2))
cat("Test set: ")
test_data_orig %>% group_by(delirium_incident) %>% summarise(n = n()) %>% mutate(freq = round(n/sum(n),2))


### save training test sets for future usage:
sets_dir <- "/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/proteomics/delirium/lasso/data_lasso_cv/cv_sets/nodem/"
system(paste0('mkdir -p ', sets_dir)) 
train_df_name <- paste0("training_data_for_cv", fold_i)
test_df_name <- paste0("test_data_for_cv", fold_i)
write.table(training_data_orig, paste0(sets_dir, train_df_name, ".csv"), sep = ",", row.names = F, col.names = T, quote = T)
write.table(test_data_orig, paste0(sets_dir, test_df_name, ".csv"), sep = ",", row.names = F, col.names = T, quote = T)


### Run logistic regression LASSO model (a=1) on original training set for CV-fold "fold_i" : delirium_incident ~ covariates + protein(1) + ... + protein(2919)

## define response variable 
Y.train <- training_data_orig %>% select(delirium_incident) %>% data.matrix # training set
Y.test  <- test_data_orig %>% select(delirium_incident) %>% data.matrix     # test set

## define matrix of predictor variables 
X.train <- data.matrix(training_data_orig[,-c("IID","delirium_incident","time","status")])
X.test  <- data.matrix(test_data_orig[,-c("IID","delirium_incident","time","status")])

## set penalty factors: 0 to demographic covariates, so they don't get penalised by lasso model
p.fac <- rep(1, ncol(X.train))
p.fac[1:3] <- 0 # 1:3 are the col. positions in X matrix

## define weights: 
# for each obs in Y.train: 1 - (#of class members /#of total)
# see here: https://stats.stackexchange.com/questions/232228/cross-validation-for-uneven-groups-using-cv-glmnet
# and here: https://glmnet.stanford.edu/reference/glmnet.html
fraction <- table(Y.train[,1]) / length(Y.train[,1])
weights  <- 1 - fraction[as.character(Y.train[,1])]

## within training set: set at which fold each observation is assigned for LASSO CV, see: https://glmnet.stanford.edu/articles/glmnet.html
set.seed(1234)
foldid_lasso <- sample(1:10, size = length(Y.train), replace = TRUE)

## training set: perform k-fold cross-validation to find optimal lambda value (slow)
cv.lasso.orig<- cv.glmnet(X.train,     # predictors' matrix
                          Y.train,     # response variable
                          alpha = 1,           # corresponds to lasso model 
                          family = "binomial", # for logistic regression model
                          weights = weights,   # observation's weights
                          foldid = foldid_lasso,
                          standardize= T,      # (default) perform standardisation of x
                          penalty.factor = p.fac, # user-defined penalty factors
                          trace.it = TRUE)     # progress bar

## save cv.lasso.orig object for future use
cv.dir <- "/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/proteomics/delirium/lasso/data_lasso_cv/lasso.cv.glmnet.data/nodem/" 
system(paste0('mkdir -p ', cv.dir)) 
cv.lasso.name <- paste0("cv.lasso.log.orig.for.cv", fold_i, ".rds")
saveRDS(cv.lasso.orig, paste0(cv.dir, cv.lasso.name))
# load cv .glmnet object after first run 
#cv.lasso.orig <- readRDS(paste0(cv.dir, cv.lasso.name))

## training set: LASSO with lambda.1se
lasso.train.1se <- glmnet(X.train, Y.train, alpha = 1, family = "binomial", lambda = cv.lasso.orig$lambda.1se, weights = as.vector(weights), penalty.factor = p.fac, trace.it = F)
lasso.train.1se_name <- paste0("1se.lasso.log.orig.for.cv", fold_i, ".rds")
saveRDS(lasso.train.1se, paste0(cv.dir, lasso.train.1se_name))


### stability selection on subsampled sets with all cases and same number of controls randomly selected 

## perform stability selection for every lambda from cv.glmnet 

# extract cases
cases_iids <- training_data_orig %>% filter(delirium_incident==1) %>% pull(IID)
cases_idx  <- which(training_data_orig$IID %in% cases_iids)
# extract lambdas from cv.glmnt object
# lambdas <- cv.lasso.orig$lambda # all 
lambdas <- c(cv.lasso.orig$lambda.min, cv.lasso.orig$lambda.1se) # only lambdas min and 1se

#lambdas <- cv.lasso.orig$lambda.1se
# nnumber of iterations
B=100
# multiplier for case/control ratio - assigned from input 
#multi=1 
multi <- as.numeric(commandArgs(trailingOnly = TRUE)[2])
# create df for storing the frequencies of selection for each feature, at all lambdas tested by sv.glmnet (columns=feature name; rows=lambda):
features   <- colnames(X.train) # get feature names
stabsel_df <- data.frame(matrix(nrow=length(lambdas), ncol=length(features))) %>% as_tibble
colnames(stabsel_df) <- features

# loop through every lambda

for (l in 1:length(lambdas)) {
  # get lambda(l)
  lambda <- lambdas[l]
  # set all features count to zero for lambda(l) - the next loop will count the number of times each feature gets selected by lasso
  stabsel_df[l,] <- 0
  # make temporary row for storing frequencies to use in the loop (faster)
  stabsel_df_l_temp <- stabsel_df[l,]
  # for lambda(l): subsample on a 1on1 case/control ratio and fit a lasso model
  for (i in 1:B) {
    # get a random set of control iids so that n_cases = multi*n_controls
    controls_iids_i <- training_data_orig %>% filter(delirium_incident==0) %>% slice_sample(n=multi*length(cases_iids)) %>% pull(IID)
    controls_idx_i  <- which(training_data_orig$IID %in% controls_iids_i)
    # subset Y.train (response) with cases + randomly selected controls
    Y.train_i <- Y.train[c(cases_idx,controls_idx_i),]
    # subset X.train (matrix of predictor features) with cases + randomly selected controls
    X.train_i <- X.train[c(cases_idx,controls_idx_i),]
    # set penalty factors: 0 to demographic covariates, so they don't get penalised by lasso model
    p.fac <- rep(1, ncol(X.train_i))
    p.fac[1:3] <- 0 # 1:3 are the col. positions in X matrix
    # set weights 
    fraction_i <- table(Y.train_i) / length(Y.train_i)
    weights_i  <- 1 - fraction_i[as.character(Y.train_i)]
    # fit lasso model on 1on1 subsample
      stabsel_i <- glmnet(X.train_i, Y.train_i, alpha = 1, family = "binomial", lambda = lambda, weight = as.vector(weights_i), penalty.factor = p.fac, trace.it = FALSE)
      # get set s of selected (nonzero) features in lasso model i 
    coefs_i <- coef(stabsel_i)
    s_i <- names(coef(stabsel_i)[coefs_i[,1]!=0,][-1])
    # add +1 if feature is in s at each iteration 
    stabsel_df_l_temp[,s_i] <- stabsel_df_l_temp[,s_i]+1
    # message
    cat(paste0("\rIteration ", i,  " for lambda ", l))
  }
  # copy results from lapbda l in stabsel_df
  stabsel_df[l,] <- stabsel_df_l_temp
  # message
  #cat(paste0("\n", "\rStability selection finished for lambda ", l, " out of ",  length(lambdas), "..."))
}

# make frequency of times each feature is seleceted after B iterations
stabsel_df2 <- stabsel_df %>% mutate_all( ~ ./B)
#add lambdas column
stabsel_df2$lambda <- lambdas


### save stabsel results in file
stabsel_name = paste0("lasso_stabsel_df_1on", multi, "_cv", fold_i, ".csv")
stabsel_dir = "/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/proteomics/delirium/lasso/data_lasso_cv/stabsel_data/nodem/"
system(paste0('mkdir -p ', stabsel_dir)) 
write.table(stabsel_df2, paste0(stabsel_dir, stabsel_name), sep = ",", row.names = F, col.names = T, quote = T)


