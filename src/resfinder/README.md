# Resistance gene identification as a part of plant_dairy_pipeline #

## Introduction ##

This program run ResFinder which is a part of the dairy pipeline.
ResFinder identifies acquired antimicrobial resistance genes in raw reads of isolates of bacteria.
The raw reads (fastq) are aligned to a gene database to find resistance.

**Maintainer:** Line Andresen (linan@dtu.dk) and Catrine Høm (s136574@student.dtu.dk)

## Pipeline overview ##

1. Download and install database (make_db_resfinder)
2. Run ResFinder on samples (run_resfinder)
3. Make a collected .txt for all samples (collect_resfinder)


## Output ##

Raw output from the tool will be a txt found under your main path -> results -> your project name with a data -> resfinder.

A summary for all samples can be seen in your main path -> results -> results -> your project name with a data -> summary -> resfinder_results.txt.

## Run pipeline ##

```
/src/resfinder/make_db_resfinder -p [path] -n [n]
/src/resfinder/run_resfinder.sh -p [path] -n [n] -d [date]
/src/resfinder/collect_resfinder.py -p [path] -n [n] -d [date]
```

Detailed arguments:

```
  -h, show help message and exits program
  -p, path to dairy pipeline
  -n, name of project
  -d, date of run (optional)
```

