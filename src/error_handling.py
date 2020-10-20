#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Program: error_handling.py
Description: This program checks
Version: 1.0
Author: Catrine Høm and Line Andresen

# Usage:
    ## error_handling.py [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run>] [-i <input file type for your tool (fastq, fasta, gfa, or gff)>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str)
    ## -i, input file type for your tool (fastq, fasta, gfa, or gff) (str)


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
    Outputs a list of True/False for each file.
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
    Outputs a list of True/False for each file.
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
            fasta_status[infile] = True
    return fasta_status

def CheckGfa(filenames):
    """
    This function checks if all the input files (list) are in fasta format.
    Outputs a list of True/False for each file.
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
            gfa_status[infile] = True
    return gfa_status

def CheckGff(filenames):
    """
    This function checks if all the input files (list) are in fasta format.
    Outputs a list of True/False for each file.
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
            gff_status[infile] = True
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
    parser.add_argument("-i", dest="i", help="input file type for your tool (fastq, fasta, gfa, or gff)", required=True, type=str))
    args = parser.parse_args()

    # Define input as variables
    main_path = args.p
    project_name = args.n
    date = "_" + str(args.d)
    input_type = args.i.lower()

################################################################################
# STEP 1:  ERROR HANDLING
################################################################################

# Make tmp DIR
tmp_path = main_path + "/results/" + project_name + date + "/tmp/"
if not os.path.exists(tmp_path):
    os.mkdir(tmp_path)

# Define tmp file
tmp_filename = tmp_path + "{}_approved.txt".format(input_type)

if not os.path.exists(tmp_filename):
    tmp_outfile = open(tmp_filename, "w")

    ### For fastq files
    if input_type == "fastq":

        # Define fastq folder path
        fastq_folders_path = main_path + "/data/" + project_name + "/raw/"

        # Find all fastq folders
        fastq_folders = [f for f in os.listdir(fastq_folders_path) if os.path.isdir(os.path.join(fastq_folders_path,f))]

        for folder in fastq_folders:
            fastq_files = [f for f in os.listdir(fastq_folders_path + folder)]

            # Add full path
            fastq_files = [fastq_folders_path + folder + "/" + file for file in fastq_files]

            fastq_status = CheckFastq(fastq_files)

            no_fastq = sum(1 for condition_true in fastq_status.values() if condition_true)

            # Print error messages
            if no_fastq == 1:
                print("{} only has one fastq file! However, the pipeline will continue with this sample anyway.".format(folder))
            elif no_fastq == 0:
                print("{} has no fastq file! This sample will not be included in any further analysis.".format(folder))

            # Write accepted samples to file
            if no_fastq > 0:
                tmp_outfile.write(folder+"\n")

        ### For fastq files
        if input_type == "fasta":
            # Define sample folder path
            sample_folders_path = main_path + "/results/" + project_name + date + "/foodqcpipeline/"

            # Find all sample folders
            sample_folders = [f for f in os.listdir(fastq_folders_path) if os.path.isdir(os.path.join(sample_folders_path,f))]

            # Check all samples if they have assemblies
            for sample in sample_folders:
                # Define assembly folder for each sample
                sample_folder = sample_folders_path + sample + "/Assembly/"

                # List content of assembly
                potential_fastas = [f for f in os.listdir(sample_folder)]

                # Check of the content of the assembly folder is fasta
                fasta_status = CheckFasta(potential_fastas)

                # Count how many fasta was found
                no_fasta = sum(1 for condition_true in fastq_status.values() if condition_true)

                # Print error messages
                if no_fasta > 1:
                    print("{} only has more than one fasta file as assembly! This sample will not be included in the following analysis.".format(folder))
                elif no_fasta == 0:
                    print("{} has no fasta file! This sample will not be included in the following analysis.".format(folder))

                # Write accepted samples to file
                if no_fasta == 1:
                    tmp_outfile.write(folder+"\n")

        ### For gfa files
        if input_type == "gfa":
            # Define sample folder path
            sample_folders_path = main_path + "/results/" + project_name + date + "/foodqcpipeline/"

            # Find all sample folders
            sample_folders = [f for f in os.listdir(sample_folders_path) if os.path.isdir(os.path.join(sample_folders_path,f))]

            # Check all samples if they have assemblies
            for sample in sample_folders:
                # Define assembly folder for each sample
                sample_folder = sample_folders_path + sample + "/Assembly/"

                # List content of assembly
                potential_folders = [f for f in os.listdir(sample_folder)]

                # Find the "_trimmed folder"
                for folder in potential_folders:
                    if folder.endswith("_trimmed"):
                        # Check of the content of the assembly folder is gff
                        gfa_status = CheckGfa(potential_fastas)

                        # Count how many gff was found
                        no_gfa = sum(1 for condition_true in gfa_status.values() if condition_true)

                        # Print error messages
                        if no_gfa > 1:
                            print("{} only has more than one gfa file as assembly! This sample will not be included in the following analysis.".format(folder))
                        elif no_gfa == 0:
                            print("{} has no gfa file! This sample will not be included in the following analysis.".format(folder))

                        # Write accepted samples to file
                        if no_gfa == 1:
                            tmp_outfile.write(folder+"\n")


        ### For gff files
        if input_type == "gff":
            # Define sample folder path
            sample_folders_path = main_path + "/results/" + project_name + date + "/prokka/"

            # Find all sample folders
            sample_folders = [f for f in os.listdir(sample_folders_path) if os.path.isdir(os.path.join(sample_folders_path,f))]

            # Check all samples if they have assemblies
            for sample in sample_folders:
                # Define assembly folder for each sample
                sample_folder = sample_folders_path + sample

                # List content of assembly
                potential_gff = [f for f in os.listdir(sample_folder)]

                gff_status = CheckGff(potential_gff)

                # Count how many fasta was found
                no_gff = sum(1 for condition_true in fastq_status.values() if condition_true)

                # Print error messages
                if no_gff > 1:
                    print("{} has {} gff files! This sample will not be included in the following analysis.".format(folder, no_gff))
                elif no_gff == 0:
                    print("{} has no gfa file! This sample will not be included in the following analysis.".format(folder))

                # Write accepted samples to file
                if no_gff == 1:
                    tmp_outfile.write(folder+"\n")

        else:
            print("Error! Uknown input file format. Should be fastq, fasta, gfa, or gff.")
            sys.exit()

# Close output file
tmp_outfile.close()

