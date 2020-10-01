module load tools
module load anaconda2/4.0.0
module load perl/5.30.2
module load roary/3.13.0


################################################################################
# GET INPUT
################################################################################


p=/home/projects/cge/people/cathom
n=DTU_LAB
d=20200825_110300
o=clustered_proteins_all_species
i1=${p}/results/${n}_${d}/prokka/*/*.gff  #—— KUN DE RIGTIGE SPECIES?? SÅ VI VIL HAVE EN LISTE AF SAMPLES ——
i2=${p}/data/ref/Lactococcus_lactis/data/*/*.gff


################################################################################
# STEP 1: RUN ROARY
################################################################################

### Rename reference .gff file, so they have an unique name

gffsamples=$(ls ${p}/data/ref/Lactococcus_lactis/data/*/*.gff)

for gff in $gffsamples
	do
		path=$(dirname ${gff})
		current_name=$(basename ${gff})
		new_name=$(basename $(dirname $gff)).gff

		mv ${path}/${current_name} ${path}/${new_name}
	done

# Run roary
roary -f ${p}/results/${n}_${d}/roary -o $o $i1


#2020/10/01 10:49:35 Input file contains duplicate gene IDs, attempting to fix by adding a unique suffix, new GFF in the fixed_input_files directory: /home/projects/cge/people/cathom/data/ref/Lactococcus_lactis/data/GCF_902364565.1/GCF_902364565.1.gff
#All input files have been excluded from analysis. Please check you have valid GFF files, with annotation and a FASTA sequence at the end. Better still, reannotate your FASTA file with PROKKA. at /services/tools/roary/3.13.0/lib/site_perl/5.26.2/Bio/Roary/CommandLine/Roary.pm line 273.

