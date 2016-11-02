#! /bin/bash
index=0;
for filename in `ls --format=commas`; do
   index=$((index + 1))
   echo $index $filename
done
