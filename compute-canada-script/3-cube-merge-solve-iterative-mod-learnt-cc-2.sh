#!/bin/bash

n=$1 #order
f=$2 #instance file name
d=$3 #directory to store into
v=$4 #num of var to eliminate during first cubing stage
t=$5 #num of conflicts for simplification
a=$6 #amount of additional variables to remove for each cubing call
c=$7 #total number of cores available
timeout=$8 #number of timeout cubes (used to determine cube distribution)

#new implementation should do the following in order:
#parameters: cube file, # of cores to be used = cpu
#1. input a cube file, determine total number of cubes n (done currently)
#2. compute number of cubes that need to be solved on each core, which is cpu/n = c 
#3. core n solve cubes if index mod cpu == n
#4. once all cubes are terminated, adjoin all unsolved cubes to create the next cube file, submit parallized job to further cube them

#we want the script to: cube, for each cube, submit sbatch to solve, if not solved, call the script again

c=$(((c + timeout / 2) / timeout))

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
