#!/bin/bash
qsub -V -cwd -q flavor.q -S /bin/bash -N japp19_gnw runOne.sh 
