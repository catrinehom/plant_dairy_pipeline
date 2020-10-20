#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jul  8 12:35:18 2020

@author: catrinehom
"""

# import libraries
from os import listdir
import sys
import glob

mypath = '/home/projects/cge/people/cathom/data/prepros'
dirs = [f for f in listdir(mypath)]
outfile = '/home/projects/cge/people/cathom/data/QC.txt'
lines = list()


for name in dirs:
    path = mypath+'/'+name+'/QC/*.txt'
    for filename in glob.glob(path):
        with open(filename, 'r') as f:
            for line in f:
                lines.append(line)

try:
    outfile = open(outfile, 'w')
    for line in lines:
        outfile.write(line)
    outfile.close()
except IOError as error:
    sys.exit("Cant write to file: {}".format(error))  
