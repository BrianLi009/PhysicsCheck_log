#!/bin/bash

[ "$1" = "-h" -o "$1" = "--help" ] && echo "
Description:
    This script generate cubes for the instance using the incremental cubing technique, then adjoin the deepest cubing file with the instance
    line by line, creating multiple separate instances with a cube embedded in it. Then maplesat-ks is being called to solve each instance (in parallel).

Usage:
    ./3-cube-merge-solve.sh n r f

Options:
    <n>: the order of the instance/number of vertices in the graph
    <r>: number of variables to eliminate before cubing is terminated
    <f>: file name of the current SAT instance
" && exit
 
n=$1 #order
r=$2 #number of variables to eliminate
f=$3 #instance file name

./gen_cubes/cube.sh $n $f $r #cube till r varaibles are eliminated

#find the deepest cube file
cube_file=$(find . -type f -wholename "./$n-cubes/*.cubes" -exec grep -H -c '[^[:space:]]' {} \; | sort -nr -t":" -k2 | awk -F: '{print $1; exit;}')

cp $(echo $cube_file) .

cube_file=$(echo $cube_file | sed 's:.*/::')

numline=$(< $cube_file wc -l)
new_index=$((numline-1))
echo "#!/bin/bash" > join-solve-$n.sh
echo "#SBATCH --array=0-${new_index}" >> join-solve-$n.sh
echo "#SBATCH --time=03:00:00" >> join-solve-$n.sh #can modify runtime based on instance size
echo "#SBATCH --account=def-janehowe" >> join-solve-$n.sh
echo "#SBATCH --mem=2G" >> join-solve-$n.sh #can modify memory based on instance size
echo "./simplification/adjoin-cube-simplify.sh $n $f $cube_file \$SLURM_ARRAY_TASK_ID 50" >> join-solve-$n.sh
#join the cube to the instance, simplified until 50% of the variables are eliminated
echo "./maplesat-ks/simp/maplesat_static $cube_file\$SLURM_ARRAY_TASK_ID.adj.simp -no-pre -exhaustive=$n-\$SLURM_ARRAY_TASK_ID.exhaust -order=$n" >> join-solve-$n.sh

sbatch join-solve-$n.sh
