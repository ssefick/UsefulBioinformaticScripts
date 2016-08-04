#!/usr/local/bin/python

'''
##################################################################
############################Preamble##############################
##################################################################
Author: Stephen A. Sefick Jr.

Last Update: 20160730

Purpose: This script produces a PBS header to be used with Torque/Moab qsub command. This script will prompt the user for input and write to script template.

Example usage:

Argument 1: Email for job status
e.g., email@whatever.com

Argument 2: Script name to write out
e.g., yourscript.sh

HPC_PBS_Header.py email@whatever.com yourscript.sh
##################################################################
##################################################################
##################################################################


##################################################################
#########################Example header###########################
##################################################################
#!/bin/sh

##choose queue
####PBS -q
##list - node are nodes: ppn are cpus per node: walltime=walltime
#PBS -l nodes=1:ppn=1,mem=10gb,walltime=30:00
##email
#PBS -M fake_email@auburn.edu
##send email abort; begin; end
#PBS -m ae
##job name
#PBS -N sra_test
##combine standard out and standard error
#PBS -j oe
##################################################################
##################################################################
##################################################################
'''


import sys

email = sys.argv[1]
output_file_name = sys.argv[2]

shebang = "#!/bin/bash"

nodes = raw_input("number of nodes: ")
ppn = raw_input("processors per node: ")
mem = raw_input("memory per cpu: ")
walltime = raw_input("Walltime (hh:mm:ss): ")
jobname = raw_input("Job Name: ")

with open(output_file_name, "w") as out:
        out.write("%s \n" % shebang)
        out.write("#PBS -l nodes=%s:ppn=%s,mem=%s,walltime=%s \n" % (nodes, ppn, mem, walltime))
        out.write("#PBS -M %s \n" % (email))
        out.write("#PBS -m ae \n")
        out.write("#PBS -N %s \n" % (jobname))
        out.write("#PBS -j oe \n")
