#!/bin/bash

n=$1 #order
f=$2 #instance file name
d=$3 #directory to store into
v=$4 #num of var to eliminate during first cubing stage
t=$5 #num of conflicts for simplification
s=$6 #amount of timeout for each solving
a=$7 #amount of additional variables to remove for each cubing call

#we want the script to: cube, for each cube, submit sbatch to solve, if not solved, call the script again

mkdir -p $d/$v/$n-solve
mkdir -p $d/$v/simp
mkdir -p $d/$v/log
mkdir -p $d/$v/$n-cubes

di="$d/$v"
./gen_cubes/cube.sh -a $n $f $v $di

files=$(ls $d/$v/$n-cubes/*.cubes)
highest_num=$(echo "$files" | awk -F '[./]' '{print $(NF-1)}' | sort -nr | head -n 1)
echo "currently the cubing depth is $highest_num"
cube_file=$d/$v/$n-cubes/$highest_num.cubes
cp $(echo $cube_file) .
cube_file=$(echo $cube_file | sed 's:.*/::')
new_cube=$((highest_num + 1))

numline=$(< $cube_file wc -l)
new_index=$((numline))

for i in $(seq 1 $new_index) #1-based indexing for cubes
    do
        child_instance="$d/$v/simp/${highest_num}.cubes${i}.adj.simp"
        command1="./gen_cubes/apply.sh $f $cube_file $i > $d/$v/simp/$cube_file$i.adj"
        command2="./simplification/simplify-by-conflicts.sh $d/$v/simp/$cube_file$i.adj $n $t >> $d/$v/$n-solve/$i-solve.log"
        command3="timeout ${s}s ./maplesat-solve-verify.sh -l $n $d/$v/simp/$cube_file$i.adj.simp $d/$v/$n-solve/$i-solve.exhaust >> $d/$v/$n-solve/$i-solve.log"
        command4="if ! grep -q 'UNSATISFIABLE' '$d/$v/$n-solve/$i-solve.log'; then sbatch $child_instance-cube.sh; fi"
        #sbatch this line
        command5="./gen_cubes/concat.sh $child_instance $child_instance.noncanonical > $child_instance.temp; ./gen_cubes/concat.sh $child_instance.temp $child_instance.unit > $child_instance.learnt; ./3-cube-merge-solve-iterative-learnt-cc.sh $n $child_instance.learnt '$d/$v-$i' $(($v + $a)) $t $s $a $(($highest_num+2)) $new_cube_file"
        command="$command1 && $command2 && $command3"
        echo "#!/bin/bash" > $child_instance-solve.sh
        echo "#SBATCH --account=def-cbright" >> $child_instance-solve.sh
        echo "#SBATCH --time=0-04:00" >> $child_instance-solve.sh
        echo "#SBATCH --mem-per-cpu=4G" >> $child_instance-solve.sh
        echo "#!/bin/bash" > $child_instance-cube.sh
        echo "#SBATCH --account=def-cbright" >> $child_instance-cube.sh
        echo "#SBATCH --time=0-04:00" >> $child_instance-cube.sh
        echo "#SBATCH --mem-per-cpu=4G" >> $child_instance-cube.sh
        echo $command >> $child_instance-solve.sh
        echo $command4 >> $child_instance-solve.sh
        echo $command5 >> $child_instance-cube.sh
        sbatch $child_instance-solve.sh
    done