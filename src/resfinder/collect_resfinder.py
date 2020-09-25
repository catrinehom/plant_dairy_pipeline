#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Program: collect_resfinder.py
Description: This program collect the results from all samples made from ResFinder
Version: 1.0
Author: Catrine Høm and Line Andresen

# Usage:
    ## collect_resfinder.py [-p <path to dairy pipeline>] [-n <name of project>] [-d <date of run>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str or int)

# Output:
    ## XXXOutputfile 1
    ## XXXOutputfile 2

# This pipeline consists of 1 steps:
    ## STEP 1:  Collect results
"""
# Import libraries
import sys
import os
from argparse import ArgumentParser


################################################################################
# GET INPUT
################################################################################

if __name__ == "__main__":
    # Parse input from command line
    parser = ArgumentParser()
    parser.add_argument("-p", dest="p", help="path to main folder", required=True, type=str)
    parser.add_argument("-n", dest="n", help="name of project", required=True, type=str)
    parser.add_argument("-d", dest="d", help="date of run", required=True)
    args = parser.parse_args()

    # Define input as variables
    main_path = args.p
    project_name = args.n
    date = "_" + str(args.d)

################################################################################
# STEP 1:  COLLECT RESULTS
################################################################################

    # Define variables
    samples = [f for f in os.listdir(main_path + "/results/" + project_name + date + "/foodqcpipeline")]
    raw_results_outfolder = main_path + "/results/" + project_name + date + "/summary/"
    raw_results_outfile = raw_results_outfolder + "resfinder_results.txt"
    lines = list()
    header_made = False

    # Create outputfolder if it doesn't exist
    if not os.path.exists(raw_results_outfolder):
        os.makedirs(raw_results_outfolder)

    # Loop through samples
    print("Start collecting results in one common file for all samples...")
    for sample in samples:
        # Define path for each sample
        sample_path = main_path + "/results/" + project_name + date + "/resfinder/" + sample + "/"

        # Find file in path
        kmerfinder_files = [f for f in os.listdir(sample_path) if os.path.isfile(os.path.join(sample_path, f))]

        # Find resfinder result files
        for file in kmerfinder_files:
            if file == ("results_tab.txt"):

                # Define path for each sample
                sample_result = sample_path + file

                # Open file
                with open(sample_result, "r") as f:
                    # If this is the first sample, we want to create a header
                    if header_made == False:
                            lines.append("Sample_name\t"+f.readline())
                            header_made = True

                            # Collect results in first sample
                            for line in f:
                                    lines.append(sample+"\t"+line)
                    else:
                        # Skip header in rest of the samples
                        next(f)
                        # Collect results
                        for line in f:
                                lines.append(sample+"\t"+line)
    print("Done")

    # Write raw results to file
    try:
        outfile = open(raw_results_outfile, "w")
        for line in lines:
                outfile.write(line)
        outfile.close()
    except IOError as error:
            sys.exit("Can't write to file: {}".format(error))

    print("Results can be found in: {}.".format(raw_results_outfile))


