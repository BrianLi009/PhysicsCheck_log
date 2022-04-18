#!/usr/bin/env python

import sys

if len(sys.argv) <= 2:
    print("Need order and filename of exhaustive output to read")
    print("Use -v for more verbose output and -q for less verbose output")
    quit()

if "-v" in sys.argv:
    verbose = True
    sys.argv.remove("-v")
else:
    verbose = False

if "-q" in sys.argv:
    quiet = True
    sys.argv.remove("-q")
else:
    quiet = False

n = int(sys.argv[1])
f = open(sys.argv[2], "r")

def print_matrix(M, n):
    for i in range(n):
        rowsum = 0
        st = ""
        for j in range(n):
            if i > j:
                st += str(M[j][i])
                rowsum += M[j][i]
            else:
                st += str(M[i][j])
                rowsum += M[i][j]
        print(st, rowsum)

def num_edges(M, n):
    edge_count = 0
    for i in range(n):
        for j in range(i):
            if M[j][i] == 1:
                edge_count += 1
    return edge_count

def degree_sequence(M, n):
    st = ""
    for i in range(n):
        rowsum = 0
        for j in range(n):
            if i > j:
                rowsum += M[j][i]
            else:
                rowsum += M[i][j]
        st += str(rowsum) + " "
    return st[:-1]

def max_degree(M, n):
    max_rowsum = 0
    for i in range(n):
        rowsum = 0
        for j in range(n):
            if i > j:
                rowsum += M[j][i]
            else:
                rowsum += M[i][j]
        if rowsum > max_rowsum:
            max_rowsum = rowsum
    return max_rowsum

def min_degree(M, n):
    min_rowsum = n
    for i in range(n):
        rowsum = 0
        for j in range(n):
            if i > j:
                rowsum += M[j][i]
            else:
                rowsum += M[i][j]
        if rowsum < min_rowsum:
            min_rowsum = rowsum
    return min_rowsum

min_edges = n*n
max_edges = 0
min_deg = n
max_deg = 0
total_edges = 0
count = 0

for line in f.readlines():
    M = [[0 for j in range(n)] for i in range(n)]
    i = 0
    j = 1
    for v in line.split(" ")[1:-1]:
        if int(v) > 0:
            M[i][j] = 1
        i += 1
        if i == j:
            i = 0
            j += 1

    assert(n == j)

    if verbose:
        print_matrix(M, j)

    if quiet == False:
        print("Edges: " + str(num_edges(M, j)) + " | Degrees: " + degree_sequence(M, j) + " | Min: " + str(min_degree(M, j)) + " | Max: " + str(max_degree(M, j)))

    if verbose:
        print("")

    count += 1
    total_edges += num_edges(M, j)

    if min_edges > num_edges(M, j):
        min_edges = num_edges(M, j)
    if max_edges < num_edges(M, j):
        max_edges = num_edges(M, j)

    if min_deg > min_degree(M, j):
        min_deg = min_degree(M, j)
    if max_deg < max_degree(M, j):
        max_deg = max_degree(M, j)

f.close()

if quiet == False and verbose == False:
    print("")

print("Order {0} Stats".format(n))
print("Min Edges: {0} | Max Edges: {1} | Min Degree: {2} | Max Degree: {3} | Avg Degree: {4}".format(min_edges, max_edges, min_deg, max_deg, 2*total_edges/(n*count)))
