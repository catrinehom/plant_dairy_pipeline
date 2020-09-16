#!/usr/bin/env bash

# Program: make_db_mydbfinder.sh
# Description: This program makes a database for MyDbFinder, which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_mydbfinder.sh [-p <path to dairy pipeline>] [-n <name of project>] [-g <gene file path>] [-d <database name (common name for pathway/gene-set with "_db", e.g. "b12_db")>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, database name (common name for pathway/gene-set with "_db", e.g. "b12_db") (str)
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
usage() { echo "Usage: $0 [-p <path to dairy pipeline>] [-n <name of project>] [-g <gene file (placed in data folder)>] [-d <database name (common name for pathway/gene-set)>]"; exit 1; }

# Parse flags
while getopts ":p:n:d:h" opt; do
    case "${opt}" in
        p)
            p=${OPTARG}
            ;;
        n)
            n=${OPTARG}
            ;;
        g)
            g=${OPTARG}
            ;;
        d)
            d=${OPTARG}
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
if [ -z "${p}" ] || [ -z "${n}" ] || [ -z "${g}" ] || [ -z "${d}" ]; then
    echo "p, n and d are required flags"
    usage
fi

date=$(date "+%Y-%m-%d %H:%M:%S")
echo "Starting make_db_mydbfinder.sh ($date)"
echo "-----------------------------------------------"
echo -e "run_mydbfinder is a script to make a database for MyDbFinder.\n"

# Print files used
echo "Name of project used is: $n"
echo "Path used is: $p"
echo "Gene list used is: $p/data/$g"
echo "Database name used is: $d"

echo -e "Time stamp: $SECONDS seconds.\n"

################################################################################
# STEP 1: DOWNLOAD GENES
################################################################################
# TODO: change so it is not hardcoded
e=s136574@student.dtu.dk

# Go to path
cd $p/data/mydbfinder_db

# Download genes
${p}/src/misc/download_genes.py -f $g -n $d -e $e -p $p

################################################################################
# STEP 2: MAKE DATABASE
################################################################################

cd ${p}/data/${d}/mydbfinder_db

# Insert gene name in each file
for gene in $g
  do
    sed "s/>/>$gene/g" $gene > with_gene_name_${gene}
    echo "Gene name inserted in ${gene}.fasta"
  done

# Collect all genes in one file
cat with_gene_name_*.fasta > ${d}_db_spaces.fsa

# Remove spaces from headers in file
sed 's/ /_/g' ${d}_db_spaces.fsa > ${d}_db.fsa

# Clean up
for gene in $g
  do
    rm $gene.fasta
    rm with_gene_name_${gene}.fasta
  done

rm ${d}_db_spaces.fsa

################################################################################
# STEP 3: INDEX DATABASE
################################################################################

python ${p}/tools/mydbfinder/curate_database.py -i $p/data/mydbfinder_db/${d}_db.fsa -o $p/data/mydbfinder_db/

gzip $p/data/mydbfinder_db/${d}_db.fsa

kma index -i $p/data/mydbfinder_db/${d}_db.fsa.gz -o ${d}_db


echo "Database created: ${p}/data/$d"

