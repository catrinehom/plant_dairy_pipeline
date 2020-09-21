#!/usr/bin/env bash

# Program: run_GC.sh
# Description: This program run GC which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## rh run_GC [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run (optional)>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)

# Output:
    ## Outputfile 1
    ## Outputfile 2

# This pipeline consists of 1 steps:
    ## STEP 1:  Run GC


################################################################################
# GET INPUT
################################################################################

# Load all required modules for the job
module load tools
module load python36
module load anaconda3/4.4.0

# Start timer for logfile
SECONDS=0

# How to use program
usage() { echo "Usage: $0 [-p <path to main>] [-n <name of project>] [-d <date of run (optional)>]"; exit 1; }

# Parse flags
while getopts ":p:n:h" opt; do
    case "${opt}" in
        p)
            p=${OPTARG}
            ;;
        n)
            n=${OPTARG}
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
if [ -z "${p}" ] || [ -z "${n}" ]; then
    echo "p and n are required flags"
    usage
fi

date=$(date "+%Y-%m-%d %H:%M:%S")
echo "Starting run_GC.sh ($date)"
echo "--------------------------------------------------------------------------------"

# Print files used
echo "Name of project used is: ${n}"
echo "Path used is: ${p}"

echo -e "Time stamp: $SECONDS seconds.\n"

################################################################################
# STEP 1: RUN TOOL
################################################################################

echo "Starting STEP 1: Run GC"

# Define variables
tool_name=GC
outputfolder=${p}/results/${n}${d}/${tool_name}

# Make output directory
[ -d $outputfolder ] && echo "Output directory: ${outputfolder} already exists. Files will be overwritten." || mkdir $outputfolder

# Define variables
samples=$(ls ${p}/results/${n}${d}/foodqcpipeline)
count=$((1))
total=$(wc -w <<<$samples)
tool=${p}/src/misc/calculate_GC_content.py
databases=$(ls ${p}/data/db/tool_db/*/* | grep .name | sed -e "s/\.name$//")

for sample in $samples
  do
    echo "Starting with: $sample ($count/$total)"
    cd ${outputfolder}

    # Define tool inputs
    i=${p}/results/${n}${d}/foodqcpipeline/${sample}/Assemblies/*.fa
    s=$sample
    o=${outputfolder}/GC_content.txt

    # Run tool
    $tool $i $s $o
    echo "Finished with: $sample"
    count=$(($count+1))
  done

echo "Results of GC content were succesfully made."
echo "Time stamp: $SECONDS seconds."

