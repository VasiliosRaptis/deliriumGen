#!/bin/bash

#$ -cwd
#$ -N regenie-prep
#$ -o ./qsub_logs/regenie-prep.$JOB_ID.$TASK_ID.o
#$ -e ./qsub_logs/regenie-prep.$JOB_ID.$TASK_ID.e
#$ -l h_rt=17:00:00
#$ -l h_vmem=4G
#$ -pe sharedmem 4
##$ -t 1-22
##$ -tc 22

## initialise the modules framework
source /etc/profile.d/modules.sh

## load modules
module load igmm/apps/plink/2.03
module load igmm/apps/plink/1.90b4
#module load roslin/regenie/3.2.2

## variables
GEN_DIR=/path/to/ukb/called/genotypes/dir
FAM_DIR=/path/to/ukb/plink/fam/files/dir
OUT=/path/to/regenie/output/dir

## merge genotype files for regenie step 1, see: https://rgcgithub.github.io/regenie/recommendations/

>temp_list_beds.txt

for CHR in {2..22} X XY; 
do 
  echo "${GEN_DIR}/ukb22418_c${CHR}_b0_v2.bed ${GEN_DIR}/ukb_snp_chr${CHR}_v2.bim ${FAM_DIR}/ukb22418_c${CHR}_b0_v2_s488118.fam" >> temp_list_beds.txt; 
done

plink \
  --bed ${GEN_DIR}/ukb22418_c1_b0_v2.bed \
  --bim ${GEN_DIR}/ukb_snp_chr1_v2.bim \
  --fam ${FAM_DIR}/ukb22418_c1_b0_v2_s488118.fam \
  --merge-list temp_list_beds.txt \
  --make-bed \
  --out ${OUT}/temp_ukb22418_allChrs \
  --threads $(nproc)

# convert XY to X genotypes
plink2 --bfile ${OUT}/temp_ukb22418_allChrs --make-bed --merge-x --out ${OUT}/ukb22418_allChrs --threads $(nproc)


## cleanup
mv ${OUT}/ukb22418_allChrs.log ${OUT}/logs/
mv ${OUT}/temp_ukb22418_allChrs.log ${OUT}/logs/

rm ${OUT}/temp_ukb22418_allChrs*
rm temp_list_beds.txt