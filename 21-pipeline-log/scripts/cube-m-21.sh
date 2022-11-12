#!/bin/bash
#SBATCH --account=def-vganesh
#SBATCH --ntasks=32
#SBATCH --mem-per-cpu=1G
#SBATCH --time=0-12:00

./gen_cubes/cube.sh -p -m 21 constraints_21_v_60_2_2.simp2 75
