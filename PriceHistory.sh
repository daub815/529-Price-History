#!/bin/bash

currentDir=$(pwd)
cd /Users/kevin/Documents/Development/PriceHistory/

echo $(which perlbrew)

export PERLBREW_ROOT=/Users/kevin/perl5/perlbrew
source ${PERLBREW_ROOT}/etc/bashrc

perlbrew use perl-5.20.1
echo $(which perl)

last=$(cat lastDate.txt)

if [ -z "$last" ]; then
	last=$(date +%m/%d/%Y)
fi

today=$(date -v -1d +%m/%d/%Y)

echo "Last Date: $last"
echo "Today's Date: $today"

perl PriceHistory.pl --startDate $last --endDate $today

echo "$today" > lastDate.txt 

perlbrew off

cd $currentDir
