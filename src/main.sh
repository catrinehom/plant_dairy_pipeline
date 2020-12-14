#!/bin/bash

# Program: main
# Description: This program run all parts of the dairy pipeline
# Version: 3.2
# Author: Catrine Høm and Line Andresen

# Usage:
    ## main [-n name of project>]
    ## -n, name of project

# Output:
    ## Quality control of data
    ## Assemblies
    ## Species identification
    ## Resistance genes
    ## Dairy genes and pathways

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

# Get the root folder name
path=$(echo `realpath $0` | rev | cut -d'/' -f3- | rev)
echo -e  "Root path is: ${path}\n" | tee -a $log

# Create log file
log=${path}/results/${name}_${date}.log
touch $log

################################################################################
# WELCOME
################################################################################

echo -e "\n"  | tee -a $log
echo "Starting plant dairy pipeline ($datestamp)"  | tee -a $log
echo -e "--------------------------------------------------------------------------------\n"  | tee -a $log

#############################################################################
# SETUP THE DIRECTORIES
################################################################################

# Check file structure
echo -e "Checking file structure..." | tee -a $log
dirs="data results src tools docs"
for dir in $dirs; do
    if [ ! -d "${path}/${dir}" ]; then
      echo "Fatal error! ${path}/${dir} directory does not exists" | tee -a $log
      exit 1
    fi
done
echo -e "File structure is ok\n" | tee -a $log

# Making project folders
echo -e "Creating folders for project..." | tee -a $log
mkdir -p ${path}/results/${name}_${date}/summary
mkdir -p ${path}/docs/${name}
mv $log ${path}/results/${name}_${date}/
log=${path}/results/${name}_${date}/${name}_${date}.log
echo -e "Project folders created\n" | tee -a $log

################################################################################
# EXTRACT DATA
################################################################################

# Check input folder exists
echo -e "Checking input file folder..." | tee -a $log
if [ ! -d "${path}/data/${name}" ]; then
  echo "Fatal error! ${path}/data/${name} directory does not exists" | tee -a $log
  exit 1
fi
echo -e "Input file exists\n" | tee -a $log

# Check input raw.tar.gz exists
echo -e "Checking raw.tar.gz exists..." | tee -a $log
if [ ! -f "${path}/data/${name}/raw.tar.gz" ]; then
  echo "Fatal error! ${path}/data/${name}/raw.tar.gz file does not exists" | tee -a $log
  exit 1
fi
echo -e "raw.tar.gz exists\n" | tee -a $log

# Unzip compressed raw data
echo -e "Extracting raw data..." | tee -a $log
tar -zxvf ${path}/data/${name}/raw.tar.gz -C ${path}/data/${name}/ > /dev/null 2>&1
echo -e "Raw data extracted\n" | tee -a $log

################################################################################
# RUN CRITERIA CHECK
################################################################################

module purge
module load tools
module load anaconda3/4.4.0
${path}/src/misc/criteria_check.py -p ${path} -n ${name} -d ${date} -t raw 2>&1 | tee -a $log

################################################################################
# RUN FOODQCPIPELINE
################################################################################

${path}/src/foodqcpipeline/run_foodqcpipeline.sh -p ${path} -n ${name} -d ${date} 2>&1 | tee -a $log

# Remove extracted raw data
echo -e "Removing extracted data..." | tee -a $log
rm -rf ${path}/data/${name}/raw
echo -e "Extracted data removed\n" | tee -a $log

################################################################################
# RUN CRITERIA CHECK
################################################################################

module purge
module load tools
module load anaconda3/4.4.0
${path}/src/misc/criteria_check.py -p ${path} -n ${name} -d ${date} -t qc 2>&1 | tee -a $log

################################################################################
# RUN KMERFINDER
################################################################################

${path}/src/kmerfinder/run_kmerfinder.sh -p ${path} -n ${name} -d ${date} 2>&1 | tee -a $log

################################################################################
# RUN CRITERIA CHECK
################################################################################

module purge
module load tools
module load anaconda3/4.4.0
${path}/src/misc/criteria_check.py -p ${path} -n ${name} -d ${date} -t lab 2>&1 | tee -a $log

################################################################################
# RUN GC CONTENT CALCULATOR
################################################################################

${path}/src/GC/run_GC.sh -p ${path} -n ${name} -d ${date} 2>&1 | tee -a $log

################################################################################
# RUN BANDAGE
################################################################################

${path}/src/bandage/run_bandage.sh -p ${path} -n ${name} -d ${date} 2>&1 | tee -a $log

################################################################################
# RUN FASTANI
################################################################################

${path}/src/fastani/run_fastani.sh -p ${path} -n ${name} -d ${date} 2>&1 | tee -a $log

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
# RUN PROKKA
################################################################################

${path}/src/prokka/run_prokka.sh -p ${path} -n ${name} -d ${date} 2>&1 | tee -a $log

################################################################################
# RUN DBCAN
################################################################################

${path}/src/dbcan/run_dbcan.sh -p ${path} -n ${name} -d ${date} 2>&1 | tee -a $log

################################################################################
# RUN CRITERIA CHECK
################################################################################

module purge
module load tools
module load anaconda3/4.4.0
${path}/src/misc/criteria_check.py -p ${path} -n ${name} -d ${date} -t roary
echo -e "Completed criteria check for Roary"

################################################################################
# RUN ROARY
################################################################################

${path}/src/roary/run_roary.sh -p ${path} -n ${name} -d ${date} 2>&1 | tee -a $log

################################################################################
# PLOTS
################################################################################

module purge
module load tools
module load anaconda3/4.4.0

${path}/src/misc/plots.py -p ${path} -n ${name} -d ${date}

################################################################################
# GOODBYE
################################################################################
# Give permissions to all results
chmod -f -R 770 ${path}/results/${name}_${date} || 2>/dev/null

echo -e "Dairy pipeline completed. Results saved in ${path}/results/${name}_${date}" | tee -a $log

