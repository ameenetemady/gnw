#!/bin/bash
gnwJarPath="/Users/ameen/mygithub/gnw/gnw-3.1.2b.jar"
javaPath="/usr/bin/java"
# Note: "-Dapple.awt.UIElement=true" is used to avoid java console popup window
"$javaPath" -Dapple.awt.UIElement=true -Xmx4000m -jar $gnwJarPath --simulate -c settings.txt --input-net $1

