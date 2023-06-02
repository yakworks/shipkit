# python playground to import into main makefile

# py test
hello: name ?= Bob
hellopy:
	#!py
	print('hello $(name)')

hello:
	#!py
	import os
	from pathlib import Path
	from pprint import pprint
	print('hello $(name)')

	print(os.getcwd())
	os.system("echo Hello from the other side!")
	dir_list = os.listdir()
	for item in dir_list:
	  print(item)

	# Print out all directories, sub-directories and files with os.walk()
	for root, dirs, files in os.walk("docs"):
	  print(f'root: {root}')
	  print("dirs",dirs)
	  print("files",files)

	path = Path()
	for p in path.iterdir():
	  print(p.absolute())
