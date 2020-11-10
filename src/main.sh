#!/bin/bash

# Program: main
# Description: This program run all parts of the dairy pipeline
# Version: 2.2
# Author: Catrine Høm and Line Andresen

# Usage:
    ## main [-n name of project>]
    ## -n, name of project

# Output:
    ## Quality control of data
    ## Assemblies
    ## Species identification
    ## Resistance genes
    ## Dairy genes

# This pipeline consists of many steps:
    ## STEP 100: write

################################################################################
# GET INPUT
################################################################################

# Define dates used
date=$(date "+%Y%m%d_%H%M%S")
datestamp=$(date "+%Y-%m-%d %H:%M:%S")

usage() { echo "Usage: $0 [-n <name of project>] [-d <date>] [-h <help>]"; exit 1;}

while getopts ":n:d:h" opt; do
   case "${opt}" in
       n)
           name=${OPTARG}
           ;;
       d)
           date=${OPTARG}
           ;;
       h)
           usage
           ;;
       *)
           echo "Invalid option: ${OPTARG}"
           usage
           ;;
   esac
done

# Check if required flags are empty
if [ -z "${name}" ]; then
    echo "n is a required flag"
    usage
fi

################################################################################
# WELCOME
################################################################################

echo -e "\n"
echo "Starting plant dairy pipeline ($datestamp)"
echo -e "--------------------------------------------------------------------------------\n"  | tee -a $log

#############################################################################
# SETUP THE DIRECTORIES
################################################################################

# Get the root folder name
path=$(echo `realpath $0` | rev | cut -d'/' -f3- | rev)
echo -e  "Root path is: ${path}\n" | tee -a $log

# Giving permissions
#echo -e "Giving permissions to folder ${path} recursively.\n" | tee -a $log
#chmod -f -R 770 ${path} || 2>/dev/null

# Create log file
log=${path}/results/${name}_${date}.log
touch $log
## Add first when running a script, second if its an echo
# 2>&1 | tee -a $log
# | tee -a $log

# Check file structure
dirs="data results src tools docs"
for dir in $dirs; do
    if [ ! -d "${path}/${dir}" ]; then
      echo "Fatal error! ${path}/${dir} directory does not exists" | tee -a $log
      exit 1
    fi
done

# TODO: Test that input fastq files are in correct file structure (placement + name)

# Check format of input files

# Making project folders
echo -e "Creating folders..." | tee -a $log
mkdir -p ${path}/results/${name}_${date}/summary
mkdir -p ${path}/docs/${name}
echo -e "Project folders created.\n" | tee -a $log

################################################################################
# RUN FOODQCPIPELINE
################################################################################

# Unzip compressed raw data
echo -e "Extracting raw data..." | tee -a $log
tar -zxvf ${path}/data/${name}/raw.tar.gz -C ${path}/data/${name}/ || 2>/dev/null
echo -e "Raw data extracted.\n" | tee -a $log

# Check format of raw input files
#${path}/src/error_handling.py -p ${path} -n ${name} -d ${date} -i raw 2>&1 | tee -a $log

################################################################################
# RUN FOODQCPIPELINE
################################################################################

${path}/src/foodqcpipeline/run_foodqcpipeline.sh -p ${path} -n ${name} -d ${date} 2>&1 | tee -a $log

# Remove extracted raw data
echo -e "Removing extracted data." | tee -a $log
rm -rf ${path}/data/${name}/raw
echo -e "Extracted data removed.\n" | tee -a $log

# Check format of output files for later use
${path}/src/error_handling.py -p ${path} -n ${name} -d ${date} -i fastq 2>&1 | tee -a $log
${path}/src/error_handling.py -p ${path} -n ${name} -d ${date} -i fasta 2>&1 | tee -a $log
${path}/src/error_handling.py -p ${path} -n ${name} -d ${date} -i gfa 2>&1 | tee -a $log

################################################################################
# RUN GC CONTENT CALCULATOR
################################################################################

${path}/src/GC/run_GC.sh -p ${path} -n ${name} -d ${date} 2>&1 | tee -a $log

################################################################################
# RUN BANDAGE
################################################################################

${path}/src/bandage/run_bandage.sh -p ${path} -n ${name} -d ${date} 2>&1 | tee -a $log

################################################################################
# RUN KMERFINDER
################################################################################

${path}/src/kmerfinder/run_kmerfinder.sh -p ${path} -n ${name} -d ${date} 2>&1 | tee -a $log

################################################################################
# RUN RESFINDER
################################################################################

${path}/src/resfinder/run_resfinder.sh -p ${path} -n ${name} -d ${date} 2>&1 | tee -a $log

################################################################################
# RUN MYDBFINDER
################################################################################

databases="b12 glutamate iron_transporter"

for database in $databases
do
  ${path}/src/mydbfinder/run_mydbfinder.sh -p ${path} -n ${name} -d ${date} -b $database 2>&1 | tee -a $log
done

################################################################################
# RUN DBCAN
################################################################################

${path}/src/dbcan/run_dbcan.sh -p ${path} -n ${name} -d ${date} 2>&1 | tee -a $log

################################################################################
# RUN PROKKA
################################################################################

${path}/src/prokka/run_prokka.sh -p ${path} -n ${name} -d ${date} 2>&1 | tee -a $log

# Check format of output files
${path}/src/error_handling.py -p ${path} -n ${name} -d ${date} -i gff 2>&1 | tee -a $log

################################################################################
# RUN ROARY
################################################################################


################################################################################
# GOODBYE
################################################################################
# Give permissions to all results
chmod -f -R 770 ${path}/results/${name}_${date} || 2>/dev/null

echo -e "Dairy pipeline completed. Results saved in ${name}_${date}" | tee -a $log

