#!/bin/bash
#SBATCH --account=def-vganesh
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --mem-per-cpu=2G
#SBATCH --time=0-12:00
./gen_cubes/cube.sh -p 22 constraints_22_60_2_2.simp2 90 23
