#!/usr/bin/env bash

# Program: make_db_mydbfinder.sh
# Description: This program makes a database for MyDbFinder, which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_mydbfinder.sh [-p <path to dairy pipeline>] [-b <database name (common name for pathway/gene-set)>]
    ## -p, path to dairy pipeline folder (str)
    ## -b, database name (common name for pathway/gene-set) (str)
    ## -g, gene file, path to a txt file with gene names, one gene per line.

# Output:
    ## Outputfile 1
    ## Outputfile 2

# This pipeline consists of 3 steps:
    ## STEP 1: Downlad genes
    ## STEP 2: Make database
    ## STEP 3: Index database


################################################################################
# GET INPUT
################################################################################

# Load all required modules for the job
module load tools
module load anaconda3/4.4.0
module load anaconda2/2.2.0
module load kma/1.2.11

# Start timer for logfile
SECONDS=0

# How to use program
usage() { echo "Usage: $0 [-p <path to dairy pipeline>] [-b <database name (common name for pathway/gene-set)>]"; exit 1; }

# Parse flags
while getopts ":p:b:h" opt; do
    case "${opt}" in
        p)
            p=${OPTARG}
            ;;
        b)
            b=${OPTARG}
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
if [ -z "${p}" ] || [ -z "${b}" ]; then
    echo "p and b are required flags"
    usage
fi

date=$(date "+%Y-%m-%d %H:%M:%S")
echo "Starting make_db_mydbfinder.sh ($date)"
echo "--------------------------------------------------------------------------------"

# Print files used
echo "Path used is: $p"
echo "Gene list used is: $p/data/${b}.txt"
echo "Database name used is: $b"

echo -e "Time stamp: $SECONDS seconds.\n"

# Define variables
tool_name=mydbfinder

# Make output directory
outputfolder=${p}/data/db/${tool_name}/${b}
[ -d $outputfolder ] && echo "Output directory: ${outputfolder} already exists. Files will be overwritten." || mkdir -p $outputfolder

################################################################################
# STEP 1: DOWNLOAD GENES
################################################################################
# TODO: change so it is not hardcoded
e=s136574@student.dtu.dk

# Download genes
#${p}/src/misc/download_genes.py -p $p -b $b -e $e

################################################################################
# STEP 2: MAKE DATABASE
################################################################################
genes=$(ls ${outputfolder})

# Insert gene name in each file
for gene in $genes
  do
    sed "s/>/>$gene/g" ${outputfolder}/$gene > ${outputfolder}/with_gene_name_${gene}
    echo "Gene name inserted in ${gene}"
  done

# Collect all genes in one file
cat ${outputfolder}/with_gene_name_*.fasta > ${outputfolder}/${b}_spaces.fsa

# Remove spaces from headers in file
sed 's/ /_/g' ${outputfolder}/${b}_spaces.fsa > ${outputfolder}/${b}.fsa

# Clean up
for gene in $genes
  do
    rm ${outputfolder}/${gene}
    rm ${outputfolder}/with_gene_name_${gene}
  done

rm ${outputfolder}/${b}_spaces.fsa

################################################################################
# STEP 3: INDEX DATABASE
################################################################################

python ${p}/tools/${tool_name}/curate_database.py -i ${outputfolder}/${b}.fsa -o ${outputfolder}/

gzip -f ${outputfolder}/${b}.fsa

kma index -i ${outputfolder}/${b}.fsa.gz -o ${outputfolder}/${b}


echo "Database created: ${outputfolder}/$b"

