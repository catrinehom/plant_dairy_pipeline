#!/usr/bin/env bash

# Program: run_mydbfinder.sh
# Description: This program run MyDbFinder which is a part of the dairy pipeline
# Version: 1.1
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
d=$(date "+_%Y%m%d_%H%M%S")

# Parse flags
while getopts ":p:n:d:b:h" opt; do
    case "${opt}" in
        p)
            p=${OPTARG}
            ;;
        n)
            n=${OPTARG}
            ;;
        d)
            d=_${OPTARG}
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
if [ -z "${p}" ] || [ -z "${n}" ]|| [ -z "${b}" ]; then
    echo "p, n and b are required flags"
    usage
fi

date=$(date "+%Y-%m-%d %H:%M:%S")
echo "Starting run_mydbfinder.sh ($date)"
echo "--------------------------------------------------------------------------------"

# Print files used
echo "Path used is: ${p}"
echo "Results will be saved: ${n}${d}"
echo "Database used is: ${p}/data/db/$b"

echo -e "Time stamp: $SECONDS seconds.\n"

################################################################################
# STEP 1: RUN TOOL
################################################################################

echo "Starting STEP 1: Run MyDbFinder"

# Define variables
tool_name=mydbfinder

# Create mydbfinder folder if it doesnt already exists
mydbfolder=${p}/results/${n}${d}/${tool_name}
mkdir -p $mydbfolder

# Make output directory
outputfolder=${mydbfolder}/${b}
[ -d $outputfolder ] && echo "Output directory: ${outputfolder} already exists. Files will be overwritten." || mkdir -p $outputfolder

# Define variables
samples=$(ls ${p}/results/${n}${d}/foodqcpipeline)
count=$((1))
total=$(wc -w <<<$samples)
tool=${p}/tools/${tool_name}/mydbfinder.py

# Run tool on all samples
for sample in $samples
  do
    echo "Starting with: $sample ($count/$total)"

    # Create sample output folder
    sample_path=${outputfolder}/${sample}
    [ -d $sample_path ] && echo "Output directory: ${sample_path} already exists. Files will be overwritten." || mkdir $sample_path

    # Define tool inputs
    i=$p/results/${n}${d}/foodqcpipeline/${sample}/Assemblies/*_trimmed/*.fa
    o=${outputfolder}/${sample}
    database=${p}/data/db/${tool_name}/$b

    # Run tool
    $tool -i $i -o $o -p $database
    echo "Finished with: $sample"
    count=$(($count+1))
  done

echo "Results of tool were succesfully made."
echo "Time stamp: $SECONDS seconds."

