#!/bin/bash
qsub -V -cwd -q flavor.q -S /bin/bash -N japp20_gnw_cascade5 runOne.sh 
