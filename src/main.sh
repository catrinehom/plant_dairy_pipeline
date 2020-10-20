#!/bin/bash

# Program: main
# Description: This program run all parts of the dairy pipeline
# Version: 2.0
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
# LOADING MODULES
################################################################################

module load tools
module load anaconda3/4.4.0

################################################################################
# GET INPUT
################################################################################

usage() { echo "Usage: $0 [-n <name of project>] [-h <help>]"; }
exit_abnormal() { usage; exit 1; }

while getopts ":n:h" opt; do
   case "${opt}" in
       n)
           n=${OPTARG}
           ;;
       h)
           h=${OPTARG}
           usage
           exit 1
           ;;
       *)
           echo "Invalid option: ${OPTARG}"
           exit_abnormal
           ;;
   esac
done

################################################################################
# WELCOME
################################################################################

#date=$(date "+%Y%m%d_%H%M%S")
date=20201012_142944
echo -e "\nWelcome to this amazing program. Your time stamp is ${date}\n"

#############################################################################
# SETUP THE DIRECTORIES
################################################################################

# Get the root folder name
path=$(echo `realpath $0` | rev | cut -d'/' -f3- | rev)
echo -e  "\nRoot path is: ${path}\n"

# Giving permissions
#echo -e "Giving permissions to folder ${path} recursively\n"
#chmod -f -R 774 ${path} || 2>/dev/null

# Making project folders
#echo -e "Creating folders\n"
#mkdir -p ${path}/results/${n}_${date}/summary
#mkdir -p ${path}/docs/${n}
#echo -e "Created project folders.\n"

################################################################################
# RUN FOODQCPIPELINE
################################################################################

# Unzip compressed raw data
#echo -e "Extracting raw data\n"
#tar -zxvf ${path}/data/${n}/raw.tar.gz -C ${path}/data/${n}/
# Run foodQCpipeline and collect results in results/${n}/summary
#echo -e "Running foodQCPipeline\n"
#${path}/src/foodqcpipeline/run_foodqcpipeline.sh -p ${path} -n ${n} -d $date
${path}/src/foodqcpipeline/collect_foodqcpipeline.py -p $path -n $n -d $date
# Remove extracted raw data
#echo -e "Removing extracted data\n"
#rm -rf ${path}/data/${n}/raw

################################################################################
# RUN GC CONTENT CALCULATOR
################################################################################

${path}/src/GC/run_GC.sh -p ${path} -n ${n} -d ${date}

################################################################################
# RUN BANDAGE
################################################################################

${path}/src/bandage/run_bandage.sh -p ${path} -n ${n} -d ${date}

################################################################################
# RUN KMERFINDER
################################################################################

${path}/src/kmerfinder/run_kmerfinder.sh -p ${path} -n ${n} -d ${date}
${path}/src/kmerfinder/collect_kmerfinder.py -p ${path} -n ${n} -d ${date}

################################################################################
# RUN RESFINDER
################################################################################

${path}/src/resfinder/run_resfinder.sh -p ${path} -n ${n} -d ${date}
${path}/src/resfinder/collect_resfinder.py -p ${path} -n ${n} -d ${date}

################################################################################
# RUN MYDBFINDER
################################################################################

### lav til loop?

# databases = b12, glutamate
# for database in $databases:
#   do
#   if ${p}/data/db/$database not exist:
#       /home/projects/cge/people/cathom/src/mydbfinder/make_db_mydbfinder.sh -p $path -n $n -g $g -d $database
#
#   ${path}/src/mydbfinder/run_mydbfinder.sh -p ${path} -n ${n} -d ${date} -b $databases
#   ${path}/src/mydbfinder/collect_mydbfinder.py -p ${path} -n ${n} -d ${date} -b b12_db
#   done

## b12
${path}/src/mydbfinder/run_mydbfinder.sh -p ${path} -n ${n} -d ${date} -b b12
${path}/src/mydbfinder/collect_mydbfinder.py -p ${path} -n ${n} -d ${date} -b b12

## glutamate
${path}/src/mydbfinder/run_mydbfinder.sh -p ${path} -n ${n} -d ${date} -b glutamate
${path}/src/mydbfinder/collect_mydbfinder.py -p ${path} -n ${n} -d ${date} -b glutamate

## iron transporters
${path}/src/mydbfinder/run_mydbfinder.sh -p ${path} -n ${n} -d ${date} -b iron_transporter
${path}/src/mydbfinder/collect_mydbfinder.py -p ${path} -n ${n} -d ${date} -b iron_transporter

################################################################################
# RUN PROKKA
################################################################################

${path}/src/prokka/run_prokka.sh -p ${path} -n ${n} -d ${date}
${path}/src/prokka/collect_prokka.py -p ${path} -n ${n} -d ${date}

################################################################################
# GOODBYE
################################################################################

echo -e "Dairy pipeline completed. Results saved in ${n}_${date}"

