#!/bin/bash
qsub -V -cwd -q flavor.q -S /bin/bash -N job_gnw_net9s runOne.sh 
