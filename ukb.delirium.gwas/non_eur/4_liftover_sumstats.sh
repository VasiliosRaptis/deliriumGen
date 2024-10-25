#!/bin/bash

#$ -cwd
#$ -N liftover
#$ -o ./qsub_logs/liftover.$JOB_ID.$TASK_ID.o
#$ -e ./qsub_logs/liftover.$JOB_ID.$TASK_ID.e
#$ -l h_rt=47:00:00
#$ -l h_vmem=5G
#$ -pe sharedmem 5
##$ -t 1-4
##$ -tc 23

## initialise the modules framework
source /etc/profile.d/modules.sh

## note:
# run first the 02_postGWAS_qc notebook

## assign population
pop="sas"

## liftover paths:
# liftOver software downlaoded from https://genome-store.ucsc.edu/ 
# chain file (hg19 to hg38) downloaded from https://hgdownload.soe.ucsc.edu/downloads.html
LIFTOVER=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/software/liftOver
CHAINFILE=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/resources/liftOver_files/hg19ToHg38.over.chain.gz
SUMSTATSDIR=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/ukb.delirium.gwas/non_eur/output/${pop}

cd $SUMSTATSDIR

## make BED file input from regenie sumstats
## change chrom 23 to X 
>${SUMSTATSDIR}/ukb_${pop}_fgQC_all_liftover_in.BED
cat ${SUMSTATSDIR}/ukb_${pop}_fgQC_all.regenie | awk 'NR>1 {gsub(/23/,"X",$1); print "chr"$1, ($2-1), $2, $3, $4, $5, $6, $7, $8, $15, $16, $17, $18}' > ${SUMSTATSDIR}/ukb_${pop}_fgQC_all_liftover_in.BED


## run liftOver
>${SUMSTATSDIR}/ukb_${pop}_fgQC_all_hg38.BED 
>${SUMSTATSDIR}/ukb_${pop}_fgQC_all_unmapped.BED
${LIFTOVER} \
  -bedPlus=3 \
  ${SUMSTATSDIR}/ukb_${pop}_fgQC_all_liftover_in.BED \
  ${CHAINFILE} \
  ${SUMSTATSDIR}/ukb_${pop}_fgQC_all_hg38.BED \
  ${SUMSTATSDIR}/ukb_${pop}_fgQC_all_unmapped.BED
  
# weird chromosomes e.g chr8_KI270821v1_alt
  
## reformat output
## change chrom name to 1,2,3..23
## remove non-standard chromosome codes (10033 snps, contain "_" in chrom name) & variants with imputation INFO<=0.5
>temp
cat ${SUMSTATSDIR}/ukb_${pop}_fgQC_all_hg38.BED | awk 'BEGIN{OFS="\t"} {gsub(/chr/,"",$1); gsub(/X/,"23",$1); print $1,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' | awk '$1!~/_/ && $(NF-1)>=0.5' > temp

## make alternative id columns: ALT_ID_HG38: CHROM:GENPOS_ALLELE0_ALLELE1 & ALT_ID2_HG38: CHROM:GENPOS
>temp2
cat temp | awk 'BEGIN{OFS="\t"} {print $1,$2,$3,$1":"$2"_"$4"_"$5,$1":"$2,$4,$5,$6,$7,$8,$9,$10,$11,$12}' > temp2

## add header 
>temp_header
>ukb_${pop}_fgQC_all_hg38_final.txt
echo -e "CHROM\tGENPOS\tID\tALT_ID_HG38\tALT_ID2_HG38\tALLELE0\tALLELE1\tA1FREQ\tA1FREQ_CASES\tA1FREQ_CONTROLS\tBETA\tSE\tINFO\tP" > temp_header
cat temp_header temp2 > ukb_${pop}_fgQC_all_hg38_final.txt

## remove temp files
rm temp
rm temp2
rm temp_header
rm ukb_${pop}_fgQC_all_liftover_in.BED
rm ukb_${pop}_fgQC_all_hg38.BED



## for finngen sumstats:

# in R: fix empty values into NAs
#  a <- fread("finngen_R*_F5_DELIRIUM")
# a2 <- a %>% mutate(rsids= na_if(rsids, "")) %>% mutate(nearest_genes = na_if(nearest_genes, "")) 

# echo -e "chrom\tpos\tref\talt\trsids\tnearest_genes\tpval\tmlogp\tbeta\tsebeta\taf_alt\taf_alt_cases\taf_alt_controls\tALT_ID_HG38\tALT_ID2_HG38" > temp_header
# cat finngen_R9_F5_DELIRIUM_nafix.txt | awk 'BEGIN{OFS="\t"} {print $0,$1":"$2"_"$3"_"$4,$1":"$2}' | grep -v "^#"  > temp
# cat temp_header temp > finngen_R9_F5_DELIRIUM_formatted.txt
# rm temp_header
# rm temp



