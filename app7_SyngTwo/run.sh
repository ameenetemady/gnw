#!/bin/bash
/usr/bin/java -Xmx64000m -jar ../gnw-3.1.2b.jar --simulate -c settings.txt --input-net SyngTwo.xml

mkdir -p processed
fGNWOut="SyngTwo_multifactorial.tsv"
paste -d"\t" $fGNWOut |awk '{print $1"\t"$2}' | tail -n +2 > processed/input.tsv
paste -d"\t" $fGNWOut |awk '{print $3}' | tail -n +2 > processed/target.tsv
