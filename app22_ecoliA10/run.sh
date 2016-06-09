#!/bin/bash
gnwJarPath="/home/ameen/gnw/gnw-3.1.2b.jar"
javaPath="/usr/bin/java"
$javaPath -Xmx32000m -jar $gnwJarPath --simulate -c settings.txt --input-net $1


