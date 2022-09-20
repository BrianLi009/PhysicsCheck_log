import sys
import os
from subprocess import call
import time
def solve_line(n):
    n = int(n)
    f = open('squarefree_10.exhaust')
    lines = f.readlines()
    line = lines[n]
    start_time = time.time()
    #command = "python3 main.py " + str(line) + "10 0 0 0 nonembed_graph_sat_$n.txt embed_graph_sat_$n.txt 0 0"
    #os.system(command)
    call(['python', 'main.py', str(line), "10", "0", "0", "0", "nonembed_graph_sat_10.txt", "embed_graph_sat_10.txt", "0", "0"])
    runtime = time.time() - start_time
    file_object = open('runtime_10.txt', 'a')
    file_object.write(str(n) + ": " + str(runtime) + "\n")
    # Close the file
    file_object.close()
    

if __name__ == "__main__":
	solve_line(sys.argv[1])
