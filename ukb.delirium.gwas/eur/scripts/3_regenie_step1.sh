#!/bin/bash

#$ -cwd
#$ -N regenie-step1
#$ -o ./qsub_logs/step1.$JOB_ID.$TASK_ID.o
#$ -e ./qsub_logs/step1.$JOB_ID.$TASK_ID.e
#$ -l h_rt=17:00:00
#$ -l h_vmem=4G
#$ -pe sharedmem 4
##$ -t 1-22
##$ -tc 22

## initialise the modules framework
source /etc/profile.d/modules.sh

## load modules
#module load igmm/apps/plink/2.03
#module load igmm/apps/plink/1.90b4
module load roslin/regenie/3.2.2  
  
## variables
REGENIE_DIR=/path/to/regenie/output/dir


## run step 1 with QC'ed called genotypes:

mkdir -p ${REGENIE_DIR}/tmpdir/
mkdir -p ${REGENIE_DIR}/step1_output/

regenie \
  --step 1 \
  --bed ${REGENIE_DIR}/ukb22418_allChrs \
  --extract ${REGENIE_DIR}/extraction_files/qc_pass_called.snplist \
  --keep ${REGENIE_DIR}/extraction_files/qc_pass_called.id \
  --phenoFile ${REGENIE_DIR}/ukb_wb_del_cov_phe.txt \
  --phenoCol delirium \
  --covarFile ${REGENIE_DIR}/ukb_wb_del_cov_phe.txt \
  --covarColList age,batch,PC{1:20} \
  --catCovarList sex \
  --bt \
  --bsize 1000 \
  --lowmem \
  --lowmem-prefix ${REGENIE_DIR}/tmpdir/regenie_tmp_preds \
  --out ${REGENIE_DIR}/step1_output/ukb_step1_delirium

