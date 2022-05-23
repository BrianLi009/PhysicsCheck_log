#!/bin/bash

#set -x

o=$1 #first index of cube files to check within directory d
i=$2 #last index of cube files to check within directory d
n=$3 #order
d=$4 #all log files should be stored in a directory

cd $d

touch verified.txt #create a file for verification
chmod u+x verified.txt #make the file writeable

for index in $(seq $o $i)
do
        find . -name "*_$index.out" -print0 | while read -d $'\0' file
        do
                if grep -q "UNSATISFIABLE" $file #if a file is successfully solved by MapleSAT, it should output "UNSATISFIABLE"
                then
                        if grep -q "Number of solutions" $file
                        then
                                number=( $(grep "Number of solutions"  $file | cut -f2 -d:) )
                                output_num=( $(wc -l $n-$index.exhaust) )
                                if [ $number != $output_num ]
                                then
                                    echo "$index output error" >> verified.txt
                                else
                                    echo "$index $number" >> verified.txt
                                fi
                        elif grep -q "error" $file
                        then 
                            echo "$index other error" >> verified.txt
                        else
                                number=0
                                echo "$index $number" >> verified.txt
                        fi
                fi
        done
done

grep "error" verified.txt
