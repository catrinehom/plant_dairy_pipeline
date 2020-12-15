#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Program: plot_computerome.py
Description: This program plot the results from plant dairy pipeline
Version: 1.0
Author: Catrine Høm and Line Andresen

# Usage:
    ## plot_results.py

# Output:
    ## pretty plots for our report
"""

# Import libraries
from argparse import ArgumentParser
import os
import pandas as pd
import matplotlib.pyplot as plt 
import seaborn as sns
import numpy as np

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
    date = str(args.d)

outputfolder = main_path + "/results/" + project_name + "_" + date + "/plots/"
inputfolder  = main_path + "/results/" + project_name + "_" + date + "/summary/"

if not os.path.exists(outputfolder):
    os.mkdir(outputfolder)
    
##############################################################################
# QC plot
##############################################################################

file = inputfolder + "foodqcpipeline_results.txt"
qc   = pd.read_csv(file, sep='\t', index_col=False)
qc.set_index('Sample_name', inplace=True)
qc['Qual_bases(%)']=qc['Qual_bases(%)'].str.split('%').str[0].astype(float)

fig, axs = plt.subplots(2,1,figsize=(6.4,4))
fig.subplots_adjust(hspace=0.5)

sns.boxplot(data = qc, x='Reads', ax=axs[0]).tick_params(left=False)

sns.boxplot(data = qc, x='Qual_bases(%)',ax=axs[1]).tick_params(left=False)
axs[0].set(xlabel='Number of reads per sample after QC')
axs[1].set(xlabel='Percentage of bases per sample after QC')
sns.despine(left=True, right=True, top=True, bottom=False)

fig.savefig(outputfolder+'QC_bases_and_reads.png', format='png', dpi=400)
