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

Details:
	PATTERN is mandatory and is a positional argument (\$1).
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

patt="$1"
shift

opt=""
echo " $*" | grep -q ' -w' && opt="word"
echo " $*" | grep -q ' -v' && opt="$opt verbose"

fic=drtot.txt
while [ $# -gt 0 ]
do
	if [ -s "$1" ]
	then
		fic=$1
		break
	fi

	shift
done

ls $fic >/dev/null

type R >/dev/null 2>&1 || module load -s intel R >/dev/null 2>&1
R --slave -f $drh/wall.R --args "$patt" $fic $opt png
