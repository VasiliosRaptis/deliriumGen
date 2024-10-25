#!/bin/bash

#$ -cwd
#$ -N regenie-qc
#$ -o ./qsub_logs/regenie-qc.$JOB_ID.$TASK_ID.o
#$ -e ./qsub_logs/regenie-qc.$JOB_ID.$TASK_ID.e
#$ -l h_rt=07:00:00
#$ -l h_vmem=4G
#$ -pe sharedmem 4
##$ -t 1-2
##$ -tc 22

## initialise the modules framework
source /etc/profile.d/modules.sh

## load modules
module load igmm/apps/plink/2.03
#module load igmm/apps/plink/1.90b4

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
NONEUR_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/non_eur/data/pheno
PLINK_DIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/non_eur/data/plink

## qc for step 1 genotypes

# make --keep files
awk 'NR >1 {print $1,$1}' $NONEUR_DIR/delirium_${pop}.phe > $NONEUR_DIR/delirium_${pop}_for_keep.id 

# extract qc'ed ids and variants:
plink2 \
  --bfile ${REGENIE_DIR}/ukb22418_allChrs \
  --keep  $NONEUR_DIR/delirium_${pop}_for_keep.id \
  --maf 0.01 \
  --mac 3 \
  --geno 0.03 --hwe 1e-6 --mind 0.05 \
  --write-snplist --write-samples --no-id-header \
  --out ${PLINK_DIR}/qc_pass_called_${pop} \
  --threads $(nproc)

mkdir -p ${PLINK_DIR}/logs/
mv ${PLINK_DIR}/qc_pass_called_${pop}.log ${PLINK_DIR}/logs/

