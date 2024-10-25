#!/bin/bash

#$ -cwd
#$ -N regenie-step2
#$ -o ./qsub_logs/step2-noqc-extra4.$JOB_ID.$TASK_ID.o
#$ -e ./qsub_logs/step2-noqc-extra4.$JOB_ID.$TASK_ID.e
#$ -l h_rt=47:00:00
#$ -l h_vmem=5G
#$ -pe sharedmem 4
#$ -t 1-4
#$ -tc 23

## initialise the modules framework
source /etc/profile.d/modules.sh

## load modules
#module load igmm/apps/plink/2.03
#module load igmm/apps/plink/1.90b4
module load roslin/regenie/3.2.2  
  
## variables
REGENIE_DIR=/path/to/regenie/output/dir
BGEN_DIR=/path/to/ukb/WTCHG_imputed/genotypes/dir
SAMPLE_DIR=/path/to/ukb/sample/files/dir
OUT_DIR=/path/regenie/step2/sumstats/output/dir

## set chromosomes (autosomes[1-22] + X[23]):
if [ $SGE_TASK_ID = 23 ]; then
  echo 'analysing chrX'
  CHR="X"
else
  echo "analysing chr${SGE_TASK_ID}"
  CHR=$SGE_TASK_ID
fi

## run step 2 with QC'ed imputed genotypes:

regenie \
  --step 2 \
  --bgen ${BGEN_DIR}/ukb22828_c${CHR}_b0_v3.bgen \
  --ref-first \
  --sample ${SAMPLE_DIR}/ukb22828_c${CHR}_b0_v3_*.sample \
  --keep ${REGENIE_DIR}/extraction_files/qc_pass_called.id \
  --phenoFile ${REGENIE_DIR}/ukb_wb_del_cov_phe.txt \
  --phenoCol delirium \
  --covarFile ${REGENIE_DIR}/ukb_wb_del_cov_phe.txt \
  --covarColList age,batch,PC{1:20} \
  --catCovarList sex \
  --bt \
  --af-cc \
  --firth --approx --pThresh 0.01 --firth-se \
  --pred ${REGENIE_DIR}/step1_output/ukb_step1_delirium_pred.list \
  --bsize 400 \
  --out ${OUT_DIR}/ukb_wb_noqc_c${CHR} \
  --threads $(nproc)










