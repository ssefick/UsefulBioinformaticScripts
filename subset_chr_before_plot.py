#!/usr/bin/python


'''
Stephen A. Sefick
March 26, 2017
Use this script to subset the table produced by vcf2table_to_plot
based on a regular expression
Everything except chrM:
subset_chr_before_plot.py '^(?!.*chrM).*$' Arctoides_SNPs.table subset_table

chrM:
subset_chr_before_plot.py 'chrM' Arctoides_SNPs.table subset_table

chrM and chrX:
subset_chr_before_plot.py 'chrX|chrM' Arctoides_SNPs.table subset_table
'''

#import regular expression and system modules
import re
import sys

#Setup Regular Expression
remove_pattern=sys.argv[1]
pattern = re.compile(remove_pattern)

#set up input
input=sys.argv[2]
output=sys.argv[3]

#read input
with open(input,"r") as infile, open(output, 'w') as outfile:
    #set place holder variable to 0 if matches
    #what we want to remove    
    first_line = infile.readline()
    outfile.write(first_line)
    for line in infile:
        #if the pattern is matched move to the next line
        if re.search(pattern, line):
            chr = 1
        else:
            chr = 0
            continue
        ##write the file out    
        if chr==1:
            #print(line)
            outfile.write(line)
    #outfile.seek(0)
    #outfile.write(first_line)


