# Gene/pathway finder as a part of plant_dairy_pipeline #

## Introduction ##

This program runs MyDbFinder which is a part of the dairy pipeline.
MyDbFinder is used for identification of sequences (genes/pathways) present in the databases provided.

**Maintainer:** Line Andresen (linan@dtu.dk) and Catrine Høm (s136574@student.dtu.dk)

## Pipeline overview ##

1. Download and install database from gene names (make_db_mydbfinder)
2. Run MyDbFinder on samples (run_mydbfinder)
3. Make a collected .txt for all samples (collect_mydbfinder)


## Output ##

Raw output from the tool will be a txt found under your main path -> results -> your project name with a data -> mydbfinder -> database name.

A summary for all samples can be seen in your main path -> results -> your project name with a data -> summary -> database name_results.txt.

## Run pipeline ##

```
/src/mydbfinder/make_db_mydbfinder -p [path] -n [n]
/src/mydbfinder/run_mydbfinder.sh -p [path] -n [n] -d [date]
/src/mydbfinder/collect_mydbfinder.py -p [path] -n [n] -d [date]
```

Detailed arguments:

```
  -h, show help message and exits program
  -p, path to dairy pipeline
  -n, name of project
  -d, date of run (optional)
```

