#!/bin/sh

drh=~/util/drh

usage()
{
	echo "Description:
	Produce a plot of wall-times of routines as measured with DrHook

Usage:
	wall.sh PATTERN [DRFILE] [-w] [-h]

Options:
	PATTERN: pattern for function names to be found in DRFILE
	DRFILE: path to a file produced by drh.sh (defaults to 'drtot.txt')
	-w: consider PATTERN as a whole word
	-h: print this help message and exit normally
"
}

set -e

if echo $* | grep -qE '(^| +)-\w*h'
then
	usage
	exit
elif [ $# -eq 0 ]
then
	usage
	exit 1
fi

fic="drtot.txt"
[ $# -eq 2 ] && fic=$2

ls $fic >/dev/null

type R >/dev/null 2>&1 || module load -s intel R >/dev/null 2>&1

echo $* | grep -qE '(^| +)-\w*w' && word=1
R --slave -f $drh/wall.R --args "$1" $fic $word
