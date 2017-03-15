#!/usr/bin/env python

import sys
import csv
import vcf

##open both input and output files
##this automatically closes the files when the script is done
with open('/home/ssefick/scratch/arctoides/ORINGINAL_GVCF_MACAQUE_COMBINED/split/chrM_Annotations/filtered_chrM_RGQ_VQSR_ANNOTATED.vcf', 'r') as infile, open('test_out_py', 'w') as out_csv:
##infile=sys.argv[1]
##outfile=sys.argv[2]
##with open(infile, 'r') as infile, open(outfile, 'w') as out_csv:    
    vcf_reader = vcf.Reader(infile)
    out = csv.writer(out_csv, delimiter='\t')
    header=['sample', 'ReadPosRankSum', 'MQRankSum', 'SOR', 'MQ', 'QD', 'GQ', 'DP', 'FS', 'DP', 'QD']
    out.writerow(header)
    for i in vcf_reader:
        for j in i.samples:
            ##print j['GQ']
            if 'ReadPosRankSum' in i.INFO:
                RPRS=str(i.INFO['ReadPosRankSum'])
            else:
                RPRS='None'
            if 'MQRankSum' in i.INFO:
                MQRS=str(i.INFO['MQRankSum'])
            else:
                MQRS='None'
            GQ_DP_SAMPLE=[j.sample, RPRS, MQRS, str(i.INFO['SOR']), str(i.INFO['MQ']), str(i.INFO['QD']), str(j['GQ']), str(j['DP']), str(i.INFO['FS']), str(i.INFO['DP']), str(i.INFO['QD'])]
            out.writerow(GQ_DP_SAMPLE)            
            
