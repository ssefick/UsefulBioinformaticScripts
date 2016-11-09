#!/usr/bin/env Rscript

################################################################################

require(argparse)

parser <- ArgumentParser()
# specify our desired options
# by default ArgumentParser will add an help option


parser$add_argument("-i", "--input_vcf", action="store", default="Table from VCF file", dest="input_vcf",
 help="Input %(default)s")

parser$add_argument("-o", "--output_pdf", action="store", default="out.pdf", dest="output_pdf",
 help="Output %(default)s")

parser$add_argument("-DP", "--Depth_cut_off", action="store", default="TRUE", dest="raw_DP",
 help="TRUE/FALSE; Truncate graph to 5*SD; defaults to  %(default)s")


# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
argv <- parser$parse_args()

################################################################################

#test

test <- 0

if(test==1){

    input <- "Arctoides_raw_indels_table"

    output <- paste(input, "pdf", sep=".")

    argv <- c(input, output)
}

if(argv["input_vcf"][[1]]=="Table from VCF file"){stop("\n\n\n Needs 2 agruments: \n\n Argument 1: vcf table generated with GATK \n Argument2: pdf file for graphical output \n\n For full help:\n plot_stats_vcf_CL_ARGS.R --help \n\n\n")}

input <- argv["input_vcf"][[1]]
output <- argv["output_pdf"][[1]]
raw_DP <- argv["raw_DP"][[1]]

#libraries
require(ggplot2)
require(grid)
require(gtable)
require(gridExtra)


#get data in
x <- read.table(input, sep="\t", header=TRUE)

#plot FS data
FS.plot <- ggplot(x, aes(x=FS))+geom_density(alpha=0.2)
FS.plot <- FS.plot + scale_x_log10() + geom_vline(xintercept = 60, colour="red")
FS.plot <- FS.plot + ggtitle("Fisher Strand (FS- Strand Bias Variant on F or R)")

#plot QD
QD.plot <- ggplot(x, aes(x=QD))+geom_density(alpha=0.2)
QD.plot <- QD.plot + geom_vline(xintercept = 2, colour="red")
QD.plot <- QD.plot + ggtitle("QD -variant qual/unfiltered depth")

#plot DP
DP.plot <- ggplot(x, aes(x=DP))
DP.plot <- DP.plot + geom_density(alpha=0.2)
DP.plot <- DP.plot + ggtitle("DP- Depth")

x_bar<- mean(x$DP)
SD <- sd(x$DP)
x_bar_SD <- x_bar + (5*SD)

stats <- data.frame(mean=x_bar, SD=SD, mean_plus_5xSD=x_bar_SD)

if(raw_DP=="TRUE"){

    DP.plot <- DP.plot + geom_vline(xintercept=x_bar_SD, col="red")+xlim(0, x_bar_SD+50)

}

pdf(output)
FS.plot
QD.plot
DP.plot

############################################################################
##table Depth Stats
############################################################################

#old table
#grid.arrange(tableGrob(stats))

t1 <- tableGrob(stats)
title <- textGrob("Depth Statistics",gp=gpar(fontsize=50))
padding <- unit(5,"mm")
table <- gtable_add_rows(t1, heights = grobHeight(title) + padding, pos = 0)
table <- gtable_add_grob(table, title, 1, 1, 1, ncol(table))
grid.newpage()
grid.draw(table)
############################################################################
############################################################################
############################################################################

dev.off()
