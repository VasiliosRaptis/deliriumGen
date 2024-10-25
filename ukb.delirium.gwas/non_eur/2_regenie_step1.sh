#!/bin/bash

#$ -cwd
#$ -N regenie-step1
#$ -o ./qsub_logs/step1.$JOB_ID.$TASK_ID.o
#$ -e ./qsub_logs/step1.$JOB_ID.$TASK_ID.e
#$ -l h_rt=17:00:00
#$ -l h_vmem=4G
#$ -pe sharedmem 4
##$ -t 1-2
##$ -tc 22

## initialise the modules framework
source /etc/profile.d/modules.sh

## load modules
#module load igmm/apps/plink/2.03
#module load igmm/apps/plink/1.90b4
module load roslin/regenie/3.2.2  

## assign population from sge_task_id
if [ $SGE_TASK_ID = 1 ]; then
  pop="afr"
  echo "analysing $pop"
elif [ $SGE_TASK_ID = 2 ]; then
  pop="sas"
  echo "analysing $pop"
fi

pop="eurSub" # for sensitivity analysis using eur. subsample

## variables
REGENIE_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/regenie_files
NONEUR_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/non_eur/data

## run step 1 with QC'ed called genotypes:

mkdir -p ${REGENIE_DIR}/tmpdir/
mkdir -p ${NONEUR_DIR}/step1/logs

regenie \
  --step 1 \
  --bed ${REGENIE_DIR}/ukb22418_allChrs \
  --extract ${NONEUR_DIR}/plink/qc_pass_called_${pop}.snplist \
  --keep ${NONEUR_DIR}/plink/qc_pass_called_${pop}.id \
  --phenoFile ${NONEUR_DIR}/pheno/delirium_${pop}.phe \
  --phenoCol delirium \
  --covarFile ${NONEUR_DIR}/pheno/delirium_${pop}.phe \
  --covarColList age,batch,PC{1:20} \
  --catCovarList sex \
  --bt \
  --bsize 1000 \
  --lowmem \
  --lowmem-prefix ${REGENIE_DIR}/tmpdir/regenie_tmp_preds_${pop} \
  --out ${NONEUR_DIR}/step1/ukb_${pop}

mv ${NONEUR_DIR}/step1/ukb_${pop}.log ${NONEUR_DIR}/step1/logs/
