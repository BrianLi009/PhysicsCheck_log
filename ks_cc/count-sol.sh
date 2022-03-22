#!/bin/bash

#Count the total number of solutions in all log files in a solution, note that this script does not
#verify or check for error, see verify.sh for that purpose.

i=$1 # directory with all the log files
sum=0
total_files=0

#computing expected number of solutions
for f in $i/*.out
do
        total_files=$((total_files+1))
        if grep -q "Number of solutions" $f
        then
                number=( $(grep "Number of solutions"  $f | cut -f2 -d:) )
                sum=$((sum += $number))
        fi
done

echo "Expecting $sum Kochen Specker candidates"
echo "in total $total_files files checked."