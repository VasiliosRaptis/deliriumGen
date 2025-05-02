#!/bin/bash

## make hdl appropriate gwas sumstats, see here: https://github.com/zhenin/HDL/wiki/Format-of-summary-statistics

cd /exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/hdl_analysis/sumstats

# delirium
cat METAANALYSIS_DELIRIUM_QC.tbl | awk 'NR>1{print $NF,$4,$5,$17,$10,$11}' > temp
echo 'SNP A1 A2 N b se' > header
cat header temp > delirium_meta_for_hdl.txt
rm temp header

# AD
cat AD_meta.txt | awk 'NR>1{print $1,$4,$5,$7,$9}' > temp
echo 'SNP A1 A2 Z N' > header
cat header temp > AD_meta_for_hld.txt
rm temp header

# ADHD - PGC
# adhd <- fread('raw/ADHD/ADHD2022_iPSYCH_deCODE_PGC.meta.gz')
# load('../../software/hdl/refpanels/UKB_imputed_SVD_eigen99_extraction/UKB_snp_list_imputed.vector_form.RData')
# adhd2 <- adhd %>% filter(SNP %in% snps.list.imputed.vector) %>% mutate(b = log(OR), N = Nca + Nco, se = SE) %>% select(SNP,A1,A2,b,se,N)
# fwrite(adhd2, file='formatted/adhdEUR_for_hdl_overlap.txt', sep=" ")

# panic disorder (PD) - PGC 
pd <- fread('raw/PD/pgc-panic2019.vcf.tsv.gz')
load('../../software/hdl/refpanels/UKB_imputed_SVD_eigen99_extraction/UKB_snp_list_imputed.vector_form.RData')


# Stroke

## for overlap, in R:

# load('UKB_snp_list_imputed.vector_form.RData') # list of rsids, find this in: software/hdl/refpanels/UKB_imputed_SVD_eigen99_extraction
# del <- fread('/paht/to/hdl_analysis/sumstats/delirium_meta_for_hdl.txt')
# del2 <- del %>% filter(SNP %in% snps.list.imputed.vector)
# fwrite(del2, file='../../../../hdl_analysis/sumstats/delirium_meta_for_hdl_overlap.txt', quote=F, sep=" ")