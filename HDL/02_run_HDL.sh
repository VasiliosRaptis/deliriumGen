#!/bin/bash

#$ -cwd
#$ -N HDL
#$ -o ./qsub_logs/hdl.$JOB_ID.$TASK_ID.o
#$ -e ./qsub_logs/hdl.$JOB_ID.$TASK_ID.e
#$ -l h_rt=01:00:00
#$ -l h_vmem=4G
#$ -pe sharedmem 4
#$ -t 1-17
  
## initialise the modules framework
source /etc/profile.d/modules.sh

## load modules
module load R/4.3

#SGE_TASK_ID=16

## paths
# inputs
HDL=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/software/hdl/HDL
LD=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/software/hdl/refpanels/UKB_imputed_SVD_eigen99_extraction/
IN=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/hdl_analysis/sumstats/formatted
# delirium sumstats
GWAS1_NAME='deliriumUKBwb_for_hdl_overlap.txt'
GWAS1=${IN}/delirium/${GWAS1_NAME}
# other disease sumstats
GWAS2_NAME=$(ls -1p $IN | grep -v / | grep 'EUR' | sed -n "${SGE_TASK_ID}p")
GWAS2=${IN}/${GWAS2_NAME}
# output
TRAIT1=$(echo $GWAS1_NAME | sed 's/_for_hdl_overlap.txt//g')
TRAIT2=$(echo $GWAS2_NAME | sed 's/_for_hdl_overlap.txt//g')
OUT=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/hdl_analysis/output/for_real

## run HDL

Rscript ${HDL}/HDL.run.R \
  gwas1.df=${GWAS1} \
  gwas2.df=${GWAS2} \
  LD.path=${LD} \
  output.file=${OUT}/${TRAIT1}_${TRAIT2}.hdl.Rout 

## in parallel
# Rscript ${HDL}/HDL.parallel.run.R \
#   gwas1.df=${GWAS1} \
#   gwas2.df=${GWAS2} \
#   LD.path=${LD} \
#   output.file=${OUT}/${TRAIT1}_${TRAIT2}.hdl.Rout \
#   numCores=$(nproc)

## heritability for delirium
# Rscript ${HDL}/HDL.run.R \
#   gwas.df=${GWAS1} \
#   LD.path=${LD} \
#   output.file=${OUT}/${TRAIT1}.hdl.Rout 
