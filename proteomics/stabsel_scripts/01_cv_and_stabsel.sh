#!/bin/bash

#$ -cwd
#$ -N cv_and_stabsel_nodem
#$ -o sh_logs/cv_and_stabsel_nodem.$JOB_ID.$TASK_ID.o
#$ -e sh_logs/cv_and_stabsel_nodem.$JOB_ID.$TASK_ID.e
#$ -l h_rt=19:00:00
#$ -l h_vmem=5G
#$ -pe sharedmem 5
#$ -t 2-5

source /etc/profile.d/modules.sh

module load R/4.3.0

# run script for 5-fold CV split in training /test & stability selection for each 5fold iteration 
# $1: CV fold -> 1 to 5
# $2: multiplier in stability selection. i.e ratio for cases/controls -> default is 1 (1on1 case/control ratio)
MULTI=1

Rscript 01b_cv_and_stabsel_nodem.R $SGE_TASK_ID $MULTI

