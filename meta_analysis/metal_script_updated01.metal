#THIS SCRIPT EXECUTES AN ANALYSIS OF EIGHT STUDIES
#THE RESULTS FOR EACH STUDY ARE STORED IN FILES finngen_DELIRIUM_sumstats.txt , ukb_DELIRIUM_sumstats.txt and MGI_DELIRIUM_sumstats.txt and more ...

# UNCOMMENT THE NEXT LINE TO ENABLE GenomicControl CORRECTION
GENOMICCONTROL ON

# REPORT FREQ INFO
AVERAGEFREQ ON
MINMAXFREQ ON

# STDERR BASED ANALYSIS
#SCHEME STDERR
SCHEME SAMPLESIZE

# === DESCRIBE AND PROCESS THE UKB EUR INPUT FILE ===

MARKER ALT_ID_HG38
#MARKER ALT_ID2_HG38
#MARKER ID
ALLELE ALLELE1 ALLELE0
EFFECT BETA
STDERR SE
PVALUE P
FREQ A1FREQ
DEFAULTWEIGHT 392273
PROCESS ukb_DELIRIUM_sumstats.txt

# === DESCRIBE AND PROCESS THE UKB AFR INPUT FILE ===

MARKER ALT_ID_HG38
#MARKER ALT_ID2_HG38
#MARKER ID
ALLELE ALLELE1 ALLELE0
EFFECT BETA
STDERR SE
PVALUE P
FREQ A1FREQ
DEFAULTWEIGHT 7595
PROCESS ukb_afr_DELIRIUM_sumstats.txt

# === DESCRIBE AND PROCESS THE UKB SAS INPUT FILE ===

MARKER ALT_ID_HG38
#MARKER ALT_ID2_HG38
#MARKER ID
ALLELE ALLELE1 ALLELE0
EFFECT BETA
STDERR SE
PVALUE P
FREQ A1FREQ
DEFAULTWEIGHT 9463
PROCESS ukb_sas_DELIRIUM_sumstats.txt

# === DESCRIBE AND PROCESS THE FINNGEN INPUT FILE ===

MARKER ALT_ID_HG38
#MARKER ALT_ID2_HG38
#MARKER rsids
ALLELE alt ref
EFFECT beta
STDERR sebeta
PVALUE pval
FREQ af_alt
DEFAULTWEIGHT 391931
#PROCESS finngen_R9_F5_DELIRIUM_info05_formatted.txt
PROCESS finngen_R10_F5_DELIRIUM_info05_formatted.txt

# === DESCRIBE AND PROCESS THE MGI INPUT FILE ===
MARKER ALT_ID_HG38
#MARKER ALT_ID2_HG38
#MARKER rsids
ALLELE Allele2 Allele1
EFFECT BETA
STDERR SE
PVALUE p.value
FREQ AF_Allele2
DEFAULTWEIGHT 44814
PROCESS MGI_DELIRIUM_sumstats.txt

# === DESCRIBE AND PROCESS THE AOU EUR INPUT FILE ===

MARKER ALT_ID_HG38
#MARKER ALT_ID2_HG38
#MARKER ID
ALLELE ALLELE1 ALLELE0
EFFECT BETA
STDERR SE
PVALUE P
FREQ A1FREQ
WEIGHTLABEL N
#DEFAULTWEIGHT 
PROCESS aou_eur_delirium_all.regenie

# === DESCRIBE AND PROCESS THE AOU AFR INPUT FILE ===

MARKER ALT_ID_HG38
#MARKER ALT_ID2_HG38
#MARKER ID
ALLELE ALLELE1 ALLELE0
EFFECT BETA
STDERR SE
PVALUE P
FREQ A1FREQ
WEIGHTLABEL N
#DEFAULTWEIGHT 
PROCESS aou_afr_delirium_all.regenie

# === DESCRIBE AND PROCESS THE AOU AMR INPUT FILE ===

MARKER ALT_ID_HG38
#MARKER ALT_ID2_HG38
#MARKER ID
ALLELE ALLELE1 ALLELE0
EFFECT BETA
STDERR SE
PVALUE P
FREQ A1FREQ
WEIGHTLABEL N
#DEFAULTWEIGHT 
PROCESS aou_amr_delirium_all.regenie

# RUN METAL
OUTFILE metal_output/updated01/delirium_meta_updated01_samplesize .tbl
ANALYZE HETEROGENEITY

QUIT