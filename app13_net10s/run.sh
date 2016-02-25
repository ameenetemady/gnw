#!/bin/bash
/usr/bin/java -Xmx32000m -jar ../gnw-3.1.2b.jar --simulate -c settings.txt --input-net net10s.xml

mkdir -p processed
fGNWOut="net10s_multifactorial.tsv"
cat $fGNWOut |awk '{print $7"\t"$10}' | tail -n +2 > processed/input.tsv
cat $fGNWOut |awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$8"\t"$9}' | tail -n +2 > processed/target.tsv
