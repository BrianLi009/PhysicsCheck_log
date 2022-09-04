#!/bin/bash
#SBATCH --array={specify the cubes to be solved}
#SBATCH --time=60:00:00
#SBATCH --account={account name}
#SBATCH --mem=2G
./simplification/adjoin-cube-simplify.sh 21 constraints_21_60_2_2.simp2 23.cubes $SLURM_ARRAY_TASK_ID 50
./maplesat-ks/simp/maplesat_static 23.cubes$SLURM_ARRAY_TASK_ID.adj.simp -no-pre -exhaustive=21-$SLURM_ARRAY_TASK_ID.exhaust -order=21
