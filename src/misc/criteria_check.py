#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Program: criteria_check.py
Description: This program checks for qc criteria and species criteria
Version: 2.0
Author: Catrine Høm and Line Andresen

# Usage:
    ## error_handling.py [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run>] [-i <input file type for your tool (fastq, fasta, gfa, or gff)>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str)
    ## -i, check type, qc, lab, roary (str)


# This pipeline consists of 4 parts:
    ## PART 1:  Raw file check
    ## PART 2:  Quality Control
    ## PART 3:  Species Selection
    ## PART 4:  Roary Group Selection
"""
import sys
import gzip
import pandas as pd
from argparse import ArgumentParser
import os

################################################################################
# GET INPUT
################################################################################

if __name__ == "__main__":
    # Parse input from command line
    parser = ArgumentParser()
    parser.add_argument("-p", dest="p", help="path to main folder", required=True, type=str)
    parser.add_argument("-n", dest="n", help="name of project", required=True, type=str)
    parser.add_argument("-d", dest="d", help="date of run", required=True)
    parser.add_argument("-t", dest="t", help="check needed (QC, LAB, roary", required=True, type=str)
    args = parser.parse_args()

    # Define input as variables
    main_path = args.p
    project_name = args.n
    date = str(args.d)
    check_type = args.t.lower()

    # Check check type
    accepted_check_types = ["raw","qc","lab","roary"]
    if check_type not in accepted_check_types:
        print("Error! Uknown check requested, possible checks are QC, LAB or roary.")
        sys.exit()


summary_path = main_path + "/results/" + project_name + "_" + date + "/summary/"
outfile_path = main_path + "/results/" + project_name + "_" + date + "/tmp/"
LAB_file     = main_path + "/data/db/qps_lab/species_list.txt"

if not os.path.exists(outfile_path):
    os.mkdir(outfile_path)

################################################################################
# FUNCTIONS
################################################################################

def CheckGZip(filename):
    """
    This function checks if the input file is gzipped.
    """
    gzipped_type = b"\x1f\x8b"

    infile = open(filename,"rb")
    filetype = infile.read(2)
    infile.close()
    if filetype == gzipped_type:
        return True
    else:
        return False

def OpenFile(filename,mode):
    """
    This function opens the input file in chosen mode.
    """
    try:
        if CheckGZip(filename):
            infile = gzip.open(filename,mode)
        else:
            infile = open(filename,mode)
    except IOError as error:
        sys.exit("Can't open file, reason: {} \n".format(error))
    return infile

def CheckFastq(filenames):
    """
    This function checks if all input files (list) are in fastq format.
    Outputs a dict of True/False for each file.
    """
    fastq_status = dict()
    fastq_type = b"@"

    # Open all files and get the first character
    for filename in filenames:
        infile = OpenFile(filename, "rb")
        first_char = infile.read(1);
        infile.close()
        # Check if fastq
        if first_char == fastq_type:
            fastq_status[infile] = True
        else:
            fastq_status[infile] = False
    return fastq_status

################################################################################
# PART 1:  Check of raw files
################################################################################

if check_type == "raw":
    approved_file = outfile_path + 'raw_approved.txt'
    outfile = open(approved_file, "w")
    
    # Define raw folder path and find all sample folders
    raw_path = main_path + "/data/" + project_name + "/raw/"
    samples_folders = [folder for folder in os.listdir(raw_path) if os.path.isdir(os.path.join(raw_path,folder))]

    # For every sample
    for sample in samples_folders:

        # Define sample path
        sample_path = raw_path + sample + "/"

        # Get files of each sample folder (exclude folders)
        potential_fastq = [file for file in os.listdir(sample_path) if not os.path.isdir(os.path.join(sample_path, file))]

        # Add full path to content of sample folder
        potential_fastqs = [sample_path + file for file in potential_fastq]

        # Check if the content of the folder is fastq
        fastq_status = CheckFastq(potential_fastqs)

        # Count how many fastq files there is for this sample
        no_fastq = sum(1 for condition_true in fastq_status.values() if condition_true)

        # Print error messages
        if no_fastq > 2:
            print("{} has more than two files that evaluate true for fastq format: {}! However, the pipeline will continue with this sample anyway.".format(sample, fastq_status))
        elif no_fastq == 1:
            print("{} only has one fastq file! However, the pipeline will continue with this sample anyway.".format(sample))
        elif no_fastq == 0:
            print("{} has no fastq file! This sample will not be included in any further analysis.".format(sample))

        # Write accepted samples to file
        if no_fastq > 0:
            outfile.write(sample+"\n")
    outfile.close()

################################################################################
# PART 2:  Quality Control
################################################################################

if check_type == "qc":
    qc_file = summary_path + 'foodqcpipeline_results.txt'
    approved_file = outfile_path + 'qc_approved.txt'

    # Criteria
    reads   = 500000
    bases   = 50
    N50     = 50000
    contigs = 150
    
    # Validate Reads, bases, N50 and contigs
    df = (pd.read_csv(qc_file, sep='\t', index_col=False, usecols=['Sample_name', 'Qual_bases(%)', 'Reads', 'N50', 'no_ctgs', 'total_bps'])).set_index('Sample_name') 
    df['Qual_bases(%)']=df['Qual_bases(%)'].str.split('%').str[0].astype(float)
    df = df[df['Reads'] >= reads]
    df = df[df['Qual_bases(%)'] >= bases]
    df = df[df['N50'] >= N50]
    df = df[df['no_ctgs'] <= contigs]
    
    approved = list(df.index)

    outfile = open(approved_file, "w")
    for sample in approved:
        outfile.write(sample+"\n")
    outfile.close()
        
################################################################################
# PART 3:  Species selection
################################################################################

if check_type == "lab":
    kmerfinder_file = summary_path + "kmerfinder_results_top1.txt"
    approved_file = outfile_path + 'species_approved.txt'
    
    # Criteria
    with open(LAB_file) as f:
        LAB = f.read().splitlines()

    # Validate correct species
    df = (pd.read_csv(kmerfinder_file, sep='\t', index_col=False, usecols=['Sample_name',"Species"])).set_index('Sample_name') 
    df = df[df['Species'].isin(LAB)]
    
    approved = list(df.index)

    outfile = open(approved_file, "w")
    for sample in approved:
        outfile.write(sample+"\n")
    outfile.close()
    
################################################################################
# PART 4:  Species for Roary
################################################################################

if check_type == "roary":
    kmerfinder_file = summary_path + "kmerfinder_results_top1.txt"
    approved_file = outfile_path + 'species_approved.txt'

    # Criteria
    with open(LAB_file) as f:
        LAB = f.read().splitlines()
        
    # Validate correct species
    df = (pd.read_csv(kmerfinder_file, sep='\t', index_col=False, usecols=['Sample_name',"Species"])).set_index('Sample_name') 
    df['Genus'] = df['Species'].str.split(' ').str[0]
    df = df[df['Species'].isin(LAB)]
    
    os.mkdir(outfile_path + 'genus')
    os.mkdir(outfile_path + 'species')
    
    listofgenuses = df['Genus'].unique()
    for genus in listofgenuses:
        genusname = genus.replace(' ','_')
        approved_file = outfile_path + f'genus/{genusname}.txt'
        IDs = df[df['Genus']==genus]
        approved = list(IDs.index)
        
        outfile = open(approved_file, 'w')
        for sample in approved:
            outfile.write(sample+"\n")
        outfile.close()

        listofspecies = df['Species'].unique()
        for species in listofspecies:
            speciesname = species.replace(' ','_')
            approved_file = outfile_path + f'species/{speciesname}.txt'
            IDs = df[df['Species']==species]
            approved = list(IDs.index)
            
            outfile = open(approved_file, 'w')
            for sample in approved:
                outfile.write(sample+"\n")
            outfile.close()
