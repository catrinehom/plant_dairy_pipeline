# QC and assembly of samples as a part of plant_dairy_pipeline #

## Introduction ##

This program runs foodqcpipeline which is a part of the dairy pipeline.
foodqcpipeline trims low quality data and adaptor sequences. Furthermore it performs a de novo assembly using SPAdes.

**Maintainer:** Line Andresen (linan@dtu.dk) and Catrine Høm (s136574@student.dtu.dk)

## Pipeline overview ##

1. Run foodqcpipeline on samples (run_foodqcpipeline)
2. Make a collected .txt for all samples (collect_foodqcpipeline)


## Output ##

Raw output from the tool will be a txt found under your main path -> results -> your project name with a data -> foodqcpipeline.

A summary for all samples can be seen in your main path -> results -> your project name with a data -> summary -> foodqcpipeline_results.txt.

## Run pipeline ##

```
/src/kmerfinder/run_foodqcpipeline.sh -p [path] -n [n] -d [date]
/src/kmerfinder/collect_foodqcpipeline.py -p [path] -n [n] -d [date]
```

Detailed arguments:

```
  -h, show help message and exits program
  -p, path to dairy pipeline
  -n, name of project
  -d, date of run (optional)
```

