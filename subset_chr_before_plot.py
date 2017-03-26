#!/usr/bin/python

########################################################
########################################################
########################################################
#Stephen A. Sefick
#July 15, 2016
#Use this script to remove sequences from a 
#fasta file that match a supplied pattern
#example usage:
#./reference.fa.filter.py ">Unknown" dp4.fa.masked out
#">Unknown" is the pattern
#dp4.fa.masked is the reference genome
#out is the outfile
########################################################
########################################################
########################################################

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
    for line in infile:
        #if the pattern is matched move to the next line
        if pattern.match(line):
            chr=0
            continue
        else:
            chr=1    
            
        #write the file out    
        outfile.write(first_line)

        if chr==1:
            #print(line)
            outfile.write(line)



