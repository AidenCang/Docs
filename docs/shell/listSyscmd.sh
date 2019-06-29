#!/usr/bin/env bash
echo $#

echo $*

echo $$

echo $!

echo $@

echo $-

echo $?

for file in `ls /etc | grep find`;
do
  echo ${file}

done

val=`expr 2 + 2`
echo "两数之和为 : $val"
