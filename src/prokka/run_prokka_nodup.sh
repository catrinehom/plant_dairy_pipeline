#!/usr/bin/env bash

# Program: run_prokka.sh
# Description: This program run PROKKA which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_prokka.sh [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run (optional)>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str)

# Output:
    ## gene annotation files

# This pipeline consists of 1 steps:
    ## STEP 1:  Run PROKKA

################################################################################
# GET INPUT
################################################################################

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
echo "Starting run_prokka.sh ($date)"
echo "--------------------------------------------------------------------------------"

# Print files used
echo "Path used is: ${p}"
echo "Results will be saved in: ${n}${d}"

echo -e "Time stamp: $SECONDS seconds.\n"


################################################################################
# STEP 1: RUN PROKKA
################################################################################

# Load modules
module load tools
module load perl
module load ncbi-blast/2.8.1+
module load hmmer/3.2.1
module load aragorn/1.2.36
module load tbl2asn/20191211
module load prodigal/2.6.3
module load infernal/1.1.2
module load barrnap/0.7
module load jdk/15
module load minced/0.2.0
module load rnammer/1.2
module load signalp/4.1c
module load prokka/1.14.0

echo "Starting STEP 1: Run PROKKA"

# Define variables
tool_name=prokka
outputfolder=${p}/results/${n}${d}/$tool_name

# Make output directory
[ -d $outputfolder ] && echo "Output directory: $outputfolder already exists. Files will be overwritten." || mkdir -p $outputfolder


# Define variables
samples_path=${p}/results/${n}${d}/foodqcpipeline
samples=$(ls $samples_path)
count=$((1))
total=$(wc -w <<<$samples)

# Run foodqcpipeline for all samples
for sample in $samples
  do
    sample_path=${outputfolder}/${sample}
    if [ -d $sample_path ] 
    then
        echo "Directory exists."
    else
      echo "Starting with: $sample ($count/$total)"

      # Create sample output folder
      sample_path=${outputfolder}/${sample}
      [ -d $sample_path ] && echo "Output directory: ${sample_path} already exists. Files will be overwritten." || mkdir $sample_path

      # Define tool inputs
      input_fasta=${samples_path}/$sample/Assemblies/*_trimmed.fa

      # Run tool
      prokka --outdir $sample_path --prefix $sample $input_fasta --force

      count=$(($count+1))
    fi
  done

echo "Images of assemblies were succesfully made."
echo "Time stamp: $SECONDS seconds."

