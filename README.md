# UsefulBioinformaticScripts

I am posting Useful Bioinformatics scripts here that I find useful.

##vcf_cutoff_stats.R
This is an R script to calculate some different statistics related to
depth and quality of vcf_files. Of course, this is not very specific
and can be ported easily to other applications. This is not the most
efficient script...; however, the R part is not the inefficient
part. I believe the cat part into the this scirpt is the inefficient
part. note tested with small fruitfly genome; your results may vary

typical use case:
vcftools --site-depth --vcf your.vcf --out site_depth
vcftools --site-quality --vcf your.vcf --out site_quality

outputs site_depth.ldepth and site_quality.lqual
then pipe this output to the script

cat site_quality.lqual | vcf_cutoff_stats.R > vcf_quality_summary.txt
cat site_depth.ldepth | vcf_cutoff_stats.R > vcf_depth_summary.txt

#reference.fa.filter.py
Stephen A. Sefick
July 15, 2016

Use this script to remove sequences from a

fasta file that match a supplied pattern

example usage:

./reference.fa.filter.py ">Unknown" dp4.fa.masked out

">Unknown" is the pattern

dp4.fa.masked is the reference genome

out is the outfile
