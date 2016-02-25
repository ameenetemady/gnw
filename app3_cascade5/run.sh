#!/bin/bash
/usr/bin/java -Xmx64000m -jar ../gnw-3.1.2b.jar --simulate -c settings.txt --input-net InSilicoSize4-CascadeA.xml

mkdir -p processed
fGNWOut="InSilicoSize4-CascadeA_multifactorial.tsv"
fGNWIn="InSilicoSize4-CascadeA_multifactorial_perturbations.tsv"
paste -d"\t" $fGNWOut $fGNWIn |awk '{print $1"\t"$7"\t"$8"\t"$9"\t"$10}' | tail -n +2 > processed/input.tsv
paste -d"\t" $fGNWOut $fGNWIn  |awk '{print $2"\t"$3"\t"$4"\t"$5}' | tail -n +2 > processed/target.tsv
