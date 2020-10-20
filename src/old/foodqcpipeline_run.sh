### SKAL OPDATERES. Line har noget kode? ligger vidst under misc

Samples=$(ls /home/projects/cge/people/cathom/data/raw/NZ_genomes_2)

for sample in $Samples
do
cd /home/projects/cge/people/cathom/data/prepros
mkdir ${sample}
cd /home/projects/cge/people/cathom/data/raw/NZ_genomes_2/${sample}
python /home/projects/cge/people/cathom/scripts/foodqcpipeline/FoodQCPipeline.py *.gz --clean_tmp --assembly_output   /home/projects/cge/people/cathom/data/prepros/${sample}/Assemblies --qc_output         /home/projects/cge/people/cathom/data/prepros/${sample}/QC --trim_output       /home/projects/cge/people/cathom/data/prepros/${sample}/Trimmed
done
