#!/usr/bin/env Rscript

############################################################################################

############################################################################################
#Typical Usage
#./filter_RGQ_gVCF_working_CHUNKS.R -i test.vcf.gz -t test.vcf.gz.tbi -RGQ 30 -o test2 -C 10
############################################################################################

suppressPackageStartupMessages(library("optparse"))
parser <- OptionParser()

# specify our command line options
option_list <- list(
make_option(c("-I", "--vcf_input"), type="character", default="input_vcf", help="input vcf file name", metavar="character"),

make_option(c("-T", "--tabix_index"), type="character", default="tabix_file", help="tabix file name", metavar="character"),

make_option(c("-O", "--vcf_output"), type="character", default="output_vcf", help="output vcf file name", metavar="character"),

make_option(c("--Reference_Genotype_Quality"), type="integer", default=20, help="Default [default %default]", metavar="number"),

make_option(c("--min_Depth"), type="integer", default=5, help="Default [default %default]", metavar="number"),

make_option(c("--max_Depth"), type="integer", default=120, help="Default [default %default]", metavar="number"),

make_option(c("--Genotype_Quality"), type="integer", default=20, help="Default [default %default]", metavar="number"),

make_option(c("-C", "--CHUNK"), type="integer", default=10, help="Default [default %default]", metavar="number")
)

parser <- parse_args(OptionParser(option_list=option_list))

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
opt_parser  <-  OptionParser(option_list=option_list)
opt  <-  parse_args(opt_parser)

if(opt$vcf_input=="vcf_input" | opt$vcf_output=="vcf_output" | opt$tabix_index=="tabix_index"){stop("\n\n\n Needs 3 agruments: \n\n Argument 1: .g.vcf file \n Argument2: .g.vcf output file \n\n Argument3: tabix index \n\n\n For full help:\n plot_stats_vcf_CL_ARGS.R --help \n\n\n")}

input <- opt$vcf_input
output <- opt$vcf_output
tabix  <- opt$tabix_index
CHUNKS  <- opt$CHUNK
#filters
RGQ_value <- opt$Reference_Genotype_Quality
min_DP  <- opt$min_Depth
max_DP  <- opt$max_Depth
GQ  <- opt$Genotype_Quality
################################################################################

#test data

test <- 0

if(test==1){
input <- "test.vcf.gz"
tabix <- "test.vcf.gz.tbi"
RGQ_value <- 30
min_DP <- 5
max_DP <- 35
GQ <- 30
output <- "test2"
CHUNKS <- 10
#x <- readVcf("test.vcf.gz", genome=ref)
}

library("VariantAnnotation")

ref <- "rheMac3"


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
    
    out <- geno(x)$RGQ >= RGQ_value & geno(x)$DP > min_DP & geno(x)$DP < max_DP

    #snps_indels <- isIndel(x) | isSNV(x)
    
    #out. <- ifelse(snps_indels==TRUE, snps_indels, out)
    
    #out.[is.na(out.)] <- TRUE
    
    return(out)
    
}

#ADDED 20161111
#GATK HARD FILTERS
#snps
#"QD < 2.0"; "MQ < 40.0"; "FS > 60.0"; "SOR > 3.0"; "MQRankSum < -12.5"; "ReadPosRankSum < -8.0"; "DP < 5"; "DP > 120"
snps <- function(x, minDP.=min_DP, maxDP.=max_DP, GQ.=GQ){

    out <- info(x)$QD > 2 & info(x)$MQ > 40 & info(x)$FS < 60 & info(x)$SOR < 3 & info(x)$MQRankSum > -12.5 & info(x)$ReadPosRankSum > -8 & geno(x)$DP > minDP. & geno(x)$DP < maxDP. & geno(x)$GQ >= GQ.

    #out.. <- ifelse(!isSNV(x)==TRUE, TRUE, out.)
    
    #out..[is.na(out..)] <- TRUE
    
    return(out)
    
}

#"FS > 200.0"; "ReadPosRankSum < -20.0"; "SOR > 10.0"; "DP < 5"; "DP > 120"  
indels <- function(x, minDP..=min_DP, maxDP..=max_DP, GQ..=GQ){

    out <- info(x)$FS < 200 & info(x)$SOR < 3 & info(x)$ReadPosRankSum > -8 & geno(x)$DP>minDP.. & geno(x)$DP<maxDP.. & geno(x)$GQ>=GQ..
    
    #out. <- ifelse(!isIndel(x)==TRUE, TRUE, out)
    
    #out.[is.na(out.)] <- TRUE
    
    return(out)
    
}

together <- function(x){

    a <- RGQ_filter(x)
    b <- snps(x)
    c <- indels(x)
    d <- cbind(a,b,c)
    out <- apply(d,1,sum, na.rm=TRUE)>0
    return(out)
}

##############################################################
##############################################################
##############################################################

prefilters <- FilterRules(list(RGQ_prefilter=isRGQ))

filters <- FilterRules(list(a=together))

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


















