#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug 26 09:23:21 2020

@author: catrinehom
"""

# import libraries
from os import listdir
import sys
import glob

mypath = '/home/projects/cge/people/cathom/results/kmerfinder'
dirs = [f for f in listdir(mypath)]
outfile = '/home/projects/cge/people/cathom/results/kmerfinder/kmerfinder_results.txt'
lines = list()
run_zero = True


for name in dirs:
    path = mypath+'/'+name+'/*' 
    print('path: '+path)
    for filename in glob.glob(path):
        print('filename: '+filename)
        if filename.endswith('_results.txt'):
            print('results.txt filename: '+filename)
            with open(filename, 'r') as f:
                if run_zero == True:
                    lines.append('Sample name\t'+f.readline())
                    for line in f:
                        lines.append(name+'\t')
                        lines.append(line)
                        run_zero = False
                    
                else:
                    next(f)
                    for line in f:
                        lines.append(name+'\t')
                        lines.append(line)
                                        

try:
        outfile = open(outfile, 'w')
        for line in lines:
                outfile.write(line)
        outfile.close()
except IOError as error:
        sys.exit("Cant write to file: {}".format(error))  
