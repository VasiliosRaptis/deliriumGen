#!/bin/bash

#$ -cwd
#$ -N regenie-qc
#$ -o ./qsub_logs/regenie-qc.$JOB_ID.$TASK_ID.o
#$ -e ./qsub_logs/regenie-qc.$JOB_ID.$TASK_ID.e
#$ -l h_rt=17:00:00
#$ -l h_vmem=4G
#$ -pe sharedmem 4
##$ -t 1-22
##$ -tc 22

## initialise the modules framework
source /etc/profile.d/modules.sh

## load modules
module load igmm/apps/plink/2.03
#module load igmm/apps/plink/1.90b4

## variables
REGENIE_DIR=/path/to/regenie/output/dir

## qc for step 1 genotypes
#  extract qc'ed ids and variants:

plink2 \
  --bfile ${REGENIE_DIR}/ukb22418_allChrs \
  --keep  ${REGENIE_DIR}/ukb_wb_eids.id \
  --maf 0.01 \
  --mac 3 \
  --geno 0.03 --hwe 1e-6 --mind 0.05 \
  --write-snplist --write-samples --no-id-header \
  --out ${REGENIE_DIR}/qc_pass_called \
  --threads $(nproc)

mkdir -p ${REGENIE_DIR}/logs/
mkdir -p ${REGENIE_DIR}/extraction_files/

mv ${REGENIE_DIR}/qc_pass_called.log ${REGENIE_DIR}/logs/
mv ${REGENIE_DIR}/qc_pass_called.* ${REGENIE_DIR}/extraction_files/
