#!/bin/bash

#$ -cwd
#$ -N dem-step2
#$ -o ./qsub_logs/dem-step2.$JOB_ID.$TASK_ID.o
#$ -e ./qsub_logs/dem-step2.$JOB_ID.$TASK_ID.e
#$ -l h_rt=47:00:00
#$ -l h_vmem=5G
#$ -pe sharedmem 4
#$ -t 1-22
#$ -tc 23

## initialise the modules framework
source /etc/profile.d/modules.sh

## load modules
#module load igmm/apps/plink/2.03
#module load igmm/apps/plink/1.90b4
module load roslin/regenie/3.2.2  
  
## variables
REGENIE_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/regenie_files
BGEN_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/ukb_data/ukb44986/genomic_data/imputed_WTCHG
SAMPLE_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/ukb_data/ukb44986/genomic_data/samples
PHENO_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/pheno_covar_files

DEMADJ_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/sensitivity/demAdj
E4ADJ_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/sensitivity/e4Adj

## set chromosomes (autosomes[1-22] + X[23]):
if [ $SGE_TASK_ID = 23 ]; then
  echo 'analysing chrX'
  CHR="X"
else
  echo "analysing chr${SGE_TASK_ID}"
  CHR=$SGE_TASK_ID
fi

## run step 2 with QC'ed imputed genotypes:

mkdir -p ${DEMADJ_DIR}/output/

## dementia adjusted
regenie \
  --step 2 \
  --bgen ${BGEN_DIR}/ukb22828_c${CHR}_b0_v3.bgen \
  --ref-first \
  --sample ${SAMPLE_DIR}/ukb22828_c${CHR}_b0_v3_*.sample \
  --keep ${REGENIE_DIR}/extraction_files/qc_pass_called.id \
  --phenoFile ${PHENO_DIR}/ukb_wb_del_cov_phe_dem_apoe.txt \
  --phenoCol delirium \
  --covarFile ${PHENO_DIR}/ukb_wb_del_cov_phe_dem_apoe.txt \
  --covarColList age,batch,PC{1:20} \
  --catCovarList sex,dementia_status \
  --bt \
  --af-cc \
  --firth --approx --pThresh 0.01 --firth-se \
  --pred ${DEMADJ_DIR}/step1/ukb_demAdj_pred.list \
  --bsize 400 \
  --out ${DEMADJ_DIR}/output/ukb_demAdj_c${CHR} \
  --threads $(nproc)











