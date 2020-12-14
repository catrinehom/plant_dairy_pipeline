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
    ## Database specific gene finder

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
echo -e "Database used is: ${path}/data/db/${database}\n"

################################################################################
# STEP 1: RUN MYDBFINDER
################################################################################

# Define variables
tool_name=mydbfinder

# Create mydbfinder folder if it doesnt already exists
mydbfolder=${path}/results/${name}_${date}/${tool_name}
mkdir -p $mydbfolder

# Make output directory
outputfolder=${mydbfolder}/${database}
[ -d $outputfolder ] || mkdir -p $outputfolder

# Define variables
samples=$(cat ${path}/results/${name}_${date}/tmp/species_approved.txt)
count=$((1))
total=$(wc -w <<<$samples)
tool=${path}/tools/${tool_name}/mydbfinder.py

# Run tool on all samples
for sample in $samples
  do
    echo "Running: $sample ($count/$total)"

    # Create sample output folder
    sample_path=${outputfolder}/${sample}
    [ -d $sample_path ] || mkdir $sample_path

    # Define tool inputs
    i=${path}/results/${name}_${date}/foodqcpipeline/${sample}/Trimmed/*.trim.fq.gz
    o=${sample_path}
    db=${path}/data/db/${tool_name}/${database}/

    # Run tool
    $tool -i $i -o $o -p $db > /dev/null 2>&1
    count=$(($count+1))
  done

# Run collect script
module purge
module load tools
module load anaconda3/4.0.0
${path}/src/${tool_name}/collect_${tool_name}.py -p ${path} -n ${name} -d ${date} -b ${database}

echo -e "The tool ${tool_name} with database ${database} finished in $SECONDS seconds.\n"

