#!/bin/bash
#set -x
i=$1 # folder with all the log files
sum=0
total_files=0

#computing expected number of solutions
for f in $i/*.out
do 	
	total_files=$((total_files+1))
	if grep -q "CPU time" $f
	then
		number=( $(grep "CPU time"  $f | cut -f2 -d:) )
		job_runtime=${number%.*}
		sum=$((sum += $job_runtime))
	fi
done

echo "Calculated $sum solving time"
echo "in total $total_files files checked."
