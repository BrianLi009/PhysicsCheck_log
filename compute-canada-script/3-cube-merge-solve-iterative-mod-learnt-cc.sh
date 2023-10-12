#!/bin/bash

n=$1 #order
f=$2 #instance file name
d=$3 #directory to store into
v=$4 #num of var to eliminate during first cubing stage
t=$5 #num of conflicts for simplification
a=$6 #amount of additional variables to remove for each cubing call
c=$7 #total number of cores available
p=${8:-} #preset cube to extend on

#new implementation should do the following in order:
#parameters: cube file, # of cores to be used = cpu
#1. input a cube file, determine total number of cubes n (done currently)
#2. compute number of cubes that need to be solved on each core, which is cpu/n = c 
#3. core n solve cubes if index mod cpu == n
#4. once all cubes are terminated, adjoin all unsolved cubes to create the next cube file, submit parallized job to further cube them

#we want the script to: cube, for each cube, submit sbatch to solve, if not solved, call the script again

mkdir -p $d/$v/$n-solve
mkdir -p $d/$v/simp
mkdir -p $d/$v/log
mkdir -p $d/$v/$n-cubes

di="$d/$v"

./gen_cubes/cube.sh -a -p $n $f $v $di $depth

files=$(ls $d/$v/$n-cubes/*.cubes)
highest_num=$(echo "$files" | awk -F '[./]' '{print $(NF-1)}' | sort -nr | head -n 1)
echo "currently the cubing depth is $highest_num"
cube_file=$d/$v/$n-cubes/$highest_num.cubes
cube_file_name=$(echo $cube_file | sed 's:.*/::')
new_cube=$((highest_num + 1))

numline=$(< $cube_file wc -l)
new_index=$((numline))

#new_index is the total number of cubes

for ((i=1; i<=$c; i++)); do
    factor=0
    cube_index=1
    echo "#!/bin/bash" > $d/$v/simp/$i-solve.sh
    echo "#SBATCH --account=rrg-cbright" >> $d/$v/simp/$i-solve.sh
    echo "#SBATCH --time=0-04:00" >> $d/$v/simp/$i-solve.sh
    echo "#SBATCH --mem-per-cpu=4G" >> $d/$v/simp/$i-solve.sh
    while [[ $cube_index -lt $new_index ]]; do
        cube_index=$(($i + $factor*$c))
        ((factor++))
        if [[ $cube_index -le $new_index ]]; then
            echo "Writing solving script of cube $cube_index to Core $i"
            child_instance="$d/$v/simp/${highest_num}.cubes${cube_index}.adj.simp"
            command1="./gen_cubes/apply.sh $f $cube_file $cube_index > $d/$v/simp/$cube_file_name$cube_index.adj"
            command2="./simplification/simplify-by-conflicts.sh $d/$v/simp/$cube_file_name$cube_index.adj $n $t"
            command3="./maplesat-solve-verify.sh -l $n $d/$v/simp/$cube_file_name$cube_index.adj.simp $d/$v/$n-solve/$cube_index-solve.exhaust >> $d/$v/$n-solve/$cube_index-solve.log"
            command4="if ! grep -q 'UNSATISFIABLE' '$d/$v/$n-solve/$cube_index-solve.log'; then sbatch $child_instance-cube.sh; fi"
            command="$command1 && $command2 && $command3 && $command4"
            echo $command >> $d/$v/simp/$i-solve.sh
        fi
    done
done

for i in $(seq 1 $new_index) #1-based indexing for cubes
    do
        child_instance="$d/$v/simp/${highest_num}.cubes${i}.adj.simp"
        command5="./gen_cubes/concat.sh $child_instance $child_instance.noncanonical > $child_instance.temp; ./gen_cubes/concat.sh $child_instance.temp $child_instance.unit > $child_instance.learnt; rm $child_instance.noncanonical; rm $child_instance.temp; rm $child_instance.unit; ./3-cube-merge-solve-iterative-mod-learnt-cc.sh $n $child_instance.learnt '$d/$v-$i' $v $t $a $c"
        echo "#!/bin/bash" > $child_instance-cube.sh
        echo "#SBATCH --account=def-cbright" >> $child_instance-cube.sh
        echo "#SBATCH --time=0-04:00" >> $child_instance-cube.sh
        echo "#SBATCH --mem-per-cpu=4G" >> $child_instance-cube.sh
        echo $command5 >> $child_instance-cube.sh
    done