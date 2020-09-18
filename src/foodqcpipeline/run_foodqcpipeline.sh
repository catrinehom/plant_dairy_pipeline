#!/usr/bin/env bash

# Program: run_foodqcpipeline.sh
# Description: This program run foodqcpipeline which is a part of the dairy pipeline
# Version: 1.0
# Author: Catrine Høm and Line Andresen

# Usage:
    ## run_foodqcpipeline.sh [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str)

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
outputfolder=${p}/results/${n}${d}/${t}

# Make output directory
[ -d $outputfolder ] && echo "Output directory: $outputfolder already exists. Files will be overwritten." || mkdir $outputfolder

# Define variables
raw=${p}/data/${n}/raw
samples=$(ls ${raw})
count=$((1))
total=$(wc -w <<<$samples)

#tool=/home/projects/cge/apps/foodqcpipeline/FoodQCPipeline.py
tool=${p}/tools/foodqcpipeline/FoodQCPipeline.py

# Run foodqcpipeline for all samples
for sample in $samples
  do
    echo "Starting with: $sample ($count/$total)"

    # Create sample output folder
    sample_path=${outputfolder}/${sample}
    [ -d $sample_path ] && echo "Output directory: ${sample_path} already exists. Files will be overwritten." || mkdir $sample_path

    # Define tool inputs
    input=${raw}/${sample}/*.gz
    assembly_output=${sample_path}/Assemblies
    qc_output=${sample_path}/QC
    trim_output=${sample_path}/Trimmed
    tmp_dir=${sample_path}/tmp

    # Run tool
    python3 $tool $input --clean_tmp --assembly_output $assembly_output --qc_output $qc_output --trim_output $trim_output --tmp_dir $tmp_dir --spades
    count=$(($count+1))
  done

# TODO: lav så den slutter på et tidspunkt ved evt. fejl
# Check of all assemblies are done
jobs_no=$(echo ${samples} | wc -w)
files_no=0
while [ $jobs_no -ne $files_no ]
  do
    sleep 60s
    #files_no=$(ls -1 ${p}/data/${n}/foodqcpipeline | wc -l)q
    files_no=$(ls ${outputfolder}/*/QC/*.qc.txt  2> /dev/null  | wc -l)
    # if SECONDS2 > inf, runtime error
  done

# Insert header and sample name
for sample in $samples
  do
    # Define paths
    sample_path=${outputfolder}/${sample}
    qc_output=${sample_path}/QC
    # Add sample name to result
    sed -i "1s/^/${sample}\t/" ${qc_output}/*.qc.txt
    # Insert header in files
    sed -i "1s/^/Sample_name\tRead_name\tBases_(MB)\tQual_Bases(MB)\tQual_bases(%)\tReads\tQual_reads(no)\tQual_reads(%)\tMost_common_adapter_(count)\t2._Most_common_adapter_(count)\tOther_adapters_(count)\tinsert_size\tN50\tno_ctgs\tlongest_size(bp)\ttotal_bps\n/" ${qc_output}/*.qc.txt
  done


echo "Results of foodqcpipeline were succesfully made."
echo "Time stamp: $SECONDS seconds."

