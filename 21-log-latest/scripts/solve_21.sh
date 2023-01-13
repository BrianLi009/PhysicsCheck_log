#!/bin/bash
#SBATCH --account=def-vganesh
#SBATCH --time=0-20:00
#SBATCH --mem-per-cpu=2G
#SBATCH --array=0-630

./simplification/adjoin-cube-simplify.sh 21 constraints_21_v_60_2_2.simp2 23.cubes ${SLURM_ARRAY_TASK_ID} 50
./maplesat-ks/simp/maplesat_static 23.cubes${SLURM_ARRAY_TASK_ID}.adj.simp -no-pre -exhaustive=21-${SLURM_ARRAY_TASK_ID}.exhaust -order=21
