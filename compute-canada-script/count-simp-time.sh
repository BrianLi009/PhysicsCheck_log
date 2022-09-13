#!/bin/bash

"""
Computing the simplification time, input i as the directory with log files in the form of slurm*.out
"""

i=$1

touch "$i"_count.log

total_time=0

for f in $i/slurm*.out
do 	
	grep 'c total real time since initialization:' $f | cut -d = -f 2 | cut -d ':' -f 2 | cut -d 's' -f 1 >> "$i"_count.log
done

awk '{s+=$1} END {print s}' "$i"_count.log