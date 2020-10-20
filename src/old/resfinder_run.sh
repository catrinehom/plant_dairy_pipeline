#!/bin/sh

Samples=$(ls /home/projects/cge/people/cathom/data/prepros)

for sample in $Samples
do
if [ -d "/home/projects/cge/people/cathom/results/ResFinder/$sample" ] 
then
    echo "Directory exists."
else
    mkdir /home/projects/cge/people/cathom/results/ResFinder/$sample
    resfinder.pl -d /home/projects/cge/people/cathom/data/resfinder_db -i /home/projects/cge/people/cathom/data/prepros/$sample/Assemblies/*.fa -o /home/projects/cge/people/cathom/results/ResFinder/$sample -a aminoglycoside,colistin,glycopeptide,sulphonamide,oxazolidinone,quinolone,tetracycline,beta-lactam,fosfomycin,macrolide,phenicol,trimethoprim,fusidicacid,nitroimidazole,rifampicin -k 90.00 -l 0.60
fi
echo "Finished with $sample"
done
