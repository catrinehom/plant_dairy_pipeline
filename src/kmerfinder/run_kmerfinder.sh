#!/usr/bin/env bash

# Program: run_kmerfinder.sh
# Description: This program run kmerfinder which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_kmerfinder.sh [-p <path to dairy pipeline>] [-n <name of project>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)

# Output:
    ## Each sample will have results file under project_name/kmerfinder/sample_name
    # the results are split in each database name

# This pipeline consists of 1 steps:
    ## STEP 1:  Run KmerFinder

###########################################################################
# GET INPUT
###########################################################################

# Load all required modules for the job
module load tools
module load anaconda2/4.0.0
module load SPAdes/3.9.0
module load perl
module load ncbi-blast/2.2.26
module load cgepipeline/20180109
module load kma/1.2.11

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
echo "Starting kmerfinder_run.sh ($date)"
echo "-----------------------------------------------"
echo -e "kmerfinder_run is a tool to run kmerfinder.\n"
echo "Get input is done."

# Print files used
echo "Name of project used is ${n}"
echo "Path used is ${p}"

echo -e "Time stamp: $SECONDS seconds.\n"


################################################################################
# STEP 1: Run KmerFinder
################################################################################

echo "Starting STEP 1: Run KmerFinder"

# Define variables
tool_name=kmerfinder
outputfolder=${p}/results/${n}/${tool_name}

# Make output directory
[ -d $outputfolder ] && echo "Output directory: ${outputfolder} already exists. Files will be overwritten." || mkdir $outputfolder

# Define variables
samples=$(ls ${p}/data/${n}/foodqcpipeline)
count=$((1))
total=$(wc -w <<<$samples)
tool=${p}/tools/${tool_name}/kmerfinder.py
databases=$(ls ${p}/data/db/kmerfinder_db/*/* | grep .name | sed -e 's/\.name$//')


count=$((1))

for sample in $samples
  do
  echo  "Starting with: $sample ($count/$total)"
  cd ${p}/results/${n}/${tool_name}
  mkdir ${sample}
  cd ${sample}

  for database in $databases
    do
      # Define tool inputs
      i=${p}/data/${n}/foodqcpipeline/${sample}/Trimmed/*.trim.fq.gz
      o=${p}/results/${n}/kmerfinder/${sample}
      t=$(echo $database | cut -f1 -d'.')
      tax=${t}.tax

      # Run tool
      $tool -db $database -i $i -o $o -tax $tax -x -q
      db_name=$(basename $t)
      # Move result for each database, so it wont overwrite it
      mv ${p}/results/${n}/kmerfinder/${sample}/results.txt ${p}/results/${n}/kmerfinder/${sample}/${db_name}_results.txt
    done
  echo -e "Finished with $sample.\n"
  count=$(($count+1))
  done

echo "Results of KmerFinder were succesfully made."
echo "Time stamp: $SECONDS seconds."

