#!/bin/bash

#$ -cwd
#$ -N dem1
#$ -o ./qsub_logs/step1.$JOB_ID.$TASK_ID.o
#$ -e ./qsub_logs/step1.$JOB_ID.$TASK_ID.e
#$ -l h_rt=09:00:00
#$ -l h_vmem=4G
#$ -pe sharedmem 4
##$ -t 1-22
##$ -tc 22

## initialise the modules framework
source /etc/profile.d/modules.sh

## load modules
module load roslin/regenie/3.2.2  
  
## variables
REGENIE_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/regenie_files
PHENO_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/pheno_covar_files
DEMADJ_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/sensitivity/demAdj
E4ADJ_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/sensitivity/e4Adj

mkdir -p ${REGENIE_DIR}/tmpdir/
mkdir -p $DEMADJ_DIR/step1/logs
mkdir -p $E4ADJ_DIR/step1/logs 

## run step 1 with QC'ed called genotypes:

# dementia adjusted:
regenie \
  --step 1 \
  --bed ${REGENIE_DIR}/ukb22418_allChrs \
  --extract ${REGENIE_DIR}/extraction_files/qc_pass_called.snplist \
  --keep ${REGENIE_DIR}/extraction_files/qc_pass_called.id \
  --phenoFile ${PHENO_DIR}/ukb_wb_del_cov_phe_dem_apoe.txt \
  --phenoCol delirium \
  --covarFile ${PHENO_DIR}/ukb_wb_del_cov_phe_dem_apoe.txt \
  --covarColList age,batch,PC{1:20} \
  --catCovarList sex,dementia_status \
  --bt \
  --bsize 1000 \
  --lowmem \
  --lowmem-prefix ${REGENIE_DIR}/tmpdir/regenie_tmp_preds \
  --out ${DEMADJ_DIR}/step1/ukb_demAdj

# apoe adjusted:
regenie \
  --step 1 \
  --bed ${REGENIE_DIR}/ukb22418_allChrs \
  --extract ${REGENIE_DIR}/extraction_files/qc_pass_called.snplist \
  --keep ${REGENIE_DIR}/extraction_files/qc_pass_called.id \
  --phenoFile ${PHENO_DIR}/ukb_wb_del_cov_phe_dem_apoe.txt \
  --phenoCol delirium \
  --covarFile ${PHENO_DIR}/ukb_wb_del_cov_phe_dem_apoe.txt \
  --covarColList age,batch,PC{1:20} \
  --catCovarList sex,e4_count \
  --bt \
  --bsize 1000 \
  --lowmem \
  --lowmem-prefix ${REGENIE_DIR}/tmpdir/regenie_tmp_preds \
  --out ${E4ADJ_DIR}/step1/ukb_e4Adj

mv ${E4ADJ_DIR}/step1/ukb_e4Adj.log ${E4ADJ_DIR}/step1/logs
mv ${DEMADJ_DIR}/step1/ukb_demAdj.log ${DEMADJ_DIR}/step1/logs


