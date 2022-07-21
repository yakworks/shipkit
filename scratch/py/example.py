#!/usr/bin/env python3
# Python shell script example

import os
import subprocess
import shutil
from pprint import pprint

print("hello world")
# simple way, kicks to console
# os.system('ls -l')
# capture stream of stdout
stream = os.popen('lss -l')
output = stream.read()
print(output)

# Get your current working directly
my_cwd = os.getcwd()
# print(my_cwd)
dir_list = os.listdir()
# for item in dir_list:
#     print(item)
#     command = "echo 'hello'"
#     result = subprocess.run(command.split(' '), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
#     #Print the stdout and stderr
#     print(result.stdout)
#     print(result.stderr)

# for item in dir_list:
#     print(item)
#     command = "echo 'hello'"
#     result = subprocess.run(command.split(' '), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
#     #Print the stdout and stderr
#     print(result.stdout)
#     print(result.stderr)
