#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# import libraries
from os import listdir
import sys
import glob

mypath = '/home/projects/cge/people/cathom/results/glutamatefinder'
dirs = [f for f in listdir(mypath)]
outfile = '/home/projects/cge/people/cathom/results/glutamatefinder/glutamate_results.txt'
lines = list()
run_zero = 1

for name in dirs:
        path = mypath+'/'+name+'/kma_glutamate_database.res'
        for filename in glob.glob(path):
                with open(filename, 'r') as f:
                        if run_zero == 1:
                                lines.append('Sample name\t'+f.readline())
                                run_zero = 0
                        next(f,"")
                        for line in f:
                                lines.append(name+'\t'+line)
                                        

try:
        outfile = open(outfile, 'w')
        for line in lines:
                outfile.write(line)
        outfile.close()
except IOError as error:
        sys.exit("Cant write to file: {}".format(error))  
