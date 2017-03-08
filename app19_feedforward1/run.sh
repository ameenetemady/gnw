#!/bin/bash
gnwJarPath="/Users/ameen/mygithub/gnw/gnw-3.1.2b.jar"
javaPath="/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/java"
"$javaPath" -Xmx32000m -jar $gnwJarPath --simulate -c settings.txt --input-net $1

