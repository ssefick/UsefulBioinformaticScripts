#!/usr/bin/env Rscript

############################################################################################

############################################################################################
#Typical Usage
#remember to tabix
#bgzip test2.vcf
#tabix -p vcf -f test2.vcf
#./SelectVariants.R -I test2.vcf.gz -O test3.vcf -V snp -T test2.vcf.gz.tbi
############################################################################################

suppressPackageStartupMessages(library("optparse"))
parser <- OptionParser()

# specify our command line options
option_list <- list(
make_option(c("-I", "--vcf_input"), type="character", default="input_vcf", help="input vcf file name", metavar="character"),

make_option(c("-T", "--tabix_index"), type="character", default="tabix_file", help="tabix file name", metavar="character"),

make_option(c("-O", "--vcf_output"), type="character", default="output_vcf", help="output vcf file name", metavar="character"),

make_option(c("-C", "--CHUNK"), type="integer", default=10, help="Default [default %default]", metavar="number"),

make_option(c("-V", "--variant_type"), type="character", default="snp or indel", help="Default [default %default]", metavar="character")

)

parser <- parse_args(OptionParser(option_list=option_list))

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
opt_parser  <-  OptionParser(option_list=option_list)
opt  <-  parse_args(opt_parser)

if(opt$vcf_input=="vcf_input" | opt$vcf_output=="vcf_output" | opt$tabix_index=="tabix_index" | opt$variant_type=="snp or indel") {stop("\n\n\n Needs 4 agruments: \n\n Argument 1: .g.vcf file \n Argument2: .g.vcf output file \n Argument3: tabix index \n Argument4: variant type - snp or indel \n For full help:\n variants_from_vcf.R --help \n\n\n")}

input <- opt$vcf_input
output <- opt$vcf_output
tabix  <- opt$tabix_index
CHUNKS  <- opt$CHUNK
variant_type <- opt$variant_type 
################################################################################

library("VariantAnnotation")

ref <- "rheMac3"

################################################################################
################################################################################
################################################################################
#test data
test <- 0

#This is used to test how filters work on the test data
manual_test  <- 0

if(test==1){
input <- "test.vcf.gz"

tabix <- "test.vcf.gz.tbi"

output <- "test2_snps"

CHUNKS <- 10

if(manual_test==1){
    x <- readVcf("test.vcf.gz", genome=ref)
}

}
################################################################################
################################################################################
################################################################################

##############################################################
##############################################################
##############################################################
snp <- function(x, variant_type=variant_type){
    out <-  isSNV(x)    
    return(out)
}

indel <- function(x, variant_type=variant_type){    
    out <-  isIndel(x)    
    return(out)
}

if(variant_type=="snp"){

    filters <- FilterRules(list(a=snp))

}

if(variant_type=="indel"){

    filters <- FilterRules(list(a=indel))

}

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


















