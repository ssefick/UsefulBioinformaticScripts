#!/usr/bin/env perl

#SAS Jun. 28, 2016
#Modified April 21, 2016
#Modified November 08, 2016
#-notes ARGV[2]=#; make sure that the test works...

#this program take a .vcf file that was created by converting a .g.vcf file to a regular vcf file
#this program "scans" the uncompressed text file and outputs the 
#entire header
#and those entries with RGQ>=3rd commandline argument
#input 1 is .vcf file
#input 2 is output name (.vcf will be appened to it)
#Example Usage

#filter_RGQ.pl input.vcf output
#returned output will be output.vcf

######################################
############Typical Usage#############
######################################
#filter_RGQ.pl input.vcf output 30
######################################
######################################
######################################

#house keeping#
use strict;
use warnings;
###############

#input file
my $input=$ARGV[0];

#open connection
open(INPUT, '<', $input);

#step through line by line
while (<INPUT>) {
  #remove line endings/returns/whatevs    
  chomp;
	
  #parse out and write header to file
  if ($_=~/^#/){
	
    #output name
    my @name=$ARGV[1];
    my $output = $name[0] . ".vcf";
    #append to file
    #this is hacky, but works
    #FIX...	
    open(NFH, '>>', $output); #or Error("Cannot write to file ($!)");        
    print NFH "$_\n";	
    close(NFH)	
  } 
	
  #look for lines that don't contain LowQual variants, start with chr,  and have no genotype information "./."
  if ($_!~/LowQual/ && $_=~/^chr/ && $_!~/\.\/./){		
    #if ($_=~/^chr/ && $_!~/\.\/./){
    my $line=$_;
    #split tab seperated lines
    my @chunk = split("\t", $line);
    #split the last column containing RGQ
    my @list_var = split(":", $chunk[9]);
    #for (my $i = 0; $i < @list_var; $i++) {next unless $list_var[$i] =~ /^RGQ/; my $index=$i;
    #convert to integer and test if greater than or equal to 30
    
    #GT:AD:DP:RGQ 
    #GT:AD:DP:GQ:PL
    if($chunk[8]=~/GT:AD:DP:RGQ/ || $chunk[8]=~/GT:AD:DP:GQ:PL/){
      
      if(int($list_var[3])>=30){
	#same as above comments		
	my @name=$ARGV[1];
	my $output = $name[0] . ".vcf";
	open(NFH, '>>', $output); #or Error("Cannot write to file ($!)");        
	print NFH "$_\n";	
	close(NFH)	
      }		
    }
    
    #GT:DP:RGQ
    if($chunk[8]=~/GT:DP:RGQ/){
      #if(int($list_var[2])>=30){
      if(int($list_var[2])>=ARGV[2]){
	#same as above comments		
	my @name=$ARGV[1];
	my $output = $name[0] . ".vcf";
	open(NFH, '>>', $output); #or Error("Cannot write to file ($!)");        
	print NFH "$_\n";	
	close(NFH)	
      }		
    }

  }	

} #end while

