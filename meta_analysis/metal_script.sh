#!/bin/bash

#$ -cwd
#$ -N metal
#$ -o ./qsub_logs/metal.$JOB_ID.o
#$ -e ./qsub_logs/metal.$JOB_ID.e
#$ -l h_rt=07:00:00
#$ -l h_vmem=7G
#$ -pe sharedmem 7

## initialise the modules framework
source /etc/profile.d/modules.sh

## load modules
module load igmm/apps/metal/2020-05-05

## rum metal script
#metal metal_script.metal > metalout.log
#metal metal_script_updated01.metal > metalout_updated01.log
#metal  metal_script_for_mtag_discovery.metal > metalout_for_mtag_samplesize.log
#metal metal_script_noAOU_noPROT.metal > metalout_noAOU_noPROT_sterr.log
metal metal_script_noAOU_noPROT.metal > metalout_noAOU_noPROT_samplesize.log

#mv *_sterr.log ./qsub_logs/
mv *_samplesize.log ./qsub_logs/
