#!/usr/bin/env bash

# Program: run_template.sh
# Description: This program run tool which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## RunToolTemplate [-p <path to dairy pipeline>] [-n <name of project>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)

# Output:
    ## Outputfile 1
    ## Outputfile 2

# This pipeline consists of 1 steps:
    ## STEP 1:  Run Tool


################################################################################
# GET INPUT
################################################################################

# Load all required modules for the job


# Start timer for logfile
SECONDS=0

# How to use program
usage() { echo "Usage: $0 [-p <path to main>] [-n <name of project>]"; exit 1; }

# Parse flags
while getopts ":p:n:h" opt; do
    case "${opt}" in
        p)
            p=${OPTARG}
            ;;
        n)
            n=${OPTARG}
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
echo "Starting RunToolTemplate ($date)"
echo "-----------------------------------------------"
echo -e "RunToolTemplate is a script to run tool.\n"

# Print files used
echo "Name of project used is: ${n}"
echo "Path used is: ${p}"

echo -e "Time stamp: $SECONDS seconds.\n"

################################################################################
# STEP 1: RUN TOOL
################################################################################

echo "Starting STEP 1: Run Tool"

# Define variables
tool_name=tool
outputfolder=${p}/data/${n}/${tool_name}

# Make output directory
[ -d $outputfolder ] && echo "Output directory: ${outputfolder} already exists. Files will be overwritten." || mkdir $outputfolder

# Define variables
samples=$(ls ${p}/data/${n}/foodqcpipeline)
count=$((1))
total=$(wc -w <<<$samples)
tool=${p}/tools/$tool_name
databases=$(ls ${p}/data/db/tool_db/*/* | grep .name | sed -e "s/\.name$//")

for sample in $samples
  do
    echo "Starting with: $sample ($count/$total)"
    cd ${outputfolder}
    [ -d $sample ] && echo "Output directory: ${sample} already exists. Files will be overwritten." || mkdir $sample
    cd ${sample}

    # Define tool inputs
    option1=optiontext1
    option2=optiontext2
    o=${outputfolder}/${sample}

    # Run tool
    $tool -option1 $option1 -option2 $option2 -o $o
    echo "Finished with: $sample"
    count=$(($count+1))
  done

echo "Results of tool were succesfully made."
echo "Time stamp: $SECONDS seconds."

