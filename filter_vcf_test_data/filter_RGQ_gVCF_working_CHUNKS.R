#!/usr/bin/env Rscript

################################################################################

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


# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
argv <- parser$parse_args()


if(argv["input_vcf"][[1]]=="VCF file"){stop("\n\n\n Needs 3 agruments: \n\n Argument 1: .g.vcf file \n Argument2: .g.vcf output file \n\n Argument3: tabix index \n\n\n For full help:\n plot_stats_vcf_CL_ARGS.R --help \n\n\n")}

input <- argv["input_vcf"][[1]]
output <- argv["output_vcf"][[1]]
RGQ_value <- argv["RGQ_value"][[1]]
tabix  <- argv["input_tabix"][[1]]

################################################################################



library("VariantAnnotation")

ref <- "rheMac3"

#x <- readVcf("test.vcf.gz", genome=ref)

#prefilter
#only those that have RGQ
isRGQ <- function(x) {
!(grepl("RGQ", x, fixed=TRUE))
}

#filters
RGQ_filter <- function(x, value=RGQ_value) {
## Filter on RGQ > value; default is 30

#test <- apply(geno(x)$RGQ>=value, 1, sum)==4

#out <- is.na(test) & test  

out <- apply(geno(x)$RGQ>=value, 1, sum)==4
    
out[is.na(out)] <- TRUE
    
return(out)
    
}

prefilters <- FilterRules(list(RGQ_prefilter=isRGQ))

filters <- FilterRules(list(RGQ_filter=RGQ_filter))

#filters <- FilterRules(list(RGQ_filter=function(x){apply(geno(x)$RGQ>=30, 1, sum)!=4}))


file.gz <- input

file.gz.tbi <- tabix

destination.file <- output

size=10

tabix.file <- open(TabixFile(file.gz, yieldSize=size))
    

#destination.file <- tempfile()

filterVcf(file=tabix.file, genome=ref, destination=destination.file, filters=filters, verbose=TRUE)

close(tabix.file)




















