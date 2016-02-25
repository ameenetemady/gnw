#!/bin/bash
/usr/bin/java -Xmx64000m -jar ../gnw-3.1.2b.jar --simulate -c settings.txt --input-net cascadeB.xml

mkdir -p processed
fGNWOut="cascadeB_multifactorial.tsv"
cat $fGNWOut |awk '{print $3}' | tail -n +2 > processed/input.tsv
cat $fGNWOut |awk '{print $1"\t"$2}' | tail -n +2 > processed/target.tsv
