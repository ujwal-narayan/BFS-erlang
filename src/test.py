import os
import sys

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

modulen = sys.argv[1]
os.system("erlc {}.erl".format(modulen))
os.system("g++ checker.cpp -o check.out")
open('Times.txt', 'w').close()
if not os.path.exists('out'):
    os.makedirs('out')

print(f"{bcolors.OKBLUE}Compiled{bcolors.ENDC}")
directory = '../testcases/input/'
i = 0
for filename in sorted(os.listdir(directory)):
	print(f"{bcolors.OKBLUE}Running Test {i}{bcolors.ENDC}")
	status = os.system("erl -noshell -s '{}' 'main' -s init stop < {} > ./out/{}.my".format(modulen, directory + filename, filename[:-3]))
	if status != 0:
		print(f"{bcolors.FAIL}Test {i} Failed{bcolors.ENDC}")
	else:
		status = os.system("cat {} ../testcases/nline ./out/{}.my | ./check.out".format(directory+filename,filename[:-3]))
		if status != 0:
			print(f"{bcolors.FAIL}Test {i} Failed{bcolors.ENDC}")
		else:
			print(f"{bcolors.OKGREEN}Test {i} Passed{bcolors.ENDC}")

	i+=1
