#!/bin/bash

#$ -cwd
#$ -N regenie-step2
#$ -o ./qsub_logs/step2-afr-noqc.$JOB_ID.$TASK_ID.o
#$ -e ./qsub_logs/step2-afr-noqc.$JOB_ID.$TASK_ID.e
#$ -l h_rt=17:00:00
#$ -l h_vmem=5G
#$ -pe sharedmem 4
#$ -l rl9=true
#$ -t 1-23
#$ -tc 23

## initialise the modules framework
source /etc/profile.d/modules.sh

## load modules
#module load roslin/regenie/3.2.2  
module load anaconda/2024.02

## activate regenie v3.5 conda env
conda activate regenie_env
 
## assign population
pop="afr"
   
## variables
REGENIE_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/regenie_files
BGEN_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/ukb_data/ukb44986/genomic_data/imputed_WTCHG
SAMPLE_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/ukb_data/ukb44986/genomic_data/samples
NONEUR_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/non_eur/data
OUT_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/non_eur/output

## set chromosomes (autosomes[1-22] + X[23]):
if [ $SGE_TASK_ID = 23 ]; then
  echo 'analysing chrX'
  CHR="X"
else
  echo "analysing chr${SGE_TASK_ID}"
  CHR=$SGE_TASK_ID
fi

## run step 2 with imputed genotypes:
mkdir -p ${OUT_DIR}/${pop}/
regenie \
  --step 2 \
  --bgen ${BGEN_DIR}/ukb22828_c${CHR}_b0_v3.bgen \
  --ref-first \
  --sample ${SAMPLE_DIR}/ukb22828_c${CHR}_b0_v3_*.sample \
  --keep ${NONEUR_DIR}/plink/qc_pass_called_${pop}.id \
  --phenoFile ${NONEUR_DIR}/pheno/delirium_${pop}.phe \
  --phenoCol delirium \
  --covarFile ${NONEUR_DIR}/pheno/delirium_${pop}.phe \
  --covarColList age,batch,PC{1:20} \
  --catCovarList sex \
  --bt \
  --af-cc \
  --firth --approx --pThresh 0.01 --firth-se \
  --pred ${NONEUR_DIR}/step1/ukb_${pop}_pred.list \
  --bsize 400 \
  --out ${OUT_DIR}/${pop}/ukb_${pop}_noqc_c${CHR} \
  --threads $(nproc)










