#!/bin/sh

# Program: main
# Description: This program run all parts of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## main [-n name of project>] [-q <qc>]
    ## -n, name of project
    ## -q, flag to run qc

# Output:
    ## extracted folder

# This pipeline consists of many steps:
    ## STEP 100: write


#######################
# LOADING MODULES
#######################

module load tools
module load anaconda3/4.0.0
#module load anaconda2/2.2.0
#module load SPAdes/3.9.0
#module load perl
#module load ncbi-blast/2.2.26
#module load cgepipeline/20180109
#module load kma/1.2.11

########################
# PARSING
########################

usage() { echo "Usage: $0 [-n <name of project>] [-h <help>]"; }
exit_abnormal() { usage; exit 1; }

while getopts ":n:qh" opt; do
   case "${opt}" in
       n)
           n=${OPTARG}
           ;;
       q)
           q="True"
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

#############################
# SETUP THE DIRECTORIES
#############################

# get the main folder name
path=$(echo `realpath $0` | rev | cut -d'/' -f4- | rev)
echo -e  "\nMain path is: ${path}\n"

# Making project folders
echo -e "Checking if project folders exist:\n"
[ -d ${path}/data/${n} ] && echo "Project folder: data/$n already exists." || mkdir -p ${path}/data/${n}/raw
[ -d ${path}/results/${n} ] && echo "Project folder: results/$n already exists." || mkdir -p ${path}/results/${n}/summary
[ -d ${path}/doc/${n} ] && echo "Project folder: doc/$n already exists." || mkdir ${path}/doc/${n}
echo -e "\nDone checking project folders.\n"

#######################
# RUNNING QC
#######################

# Checking if QC should be run
# if dir:qc doesnt exist, dir:qc is empty or flag is put.
if [ ! -d "${path}/data/${n}/foodqcpipeline" ] || [ -z "$(ls -A ${path}/data/${n}/foodqcpipeline)" ] || [${q}]; then
   if [ -z "$(ls -A ${path}/data/${n}/raw)" ]; then
       echo "Please put a data in ${path}/data/${n}/raw in format .tar.gz"
   else
       cd ${path}/data/${n}/raw/
       files=$(find \( -name "*.tar.gz" -o -name "*.zip" \))
       for file in ${files}; do
           echo -e "Extracting ${file}...\n"
           case ${file} in
               *.tar.gz) tar -xz -f "${file}" ;;
               *.zip)    unzip      "${file}"
                         rm -rf __* ;;
               *) echo "File need to be in .tar.gz or .zip format"
                  exit 1
           esac
           echo -e "... data was extracted.\n"
       done
       foldername=$(echo "${files}" | cut -d'/' -f2 | cut -d'.' -f1 )
       echo -e "Name of folder is: ${foldername}\n\n"
       ${path}/src/foodqcpipeline/foodqcpipeline_run.sh -p ${path} -n ${n} -f ${foldername}       
       chmod -R 774 ${path}/data/${n}/foodqcpipeline/
       ${path}/src/foodqcpipeline/foodqcpipeline_collect.py -p ${path} -n ${n}
   fi
else
   echo -e "QC has previously been carried out, moving on.\n"
fi

######################
# RUNNING KMERFINDER 
######################

echo -e "Running KmerFinder\n"
