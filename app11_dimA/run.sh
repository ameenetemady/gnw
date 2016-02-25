#!/bin/bash
#/usr/bin/java -Xmx64000m -jar ../gnw-3.1.2b.jar --simulate -c settings.txt --input-net dimA.xml

mkdir -p processed
fGNWOut="dimA_multifactorial.tsv"
cat $fGNWOut |awk '{print $1"\t"$4}' | tail -n +2 > processed/input.tsv
cat $fGNWOut |awk '{print $2"\t"$3"\t"$5}' | tail -n +2 > processed/target.tsv
