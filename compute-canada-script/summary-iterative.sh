#!/bin/bash
d=$1 #directory for iterative cubing
v=$2 #initial amount of variables to eliminate during iterative cubing
a=$3 #amount of additonal variable to eliminate in each cubing stage
n=$4 #order

cd $d

cubetime=$(find . -type f -name "*.log" -exec grep -h "c time * *[0-9]*\.*[0-9]*" {} + | awk '{total += $(NF-1)} END {print total}')
simptime=$(find . -type f -name "*.simp" -exec grep -h "c total process time since initialization: * *[0-9]*\.*[0-9]*" {} + | awk '{total += $(NF-1)} END {print total}')
simptime2=$(find . -type f -name "*.log" -exec grep -h "c total process time since initialization: * *[0-9]*\.*[0-9]*" {} + | awk '{total += $(NF-1)} END {print total}')
solvetime=$(find . -type f -name "*.log" -exec grep -h "CPU time * *[0-9]*\.*[0-9]*" {} + | awk '{total += $(NF-1)} END {print total}')
verifytime=$(find . -type f -name "*.log" -exec grep -h "verification time: * *[0-9]*\.*[0-9]*" {} + | awk '{total += $(NF-1)} END {print total}')
conflicts=$(find . -type f -name "*.log" -exec grep -h "conflicts             : * *[0-9]*\.*[0-9]*" {} + | awk '{total += $(NF-2)} END {print total}')

printf "%-15s %-15s %-15s %-15s %-15s\n" "cubing time" "cube simp time" "solve simp time" "solve time" "verify time"
printf "%-15s %-15s %-15s %-15s %-15s\n" "${cubetime} secs" "${simptime} secs" "${simptime2} secs" "${solvetime} secs" "${verifytime} secs"

printf "total number of conflicts: $conflicts"

cd -

#verify

perform_verification() {
    local directory_to_verify=$1
    local current_var_eliminated=$2
    local increment=$3

    solve_log=$directory_to_verify/$n-solve
    cube_log=$directory_to_verify/$n-cubes

    if [ ! -d "$solve_log" ] || [ -z "$(ls -A "$solve_log")" ]; then
        echo "Error: $solve_log cannot be found or is empty, verification failed"
        exit 0
    fi

    files=$(ls $cube_log/*.cubes)
    highest_num=$(echo "$files" | awk -F '[./]' '{print $(NF-1)}' | sort -nr | head -n 1)
    cube_file=$cube_log/$highest_num.cubes

    num_cubes=$(wc -l "$cube_file" | awk '{print $1}')

    for ((i=1; i<=$num_cubes; i++))
    do
        file=$solve_log/$i-solve.log
        if [ ! -f "$file" ] ; then
            echo "Error: $file cannot be found or is empty, verification failed"
            exit 0
        fi
        if grep -q "UNSATISFIABLE" "$file"; then
            if grep -q "s VERIFIED" "$file"; then
                echo "$file verified"
            else
                echo "$file is solved but not verified"
            fi
        else
            echo "$file is not solved, needs to be extended"
            index=$(echo "$file" | grep -oP '(?<=/)\d+(?=-solve\.log)')
            result="$current_var_eliminated-$index"
            new_var_to_cube=$(echo "$current_var_eliminated + $increment" | bc)
            d="${solve_log%%/$current_var_eliminated*}"
            new_dir=$d/$result/$new_var_to_cube
            command="perform_verification $new_dir $new_var_to_cube $a"
            #echo $command
            eval $command
        fi
    done
}


directory_to_verify=$d/$v
perform_verification "$directory_to_verify" $v $a