

## activate env
conda activate mtag

## paths
MTAG=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/software/mtag
MTAG_SUMSTATS=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/mtag_anaylsis/sumstats
OUT=/exports/cmvm/eddie/smgphs/groups/Quantgen/Users/vasilis/PHD/mtag_anaylsis/output

## run mtag - discovery
mkdir -p $OUT/discovery
python $MTAG/mtag.py  \
  --sumstats $MTAG_SUMSTATS/del_meta_discovery.txt,$MTAG_SUMSTATS/AD_meta.txt \
  --out $OUT/discovery/del_AD_mtag \
  --force \
  --stream_stdout &

## run mtag - replication (AoU EUR)
mkdir -p $OUT/replication
python $MTAG/mtag.py  \
  --sumstats $MTAG_SUMSTATS/del_aou_eur_replication.txt,$MTAG_SUMSTATS/AD_meta.txt \
  --out $OUT/replication/del_AD_mtag_aou_eur \
  --force \
  --stream_stdout &

## AoU AFR
python $MTAG/mtag.py  \
  --sumstats $MTAG_SUMSTATS/del_aou_afr_replication.txt,$MTAG_SUMSTATS/AD_meta.txt \
  --out $OUT/replication/del_AD_mtag_aou_afr \
  --force \
  --stream_stdout &

## AoU AMR
python $MTAG/mtag.py  \
  --sumstats $MTAG_SUMSTATS/del_aou_amr_replication.txt,$MTAG_SUMSTATS/AD_meta.txt \
  --out $OUT/replication/del_AD_mtag_aou_amr \
  --force \
  --stream_stdout &


## format for gwaslab
# discovery
cat $OUT/discovery/del_AD_mtag_trait_1.txt | awk 'BEGIN{OFS="\t"} $3=int($3) {print $2":"$3":"$4":"$5"\t"$0}' > $OUT/discovery/del_AD_mtag_trait_1_for_gwaslab.txt 
gzip $OUT/discovery/del_AD_mtag_trait_1_for_gwaslab.txt 
# replication
#eur
cat $OUT/replication/del_AD_mtag_aou_eur_trait_1.txt | awk 'BEGIN{OFS="\t"} NR==1 || $3=int($3) {print $2":"$3":"$4":"$5"\t"$0}' > $OUT/replication/del_AD_mtag_aou_eur_trait_1_for_gwaslab.txt
gzip $OUT/replication/del_AD_mtag_aou_eur_trait_1_for_gwaslab.txt
#afr
cat $OUT/replication/del_AD_mtag_aou_afr_trait_1.txt | awk 'BEGIN{OFS="\t"} NR==1 || $3=int($3) {print $2":"$3":"$4":"$5"\t"$0}' > $OUT/replication/del_AD_mtag_aou_afr_trait_1_for_gwaslab.txt
gzip $OUT/replication/del_AD_mtag_aou_afr_trait_1_for_gwaslab.txt
#amr
cat $OUT/replication/del_AD_mtag_aou_amr_trait_1.txt | awk 'BEGIN{OFS="\t"} NR==1 || $3=int($3) {print $2":"$3":"$4":"$5"\t"$0}' > $OUT/replication/del_AD_mtag_aou_amr_trait_1_for_gwaslab.txt
gzip $OUT/replication/del_AD_mtag_aou_amr_trait_1_for_gwaslab.txt


## maxFDR
## discovery
mkdir -p $OUT/discovery/maxFDR
python $MTAG/mtag.py  \
  --out $OUT/discovery/maxFDR/del_AD_mtag \
  --force \
  --skip_mtag \
  --fdr \
  --stream_stdout &




#  --snp_name snpid \
#  --chr_name che \ 
#  --bpos_name bpos
#  --a1_name a1 \
#  --a2_name a2 \
#  --eaf_name freq \ 
#  --z_name z \
#  --n_name n \


