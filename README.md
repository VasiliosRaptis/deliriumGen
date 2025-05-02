# deliriumGen

This repository contains scripts associated with the paper:

**Dissecting the genetic and proteomic risk factors for delirium**

Vasilis Raptis, Youngjune Bhak, Timothy I Cannings, Alasdair M. J. MacLullich, Albert Tenesa
medRxiv 2024.10.11.24315324; doi: https://doi.org/10.1101/2024.10.11.24315324

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

