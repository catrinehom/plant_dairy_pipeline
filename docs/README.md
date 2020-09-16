# Catrine and Lines veghurt pipeline #

## Introduction ##

This pipeline takes raw reads as input, and will perform QC and assembly of these reads.
Afterwards and analysis of the data will be performed, to determine if any sample could be useful for fermentation of plant yoghurt.

The pipeline is written to be executed on Computerome at DTU. It could be modified to run elsewhere but this would require some work.

**Maintainer:** Line Andresen (linan@dtu.dk) and Catrine Høm (s136574@student.dtu.dk)

## Pipeline overview ##

1. Run QC and assembly (FastQC and SPAdes)
2. Resistance genes (ResFinder)
3. ... ()


## Pipeline details ##

### QC and assembly ###

fastqcpipeline

### Output ###

Structure and files


## Run default pipeline ##


```
python FoodQCPipeline.py --spades True Raw_data/*.gz
```


## Advanced options ##

Use the -h flag to see all the possible options.

```
python FoodQCPipeline.py -h
usage: FoodQCPipeline.py [-h] [--adapters ADAP_TXT] [--map_db DB_TXT]
                         [--queue QUEUE] [--spades BOOL] [--trim_output DIR]
                         [--trim_mem MEM] [--assembly_output DIR]
                         [--qc_output DIR] [--tmp_dir DIR] [--keep]
                         [-c CONF_PATH] [--abs_path_adapt PATH]
                         [--grade GRADE] FAST(Q|A) [FAST(Q|A) ...]

Runs triming, fastqc, and assembly. Used for QC.

positional arguments:
  FAST(Q|A)             Raw data in FASTQ format and/or assemblies in FASTA
                        format.

optional arguments:
  -h, --help            show this help message and exit
  --adapters ADAP_TXT   Text file containing on adapter on each line.
  --map_db DB_TXT       The pipeline maps all reads to this database in order
                        to determine insert size and spot contaminations in
                        WGS samples. WGS samples are defined as samples that
                        are also assembled using SPAdes. IMPORTANT: The
                        database must have been indexed with the bbmap version
                        corresponding to the pipeline and it must have been
                        indexed using the usemodulo=t option.
  --queue QUEUE         Use a queing system for a computer cluster.
  --spades BOOL         If set the data assembled with spades.
  --trim_output DIR     The directory where the trimmed files will be stored.
  --trim_mem MEM        Manually set memory requirements for the trimming step
                        in gigabytes.
  --assembly_output DIR
                        The directory where the assemblies will be stored
  --qc_output DIR       The directory where the qc reports are stored.
  --tmp_dir DIR         The directory where temporary files are stored.
  --keep                Keep the concatenated fastq files in the tmp dir.
```

## Suggestions and Improvements ##

Do not hesitate to let me know if you have ideas for improvements or extra functionality that could be useful.

