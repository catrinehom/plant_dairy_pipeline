#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Program: collect_plasmidfinder.py
Description: This program collect the results from all samples made from plasmidfinder
Version: 1.0
Author: Catrine Høm and Line Andresen

# Usage:
    ## collect_plasmidfinder [-p <path to dairy pipeline>] [-n <name of project>]  [-d <date of run>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)

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
import json

################################################################################
# GET INPUT
################################################################################

if __name__ ==  "__main__":
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
    samples = [f for f in os.listdir(main_path +  "/results/" + project_name + date + "/foodqcpipeline")]
    raw_results_outfolder = main_path + "/results/" + project_name + date + "/summary/"
    raw_results_outfile = raw_results_outfolder + "plasmidfinder_results.txt"
    lines = list()
    header_made = False

    # Create outputfolder if it doesn't exist
    if not os.path.exists(raw_results_outfolder):
        os.makedirs(raw_results_outfolder)

    # Loop through samples
    print("Start collecting results in one common file for all samples...")
    for sample in samples:
            # Define path for each sample
            sample_path = main_path + "/results/" + project_name + date + "/plasmidfinder/" + sample + "/"

            # Find file in path
            tool_files = [f for f in os.listdir(sample_path) if os.path.isfile(os.path.join(sample_path, f))]

            # Collect results
            for file in tool_files:
                if file == "data.json":
                    sample_result = sample_path + file

                    # Open file
                    with open(sample_result, "r") as json_file:
                        data = json.load(json_file)
                        for key in data["plasmidfinder"]["results"]:
                            result = data["plasmidfinder"]["results"][key]
                            for key in result:
                                hit = result[key]
                                if hit !=  "No hit found":
                                    print(sample)
                                    print(key)
                                    print(result[key])
                                    outline = sample + "\t" + key + "\t" + str(result[key])
                                    print(outline)
                                    lines.append(outline)
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

