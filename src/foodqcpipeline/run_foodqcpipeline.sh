#!/usr/bin/env bash

# Program: run_foodqcpipeline.sh
# Description: This program run foodqcpipeline which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_foodqcpipeline.sh [-p <path to dairy pipeline>] [-n <name of project>] [-f <folder name>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -f, folder name with raw files

# Output:
    ## Trimmed directory: For each sample there exists 2 trimmed fastq files
    # (1 if single-end), along with a file containing discarded reads, and if
    # paired-end a file containing reads that could not be paired.
    ## Assembly directory An assembly in FASTA format for each WGS sample.
    # The assembly only contains contigs greater thean 500 bp.
    # For each assembly exists a directory with the details of the assembly.
    ## QC directory: For each sample there exists a single line text file,
    # with all the QC information.

# This pipeline consists of 1 steps:
    ## STEP 1:  Run foodqcpipeline

################################################################################
# GET INPUT
################################################################################

# Start timer for logfile
SECONDS=0

# How to use program
usage() { echo "Usage: $0 [-p <path to main>] [-n <name of project>] [-f <folder name>]"; exit 1; }

# Parse flags
while getopts ":p:n:f:h" opt; do
    case "${opt}" in
        p)
            p=${OPTARG}
            ;;
        n)
            n=${OPTARG}
            ;;
        f)
            f=${OPTARG}
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
echo "Starting foodqcpipeline_run.sh ($date)"
echo "-----------------------------------------------"
echo -e "foodqcpipeline_run.sh is a pipeline to run foodqcpipeline.\n"
echo "Get input is done."

# Print files used
echo "Name of project used is ${n}"
echo "Path used is ${p}"

echo -e "Time stamp: $SECONDS seconds.\n"


################################################################################
# STEP 1: RUN FOODQCPIPELINE
################################################################################

echo "Starting STEP 1: Run foodqcpipeline"

# Define variables
t=foodqcpipeline
o=${p}/data/${n}/${t}

# Make output directory
[ -d $o ] && echo "Output directory: ${o} already exists. Files will be overwritten." || mkdir $o

# Define variables
samples=$(ls ${p}/data/${n}/raw/${f})
count=$((1))
total=$(wc -w <<<$samples)

#tool=/home/projects/cge/apps/foodqcpipeline/FoodQCPipeline.py
tool=${p}/tools/foodqcpipeline/FoodQCPipeline.py

# Run foodqcpipeline for all samples
for sample in $samples
  do
    echo "Starting with: $sample ($count/$total)"
    cd ${p}/data/${n}/foodqcpipeline
    mkdir ${sample}
    cd ${sample}
    input=${p}/data/${n}/raw/${f}/${sample}/*.gz
    assembly_output=${p}/data/${n}/foodqcpipeline/${sample}/Assemblies
    qc_output=${p}/data/${n}/foodqcpipeline/${sample}/QC
    trim_output=${p}/data/${n}/foodqcpipeline/${sample}/Trimmed
    python3 $tool $input --clean_tmp --assembly_output $assembly_output --qc_output $qc_output --trim_output $trim_output --spades
    count=$(($count+1))
  done

# TODO: lav så den slutter på et tidspunkt ved evt. fejl
# Check of all assemblies are done
jobs_no=$(echo $samples | wc -w)
files_no=0
while [ $jobs_no -ne $files_no ]
  do
    sleep 60s
    #files_no=$(ls -1 ${p}/data/${n}/foodqcpipeline | wc -l)q
    files_no=$(ls ${p}/data/${n}/foodqcpipeline/*/Assemblies/*.fa  2> /dev/null  | wc -l)
    # if SECONDS2 > inf, runtime error
  done

for sample in $samples
  do
    qc_output=${p}/data/${n}/foodqcpipeline/${sample}/QC
    # Insert header in file
    sed -i '1s/^/Sample\tBases_(MB)\tQual_Bases(MB)\tQual_bases(%)\tReads\tQual_reads(no)\tQual_reads(%)\tMost_common_adapter_(count)\t2._Most_common_adapter_(count)\tOther_adapters_(count)\tinsert_size\tN50\tno_ctgs\tlongest_size(bp)\ttotal_bps\n/' ${qc_output}/*.qc.txt
    echo "Finished with: $sample"
  done

echo "Results of foodqcpipeline were succesfully made."
echo "Time stamp: $SECONDS seconds."

