#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Program: error_handling.py
Description: This program checks the input format of the files neccesary for a tool to run.
Version: 1.0
Author: Catrine Høm and Line Andresen

# Usage:
    ## error_handling.py [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run>] [-i <input file type for your tool (fastq, fasta, gfa, or gff)>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str)
    ## -i, input file type for your tool (raw, fastq, fasta, gfa, or gff) (str)


# This pipeline consists of 1 steps:
    ## STEP 1:  ERROR HANDLING
"""

# Import libraries
import sys
import os
import gzip
from argparse import ArgumentParser

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

def CheckFasta(filenames):
    """
    This function checks if all the input files (list) are in fasta format.
    Outputs a dict of True/False for each file.
    """
    fasta_status = dict()
    fasta_type = b">"

    # Open file and get the first character
    for infile in filenames:
        f = OpenFile(infile, "rb")
        first_char = f.read(1);
        f.close()
        # Check if fasta
        if first_char == fasta_type:
            fasta_status[infile] = True
        else:
            fasta_status[infile] = False
    return fasta_status

def CheckGfa(filenames):
    """
    This function checks if all the input files (list) are in fasta format.
    Outputs a dict of True/False for each file.
    """
    gfa_status = dict()
    gfa_type = b"S"

    # Open file and get the first character
    for infile in filenames:
        f = OpenFile(infile, "rb")
        first_char = f.read(1);
        f.close()
        # Check if fasta
        if first_char == gfa_type:
            gfa_status[infile] = True
        else:
            gfa_status[infile] = False
    return gfa_status

def CheckGff(filenames):
    """
    This function checks if all the input files (list) are in fasta format.
    Outputs a dict of True/False for each file.
    """
    gff_status = dict()
    gff_type = b"##"

    # Open file and get the first character
    for infile in filenames:
        f = OpenFile(infile, "rb")
        first_char = f.read(2);
        f.close()
        # Check if fasta
        if first_char == gff_type:
            gff_status[infile] = True
        else:
            gff_status[infile] = False
    return gff_status

################################################################################
# GET INPUT
################################################################################

if __name__ == "__main__":
    # Parse input from command line
    parser = ArgumentParser()
    parser.add_argument("-p", dest="p", help="path to main folder", required=True, type=str)
    parser.add_argument("-n", dest="n", help="name of project", required=True, type=str)
    parser.add_argument("-d", dest="d", help="date of run", required=True)
    parser.add_argument("-i", dest="i", help="input file type for your tool (fastq, fasta, gfa, or gff)", required=True, type=str)
    args = parser.parse_args()

    # Define input as variables
    main_path = args.p
    project_name = args.n
    date = str(args.d)
    input_type = args.i.lower()

    # Check input type
    accepted_input_types = ["raw","fastq", "fasta", "gfa", "gff"]
    if input_type not in accepted_input_types:
        print("Error! Uknown input file format. Should be fastq, fasta, gfa, or gff.")
        sys.exit()

################################################################################
# STEP 1:  ERROR HANDLING
################################################################################

# Make tmp directory for output file
tmp_path = main_path + "/results/" + project_name + "_" + date + "/tmp/"
if not os.path.exists(tmp_path):
    os.mkdir(tmp_path)

# Define tmp output file
tmp_filename = tmp_path + "{}_approved.txt".format(input_type)

# Open file to write output
tmp_outfile = open(tmp_filename, "w")

### For fastq format files
if input_type == "raw":

    # Define raw folder path
    raw_path = main_path + "/data/" + project_name + "/raw/"

    # Find all sample folders
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
            tmp_outfile.write(sample+"\n")
### For fasta format files
elif input_type == "fastq":

    # Define samples path
    samples_path = main_path + "/results/" + project_name + "_" + date + "/foodqcpipeline/"

    # Find all sample folders
    samples_folders = [folder for folder in os.listdir(samples_path) if os.path.isdir(os.path.join(samples_path, folder))]

    # For all samples
    for sample in samples_folders:

        # Define assembly folder for each sample
        assembly_folder = samples_path + sample + "/Trimmed/"

        # List files of assemblies
        potential_fastqs = [file for file in os.listdir(assembly_folder) if not os.path.isdir(os.path.join(assembly_folder, file)) if file.endswith(".trim.fq.gz")]

        # Add full path
        potential_fastqs = [assembly_folder + "/" + file for file in potential_fastqs]

        # Check of the content of the assembly folder is fasta
        fastq_status = CheckFastq(potential_fastqs)

        # Count how many fasta was found
        no_fastq = sum(1 for condition_true in fastq_status.values() if condition_true)

        # Print error messages
        if no_fastq > 2:
            print("{} has more than one file that evaluate as true for fastq format: {}! This sample will not be included in the following analysis.".format(sample, fastq_status))
        elif no_fastq == 0:
            print("{} has no fastq file! This sample will not be included in the following analysis.".format(sample))

        # Write accepted samples to file
        if no_fastq > 1:
            tmp_outfile.write(sample+"\n")

### For fasta format files
elif input_type == "fasta":

    # Define samples path
    samples_path = main_path + "/results/" + project_name + "_" + date + "/foodqcpipeline/"

    # Find all sample folders
    samples_folders = [folder for folder in os.listdir(samples_path) if os.path.isdir(os.path.join(samples_path, folder))]

    # For all samples
    for sample in samples_folders:

        # Define assembly folder for each sample
        assembly_folder = samples_path + sample + "/Assemblies/"

        # List files of assemblies
        potential_fastas = [file for file in os.listdir(assembly_folder) if not os.path.isdir(os.path.join(assembly_folder, file))]

        # Add full path
        potential_fastas = [assembly_folder + "/" + file for file in potential_fastas]

        # Check of the content of the assembly folder is fasta
        fasta_status = CheckFasta(potential_fastas)

        # Count how many fasta was found
        no_fasta = sum(1 for condition_true in fasta_status.values() if condition_true)

        # Print error messages
        if no_fasta > 1:
            print("{} has more than one file that evaluate as true for fasta format: {}! This sample will not be included in the following analysis.".format(sample, fasta_status))
        elif no_fasta == 0:
            print("{} has no fasta file! This sample will not be included in the following analysis.".format(sample))

        # Write accepted samples to file
        if no_fasta == 1:
            tmp_outfile.write(sample+"\n")

### For gfa files
elif input_type == "gfa":

    # Define sample folder path
    samples_path = main_path + "/results/" + project_name + "_" + date + "/foodqcpipeline/"

    # Find all sample folders
    samples_folders = [folder for folder in os.listdir(samples_path) if os.path.isdir(os.path.join(samples_path, folder))]


    # Check all samples if they have assemblies
    for sample in samples_folders:

        # Define assembly folder for each sample
        assembly_folder = samples_path + sample + "/Assemblies/"

        # List folders of assembly (exclude files)
        potential_folders = [folder for folder in os.listdir(assembly_folder) if os.path.isdir(os.path.join(assembly_folder, folder))]

        # Find the "_trimmed folder"
        for folder in potential_folders:
            if not folder.endswith("corrected_reads"):

                # Add full path
                trimmed_folder = assembly_folder + "/" + folder

                # Find files in _trimmed folder (exclude folders)
                potential_gfa = [file for file in os.listdir(trimmed_folder) if not os.path.isdir(os.path.join(trimmed_folder, file))]

                # Add full path
                potential_gfa = [trimmed_folder + "/" + file for file in potential_gfa]

                # Check of the content of the trimmed_folder is gff
                gfa_status = CheckGfa(potential_gfa)

                # Count how many gff was found
                no_gfa = sum(1 for condition_true in gfa_status.values() if condition_true)

                # Print error messages
                if no_gfa > 1:
                    print("{} has more than one file that evaluate as true for gfa format: {}! This sample will not be included in the following analysis.".format(sample, gfa_status))
                elif no_gfa == 0:
                    print("{} has no gfa file! This sample will not be included in the following analysis.".format(sample))

                # Write accepted samples to file
                if no_gfa == 1:
                    tmp_outfile.write(sample+"\n")


### For gff files
elif input_type == "gff":
    # Define sample folder path
    samples_path = main_path + "/results/" + project_name + "_" + date + "/prokka/"

    # Find all sample folders
    samples_folders = [folder for folder in os.listdir(samples_path) if os.path.isdir(os.path.join(samples_path, folder))]

    # Check all samples if they have assemblies
    for sample in samples_folders:

        # Add full path to sample folder
        sample_folder = samples_path + sample

        # List content of assembly (exclude folders)
        potential_gff = [file for file in os.listdir(sample_folder) if not os.path.isdir(os.path.join(sample_folder, file))]

        # Add full path to files
        potential_gff = [sample_folder + "/" + file for file in potential_gff]

        # Check of the content of the sample_folder is gff
        gff_status = CheckGff(potential_gff)

        # Count how many gff was found
        no_gff = sum(1 for condition_true in gff_status.values() if condition_true)

        # Print error messages
        if no_gff > 1:
            print("{} has more than one file that evaluate as true for gff format: {}! This sample will not be included in the following analysis.".format(sample, gff_status))

        elif no_gff == 0:
            print("{} has no gff file! This sample will not be included in the following analysis.".format(sample))

        # Write accepted samples to file
        if no_gff == 1:
            tmp_outfile.write(sample+"\n")

# Close output file
tmp_outfile.close()

