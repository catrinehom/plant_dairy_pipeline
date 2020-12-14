#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Program: collect_dbcan.py
Description: This program collect the results from all samples made from dbcan
Version: 1.0
Author: Catrine Høm and Line Andresen

# Usage:
    ## collect_dbcan.py [-p <path>] [-n <name>] [-d <date of run>]
    ## -p, path to dairy pipeline folder (str)
    ## -n, name of project (str)
    ## -d, date of run (str)

# Output:
    ## dbcan_results.txt, summary of GH families for all samples
"""

# Import libraries
from argparse import ArgumentParser
import os
import re
import pandas as pd

################################################################################
# GET INPUT
################################################################################

if __name__ == "__main__":
    # Parse input from command line
    parser = ArgumentParser()
    parser.add_argument("-p", dest="p", help="path to main", required=True, type=str)
    parser.add_argument("-n", dest="n", help="name of project", required=True, type=str)
    parser.add_argument("-d", dest="d", help="date of run", required=True)
    args = parser.parse_args()

    # Define input as variables
    main_path = args.p
    project_name = args.n
    date = str(args.d)

################################################################################
# STEP 1:  COLLECT RESULTS
################################################################################

# Define input and output files
dbcan_path = main_path + "/results/" + project_name + "_" + date + "/dbcan/"
samples = [file for file in os.listdir(dbcan_path) if os.path.isdir(os.path.join(dbcan_path, file))]
summary_outfolder = main_path + "/results/" + project_name + "_" + date + "/summary/"
summary_outfilename = summary_outfolder + "dbcan_results.txt"

# Create outputfolder if it doesn't exist
if not os.path.exists(summary_outfolder):
    os.makedirs(summary_outfolder)

# Define variables
header = False
CAZy_classes = dict()
CAZy_main = dict()
CAZy_classes_pattern = r"((GH|PL|CE|AA|GT|CBM)[0-9]{1,10})"
CAZy_main_pattern = r"((GH|PL|CE|AA|GT|CBM))"

# Go through all samples
for sample in samples:
    sample_path = dbcan_path + sample + "/" + "overview.txt"

    res_file = open(sample_path,"r")

    #sample = sample.split("_")[0]

    sample_CAZy_classes = set()
    CAZy_classes[sample] = dict()
    CAZy_main[sample] = dict()

    #Find header if it
    if not header:
        # Create header variable
        header = res_file.readline()

    else:
        #Skip header
        res_file.readline()

    for line in res_file:
        line = line.split("\t")
        gene_id = line[0]
        HMMER = line[1]
        Hotpep = line[2]
        Diamond = line[3]
        signalp = line[4]
        noofTools = int(line[5])

        # We need at least two tools agreeing to trust the result
        if noofTools > 1:
            # Diamond is the most precise tool
            CAZy_classes_result = re.findall(CAZy_classes_pattern, Diamond)
            if CAZy_classes_result != None:
                for CAZy in CAZy_classes_result:
                    if CAZy[0] in CAZy_classes[sample]:
                        CAZy_classes[sample][CAZy[0]] += 1
                    else:
                        CAZy_classes[sample][CAZy[0]] = 1
                        CAZy_classes_result = re.findall(CAZy_classes_pattern, Diamond)

            CAZy_main_result = re.findall(CAZy_main_pattern, Diamond)
            if CAZy_main_result != None:
                for CAZy in CAZy_main_result:
                    if CAZy[0] in CAZy_main[sample]:
                        CAZy_main[sample][CAZy[0]] += 1
                    else:
                        CAZy_main[sample][CAZy[0]] = 1



# Write results to file
summary_outfile = open(summary_outfilename, "w")

df = pd.DataFrame.from_dict(CAZy_classes)
df = df.fillna(0)
df.to_csv(summary_outfilename, sep="\t")

summary_outfile.close()


print("Results can be found in: {}".format(summary_outfilename))

