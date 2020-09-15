#!/usr/bin/env bash

# Program: RunToolTemplate
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


###########################################################################
# GET INPUT
###########################################################################

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

# Define variables
t=tool
o=${p}/${n}/${t}

# Make output directory
[ -d $o ] && echo "Output directory: ${o} already exists. Files will be overwritten." || mkdir $o

date=$(date "+%Y-%m-%d %H:%M:%S")
echo "Starting RunToolTemplate ($date)"
echo "-----------------------------------------------"
echo -e "RunToolTemplate is a pipeline to run tool.\n"
echo "Get input is done."

# Print files used
echo "Name of project used is ${n}"
echo "Path used is ${p}"

echo -e "Time stamp: $SECONDS seconds.\n"

###########################################################################
# STEP 1: Run Tool
###########################################################################

echo "Starting STEP 1: Run Tool"

samples=$(ls $p/data/foodqcpipeline)
count=$((1))
total=$(wc -w <<<$samples)

mkdir ${p}/data/tool
tool=${p}/tools/tool

for sample in $samples
  do
  echo "Starting with: $sample ($count/$total)"
  cd $p/path/you/want
  mkdir ${sample}
  cd ${sample}
  option1=optiontext1
  option2=optiontext2
  ./path/to/tool/to/run -option1 $option1 -option2 $option2
  echo "Finished with: $sample"
  done

echo "Results of tool were succesfully made."
echo "Time stamp: $SECONDS seconds."

