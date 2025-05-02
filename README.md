# deliriumGen

This repository contains scripts associated with the paper:

**Dissecting the genetic and proteomic risk factors for delirium**

Vasilis Raptis, Youngjune Bhak, Timothy I Cannings, Alasdair M. J. MacLullich, Albert Tenesa
medRxiv 2024.10.11.24315324; doi: https://doi.org/10.1101/2024.10.11.24315324

## R requirements

- R version 4.3.2
- ggplot2_3.5.1 
- data.table_1.16.4 
- stringr_1.5.1 
- tidyr_1.3.1 
- dplyr_1.1.4
- glmnet_4.1-8
- Matrix_1.6-0
- ggpubr_0.6.0
- readxl_1.4.3
- TwoSampleMR_0.5.11

## software requirements
- MTAG (v1.0.8)
- PLINK (v1.90b4)
- PLINK (v2.03)
- METAL (v2020-05-05)
- HDL (v1.4.0)
- REGENIE (v3.2.2)


## GWAS

- UKB GWAS

- All of Us GWAS

- GWAMA

- Sensitivity GWAS


## mediation analysis

- [01_mediation_analysis.ipynb](https://github.com/VasiliosRaptis/deliriumGen/blob/main/mediation/01_mediation_analysis.ipynb)

Performs mediation analysis between APOE and delirium via dementia


## HDL

- [02_run_HDL.sh](https://github.com/VasiliosRaptis/deliriumGen/blob/main/HDL/02_run_HDL.sh)

Performs delirium heritability and genetic correlation analyses

## MTAG

- [1_run_mtag.sh](https://github.com/VasiliosRaptis/deliriumGen/blob/main/mtag/1_run_mtag.sh)

Runs multi-trait analysis of GWAS for delirium and Alzheimer disease

## proteomics analyses

- [01_delirium_pwas_model1_clean.ipynb](https://github.com/VasiliosRaptis/deliriumGen/blob/main/proteomics/01_delirium_pwas_model1_clean.ipynb)

Performs proteome-wide association study (PWAS) and sensitivity analyses on the UKB proteomic data

- [01b_pwas_volcano_plot.ipynb](https://github.com/VasiliosRaptis/deliriumGen/blob/main/proteomics/01b_pwas_volcano_plot.ipynb)

Makes PWAS volcano plots (Figure 5)

- [02_proteomics_delirium_LASSO.ipynb](https://github.com/VasiliosRaptis/deliriumGen/blob/main/proteomics/02_proteomics_delirium_LASSO.ipynb)

Performs LASSO model training on training set

- [stabsel_scripts](https://github.com/VasiliosRaptis/deliriumGen/tree/main/proteomics/stabsel_scripts)

Performs stability selection

- [02a_test_stabsel.ipynb](https://github.com/VasiliosRaptis/deliriumGen/blob/main/proteomics/02a_test_stabsel.ipynb)

Evaluates predictive performance of proteomic models on test set, and  makes ROC and PR curves (Figure 6)

## mendelian randomisation

- [01_cis_MR_discoveryUKB.ipynb](https://github.com/VasiliosRaptis/deliriumGen/blob/main/pQTL_MR/01_cis_MR_discoveryUKB.ipynb)

Performs MR between plasma protein levels and delirium in UKB (discovery MR)

- [02_cis_MR_replicationFG.ipynb](https://github.com/VasiliosRaptis/deliriumGen/blob/main/pQTL_MR/02_cis_MR_replicationFG.ipynb)

Performs MR between plasma protein levels and delirium in FinnGen (replication MR)

- [03_cis_MR_discoveryUKB_nodem.ipynb](https://github.com/VasiliosRaptis/deliriumGen/blob/main/pQTL_MR/03_cis_MR_discoveryUKB_nodem.ipynb)

MR in UKB dementia-free sub-cohort

- [04_postMR_processing.ipynb](https://github.com/VasiliosRaptis/deliriumGen/blob/main/pQTL_MR/04_postMR_processing.ipynb)

Makes Figure 7

## colocalision

- [01_coloc_pQTLs_del.ipynb](https://github.com/VasiliosRaptis/deliriumGen/blob/main/pQTL_coloc/01_coloc_pQTLs_del.ipynb)

Perform protein-delirium colocalisation 




 
