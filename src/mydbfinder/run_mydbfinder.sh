#!/usr/bin/env bash

# Program: run_mydbfinder.sh
# Description: This program run MyDbFinder which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_mydbfinder.sh [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run (optional)>] [-d <database name (common name for pathway/gene-set")>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str)
    ## -b, database name (common name for pathway/gene-set") (str)

# Output:
    ## Outputfile 1
    ## Outputfile 2

# This pipeline consists of 1 steps:
    ## STEP 1:  Run MyDbFinder


################################################################################
# GET INPUT
################################################################################

# Load all required modules for the job
module purge
module load tools
module load anaconda3/4.4.0
module load anaconda2/2.2.0
module load kma/1.2.11

# Start timer for logfile
SECONDS=0

# How to use program
usage() { echo "Usage: $0 [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run>] [-b <database name (common name for pathway/gene-set)>]"; exit 1; }

# Default values
date=$(date "+%Y%m%d_%H%M%S")

# Parse flags
while getopts ":p:n:d:b:h" opt; do
    case "${opt}" in
        p)
            path=${OPTARG}
            ;;
        n)
            name=${OPTARG}
            ;;
        d)
            date=${OPTARG}
            ;;
        b)
            database=${OPTARG}
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
if [ -z "${path}" ] || [ -z "${name}" ]|| [ -z "${database}" ]; then
    echo "p, n and b are required flags"
    usage
fi

datestamp=$(date "+%Y-%m-%d %H:%M:%S")
echo "Starting run_mydbfinder.sh ($datestamp)"
echo "--------------------------------------------------------------------------------"

# Print files used
echo "Path used is: ${path}"
echo "Results will be saved: ${name}_${date}"
echo "Database used is: ${path}/data/db/${database}"

################################################################################
# STEP 1: RUN TOOL
################################################################################

echo "Starting STEP 1: Run MyDbFinder"

# Define variables
tool_name=mydbfinder

# Create mydbfinder folder if it doesnt already exists
mydbfolder=${path}/results/${name}_${date}/${tool_name}
mkdir -p $mydbfolder

# Make output directory
outputfolder=${mydbfolder}/${database}
[ -d $outputfolder ] && echo "Output directory: ${outputfolder} already exists. Files will be overwritten." || mkdir -p $outputfolder

# Define variables
samples=$(cat ${path}/results/${name}_${date}/tmp/fasta_approved.txt)
count=$((1))
total=$(wc -w <<<$samples)
tool=${path}/tools/${tool_name}/mydbfinder.py

# Run tool on all samples
for sample in $samples
  do
    echo "Starting with: $sample ($count/$total)"

    # Create sample output folder
    sample_path=${outputfolder}/${sample}
    [ -d $sample_path ] && echo "Output directory: ${sample_path} already exists. Files will be overwritten." || mkdir $sample_path

    # Define tool inputs
    i=${path}/results/${name}_${date}/foodqcpipeline/${sample}/Trimmed/*.trim.fq.gz
    o=${outputfolder}/${sample}
    db=${path}/data/db/${tool_name}/${database}/

    # Run tool
    $tool -i $i -o $o -p $db --min_cov 0.5 --threshold 0.5
    echo "Finished with: $sample"
    count=$(($count+1))
  done

# Run collect script
module purge
module load tools
module load anaconda3/4.0.0
${path}/src/${tool_name}/collect_${tool_name}.py -p ${path} -n ${name} -d ${date} -b ${database}

echo -e "${tool_name} finished in $SECONDS seconds.\n"

