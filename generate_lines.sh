#!/bin/bash

for folder in derivate_branch_files master_branch_files common_files
do
	[ ! -d $folder ] && mkdir $folder
	for line in $(seq 1 1000)
	do 
		echo $line $folder >> $folder/file.log
	done
done
