#!/usr/bin/env bash

#####################################
########## COMPUTEROME ##############
#####################################


Samples=$(ls /home/projects/cge/people/cathom/data/foodqcpipeline)

for sample in $Samples
do
  cd /home/projects/cge/people/cathom/data/foodqcpipeline/${sample}/Assemblies/
  cd *trimmed
  mv assembly_graph_with_scaffolds.gfa ${sample}_assembly_graph_with_scaffolds.gfa
  echo $sample
done

for sample in $Samples
do
  cp /home/projects/cge/people/cathom/data/foodqcpipeline/${sample}/Assemblies/*trimmed/${sample}_assembly_graph_with_scaffolds.gfa /home/projects/cge/people/cathom/results/foodqcpipeline/gfa_results/
done

tar czf gfa_results.tar.gz /home/projects/cge/people/cathom/results/foodqcpipeline/gfa_results/

###################################
######## LOCAL COMPUTER ###########
###################################

scp cathom@ssh.computerome.dk:/home/projects/cge/people/cathom/results/foodqcpipeline/gfa_results.tar.gz /Users/catrinehom/Desktop/gfa_results/

tar -xf gfa_results.tar.gz


gfas=$(ls /Users/catrinehom/Desktop/gfa_results)

for gfa in $gfas
do
  /Users/catrinehom/Bandage/Bandage.app/Contents/MacOS/Bandage image $gfa $gfa.png
done

