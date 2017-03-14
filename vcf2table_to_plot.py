#!/usr/bin/env python

'''
Author: Stephen A. Sefick
Date: 20170314
Language: Python 2.7

Usage:
vcf2table_to_plot.py SNP.vcf SNP_table.out.txt


This script will take a SNP only vcf and strip out a number of annotations 
that may be of interest to plot and decide on hard filtering
'''
###########################################################################
##imports
import sys
import csv
import vcf
###########################################################################

###########################################################################
##commands
##open both input and output files
##this automatically closes the files when the script is done
##with open('test3.vcf', 'r') as infile, open('test_out_py', 'w') as out_csv:
infile=sys.argv[1]
outfile=sys.argv[2]
with open(infile, 'r') as infile, open(outfile, 'w') as out_csv:    
    vcf_reader = vcf.Reader(infile)
    out = csv.writer(out_csv, delimiter='\t')
    header=['sample', 'GQ', 'DP', 'FS', 'DP', 'QD']
    out.writerow(header)
    for i in vcf_reader:
        for j in i.samples:
            ##print j['GQ']
            GQ_DP_SAMPLE=[j.sample, str(j['GQ']), str(j['DP']), str(i.INFO['FS']), str(i.INFO['DP']), str(i.INFO['QD'])]
            ##out_str=",".join(GQ_DP_SAMPLE)
            out.writerow(GQ_DP_SAMPLE)
###########################################################################
