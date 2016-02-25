#!/bin/bash
/usr/bin/java -Xmx32000m -jar ../gnw-3.1.2b.jar --simulate -c settings.txt --input-net feedforward1.xml

mkdir -p processed
fGNWOut="feedforward1_multifactorial.tsv"
cat $fGNWOut |awk '{print $3}' | tail -n +2 > processed/input.tsv
cat $fGNWOut |awk '{print $1"\t"$2}' | tail -n +2 > processed/target.tsv
