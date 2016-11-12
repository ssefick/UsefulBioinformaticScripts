#!/usr/bin/env Rscript

############################################################################################

############################################################################################
#Typical Usage
#./filter_RGQ_gVCF_working_CHUNKS.R -i test.vcf.gz -t test.vcf.gz.tbi -RGQ 30 -o test2 -C 10
############################################################################################

require(argparse)

parser <- ArgumentParser()
# specify our desired options
# by default ArgumentParser will add an help option


parser$add_argument("-i", "--input_vcf", action="store", default="VCF file", dest="input_vcf",
 help="Input %(default)s")

parser$add_argument("-t", "--tabix_index", action="store", default="tabix index", dest="input_tabix",
 help="Input %(default)s")

parser$add_argument("-o", "--output_vcf", action="store", default="Filtered Vcf", dest="output_vcf",
 help="Output %(default)s")

parser$add_argument("-RGQ", "--Reference_Genotype_Quality", action="store", default=30, dest="RGQ_value",
 help="Default: %(default)s")

parser$add_argument("-min_DP", "--min_Depth", action="store", default=5, dest="min_DP",
 help="Default: %(default)s")

parser$add_argument("-max_DP", "--max_Depth", action="store", default=120, dest="max_DP",
 help="Default: %(default)s")

parser$add_argument("-GQ", "--Genotype_Quanlity", action="store", default=20, dest="GQ",
 help="Default: %(default)s")


parser$add_argument("-C", "--CHUNKS", action="store", default=1, dest="CHUNKS",
 help="Number of CHUNKS defaults to %(default)s")


# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
argv <- parser$parse_args()


if(argv["input_vcf"][[1]]=="VCF file"){stop("\n\n\n Needs 3 agruments: \n\n Argument 1: .g.vcf file \n Argument2: .g.vcf output file \n\n Argument3: tabix index \n\n\n For full help:\n plot_stats_vcf_CL_ARGS.R --help \n\n\n")}

input <- argv["input_vcf"][[1]]
output <- argv["output_vcf"][[1]]
tabix  <- argv["input_tabix"][[1]]
CHUNKS  <- argv["CHUNKS"][[1]]
#filters
RGQ_value <- argv["RGQ_value"][[1]]
min_DP  <- argv["min_DP"][[1]]
max_DP  <- argv["max_DP"][[1]]
GQ  <- argv["GQ"][[1]]
################################################################################

#test data

test <- 0

if(test==1){
input <- "test.vcf.gz"
tabix <- "test.vcf.gz.tbi"
RGQ_value <- 30
output <-  "test2"
CHUNKS <- 10
}

library("VariantAnnotation")

ref <- "rheMac3"

x <- readVcf("test.vcf.gz", genome=ref)

##############################################################
##############################################################
##############################################################
#prefilter
#only those that have RGQ
isRGQ <- function(x) {
    !(grepl("RGQ", x, fixed=TRUE))
}
##############################################################
##############################################################
##############################################################

##############################################################
##############################################################
##############################################################

######################################################################################################################
#filters
#snps
#"QD < 2.0"; "MQ < 40.0"; "FS > 60.0"; "SOR > 3.0"; "MQRankSum < -12.5"; "ReadPosRankSum < -8.0"; "DP < 5"; "DP > 120"
#indels
#"FS > 200.0"; "ReadPosRankSum < -20.0"; "SOR > 10.0"; "DP < 5"; "DP > 120"  
######################################################################################################################


#RGQ
RGQ_filter <- function(x, RGQvalue=RGQ_value, minDP=min_DP, maxDP=max_DP) {
    ## Filter on RGQ > value; default is 30

    #out <- apply(geno(x)$RGQ>=value, 1, function(x)sum(x, na.rm=TRUE))==4
    
    out <- apply(geno(x)$RGQ >= RGQvalue & geno(x)$DP > minDP & geno(x)$DP < maxDP, 1, function(x)sum(x, na.rm=TRUE))==4

    snps_indels <- isIndel(x) | isSNV(x)
    
    out. <- ifelse(snps_indels==TRUE, snps_indels, out)
    
    out.[is.na(out.)] <- TRUE
    
    return(out.)
    
}

#ADDED 20161111
#GATK HARD FILTERS
#snps
#"QD < 2.0"; "MQ < 40.0"; "FS > 60.0"; "SOR > 3.0"; "MQRankSum < -12.5"; "ReadPosRankSum < -8.0"; "DP < 5"; "DP > 120"
snps <- function(x, minDP.=min_DP, maxDP.=max_DP, GQ.=GQ){

    out. <- apply(info(x)$QD > 2 & info(x)$MQ > 40 & info(x)$FS < 60 & info(x)$SOR < 3 & info(x)$MQRankSum > -12.5 & info(x)$ReadPosRankSum > -8 & geno(x)$DP >= minDP. & geno(x)$DP <= maxDP. & geno(x)$GQ >= GQ., 1, function(x)sum(x, na.rm=TRUE))==4

    out.. <- ifelse(!isSNV(x)==TRUE, TRUE, out.)
    
    out..[is.na(out..)] <- TRUE
    
    return(out..)
    
}

#"FS > 200.0"; "ReadPosRankSum < -20.0"; "SOR > 10.0"; "DP < 5"; "DP > 120"  
indels <- function(x, minDP..=min_DP, maxDP..=max_DP, GQ..=GQ){

    out <- apply(info(x)$FS < 200 & info(x)$SOR < 3 & info(x)$ReadPosRankSum > -8 & geno(x)$DP>=minDP.. & geno(x)$DP<=maxDP.. & geno(x)$GQ>=GQ.., 1, function(x)sum(x, na.rm=TRUE))==4
    
    out. <- ifelse(!isIndel(x)==TRUE, TRUE, out)
    
    out.[is.na(out.)] <- TRUE
    
    return(out.)
    
}

together <- function(x){

    a <- RGQ_filter(x)
    b <- snps(x)
    c <- indels(x)
    d <- cbind(a,b,c)
    out <- apply(d,1,sum)>0
    return(out)
}

##############################################################
##############################################################
##############################################################

prefilters <- FilterRules(list(RGQ_prefilter=isRGQ))

filters <- FilterRules(list(a=RGQ_filter))

#filters <- FilterRules(list(RGQ_filter=function(x){apply(geno(x)$RGQ>=30, 1, sum)!=4}))


file.gz <- input

file.gz.tbi <- tabix

destination.file <- output

size  <- CHUNKS

tabix.file <- open(TabixFile(file.gz, yieldSize=size))
    

#destination.file <- tempfile()

filterVcf(file=tabix.file, genome=ref, destination=destination.file, filters=filters, verbose=TRUE)

close(tabix.file)

if(length(warnings)>0){
print(warnings())
}


















