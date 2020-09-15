# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

# import libraries
from os import listdir
from os import chdir
import sys
import glob

# Change paths to folder and output file
mypath = '/home/projects/cge/people/cathom/data/raw/NZ_genomes_2'
outfile = '/home/projects/cge/people/linan/list.txt'

# Initiate
dirs = [f for f in listdir(mypath)]
names = list()

# Get filenames for repeat 1: R1
for name in dirs:
    chdir(mypath+'/'+name)
    for filename in glob.glob("*_R1_P_trimmed.fastq.gz"):
        print(filename)
        names.append(filename[:10])
# Write output file
try:
    outfile = open(outfile, 'w')
    for i in range(0,len(names)):
        outfile.write(dirs[i]+'\t'+names[i]+'\n')
    outfile.close()
except IOError as error:
    sys.exit("Cant write to file: {}".format(error))
    
