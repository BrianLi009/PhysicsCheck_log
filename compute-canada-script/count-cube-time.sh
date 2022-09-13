#!/bin/bash

"""
Computing the cubing time, call with ./count-cube-time.sh <filename>
"""

f=$1

echo $f

touch "$f"_count.log

grep 'c time' $f | cut -d = -f 2 | cut -d ' ' -f 2 >> "$f"_count.log

awk '{s+=$1} END {print s}' "$f"_count.log