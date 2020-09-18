#!/usr/bin/env bash

# Program: run_resfinder.sh
# Description: This program run ResFinder which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_resfinder.sh [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str or int)

# Output:
    ## Outputfile 1
    ## Outputfile 2

# This pipeline consists of 1 steps:
    ## STEP 1:  Run ResFinder


################################################################################
# GET INPUT
################################################################################

# Load all required modules for the job
module load tools
module load anaconda3/4.4.0
module load anaconda2/2.2.0
module load kma/1.2.11
module unload mgmapper metabat fastqc
module unload ncbi-blast perl
source /home/projects/cge/apps/env/rf4_env/bin/activate
module load perl
module load ncbi-blast/2.8.1+

# Start timer for logfile
SECONDS=0

# How to use program
usage() { echo "Usage: $0 [-p <path to main>] [-n <name of project>] [-d <date of run>]"; exit 1; }

# Parse flags
while getopts ":p:n:d:h" opt; do
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
echo "Starting run_resfinder ($date)"
echo "-----------------------------------------------"
echo -e "run_resfinder is a script to run ResFinder.\n"

# Print files used
echo "Name of project used is: ${n}"
echo "Path used is: ${p}"

echo -e "Time stamp: $SECONDS seconds.\n"

################################################################################
# STEP 1: RUN RESFINDER
################################################################################

echo "Starting STEP 1: Run ResFinder"

# Define variables
tool_name=resfinder
outputfolder=${p}/results/${n}${d}/${tool_name}

# Make output directory
[ -d $outputfolder ] && echo "Output directory: ${outputfolder} already exists. Files will be overwritten." || mkdir $outputfolder

# Define variables
samples=$(ls ${p}/results/${n}${d}/foodqcpipeline)
count=$((1))
total=$(wc -w <<<$samples)
#tool=${p}/tools/${tool_name}/run_resfinder.py
tool=/home/projects/cge/apps/resfinder/resfinder/run_resfinder.py
db_res=${p}/data/db/resfinder_db
#db_point=${p}/data/db/pointfinder_db

# Run tool on all samples
for sample in $samples
  do
  echo  "Starting with: $sample ($count/$total)"

  # Create sample output folder
  sample_path=${outputfolder}/${sample}
  [ -d $sample_path ] && echo "Output directory: ${sample_path} already exists. Files will be overwritten." || mkdir $sample_path

  # Define tool inputs
  ifq=$p/results/${n}${d}/foodqcpipeline/${sample}/Trimmed/*.trim.fq.gz
  #ifa=${sample_path}/Assemblies/*.fa

  # Run tool
  $tool -ifq $ifq -o $sample_path -db_res $db_res -acq
  #$tool -ifa $ifa -o $sample_path -db_res $db_res -acq

  echo -e "Finished with $sample.\n"
  count=$(($count+1))
  done

echo "Results of ResFinder were succesfully made."
echo "Time stamp: $SECONDS seconds."


