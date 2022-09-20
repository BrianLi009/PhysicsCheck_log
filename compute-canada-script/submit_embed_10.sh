#!/bin/bash
#SBATCH --array=0-723
#SBATCH --time=00:10:00
#SBATCH --account=def-vganesh
#SBATCH --mem=2GB

start=$((SLURM_ARRAY_TASK_ID*7))
end=$((start + 6))
for i in $(seq $start $end)
do
	python3 driver_10.py $i
done
