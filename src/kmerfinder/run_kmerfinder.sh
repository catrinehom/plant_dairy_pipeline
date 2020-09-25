#!/usr/bin/env bash

# Program: run_kmerfinder.sh
# Description: This program run kmerfinder which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_kmerfinder.sh [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run (optional)>]
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
usage() { echo "Usage: $0 [-p <path to main>] [-n <name of project>] [-d <date of run>]"; exit 1; }

# Default values
d=$(date "+_%Y%m%d_%H%M%S")

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
            d=_${OPTARG}
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
echo "--------------------------------------------------------------------------------"

# Print files used
echo "Path used is: ${p}"
echo "Results will be saved: ${n}${d}"

echo -e "Time stamp: $SECONDS seconds.\n"


################################################################################
# STEP 1: Run KmerFinder
################################################################################

echo "Starting STEP 1: Run KmerFinder"

# Define variables
tool_name=kmerfinder
outputfolder=${p}/results/${n}${d}/${tool_name}

# Make output directory
[ -d $outputfolder ] && echo "Output directory: ${outputfolder} already exists. Files will be overwritten." || mkdir $outputfolder

# Define variables
samples=$(ls ${p}/results/${n}${d}/foodqcpipeline)
count=$((1))
total=$(wc -w <<<$samples)
tool=${p}/tools/${tool_name}/kmerfinder.py
databases=$(ls ${p}/data/db/${tool_name}/*/* | grep .name | sed -e 's/\.name$//')

# Run tool on all samples
for sample in $samples
  do
  echo  "Starting with: $sample ($count/$total)"

  # Create sample output folder
  sample_path=${outputfolder}/${sample}
  [ -d $sample_path ] && echo "Output directory: ${sample_path} already exists. Files will be overwritten." || mkdir $sample_path

  for database in $databases
    do
      # Define tool inputs
      i=$p/results/${n}${d}/foodqcpipeline/${sample}/Trimmed/*.trim.fq.gz
      t=$(echo $database | cut -f1 -d'.')
      tax=${t}.tax

      # Run tool
      $tool -db $database -i $i -o $sample_path -tax $tax -x -q
      db_name=$(basename $t)
      # Move result for each database, so it wont overwrite it
      mv ${sample_path}/results.txt ${sample_path}/${db_name}_results.txt
    done
  echo -e "Finished with $sample.\n"
  count=$(($count+1))
  done

echo "Results of KmerFinder were succesfully made."
echo "Time stamp: $SECONDS seconds."


