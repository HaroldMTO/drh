#!/bin/sh

drh=~/util/drh

usage()
{
	echo "Description:
	Produce a plot of wall-times of routines as measured with DrHook

Usage:
	wall.sh PATTERN [DRFILE] [-w] [-v] [-h]

Options:
	PATTERN: pattern for function names to be found in DRFILE
	DRFILE: path to a file produced by drh.sh (defaults to 'drtot.txt')
	-w: consider PATTERN as a whole word
	-v: verbose mode
	-h: print this help message and exit normally
"
}

set -e

if echo " $*" | grep -qE ' -h'
then
	usage
	exit
elif [ $# -eq 0 ]
then
	usage
	exit 1
fi

opt="drtot.txt"
[ $# -ge 2 -a -s "$2" ] && opt=$2 || opt="drtot.txt"

ls $fic >/dev/null

type R >/dev/null 2>&1 || module load -s intel R >/dev/null 2>&1

echo " $*" | grep -q ' -w' && opt="$opt word"
echo " $*" | grep -q ' -v' && opt="$opt verbose"
R --slave -f $drh/wall.R --args "$1" $opt
