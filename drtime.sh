#!/bin/sh

drh=~/util/drh

usage()
{
	echo "Description:
	Produce plots of DrHook accumulated total time for a set of routines

Usage:
	drtime.sh FILE [DRFILE] [-w] [-v] [-h]

Options:
	FILE: short text file listing tags (roughly, function names) to be found in DRFILE
	DRFILE: path to a file produced by drh.sh (defaults to 'drtot.txt')
	-v: verbose mode
	-h: print this help message and exit normally

Details:
	FILE is mandatory and is a positional argument (\$1).
	The 1st tag in FILE is considered as a tag which DrHook time encompasses time of all the other tags. On the contrary, times for other tags than this 1st one are considered to be non overlapping times, so that stacking these times has some meaning.
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

flist="$1"
ls $flist >/dev/null
shift

opt=""
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

[ $fic = "drtot.txt" ] || echo "alternate file: $fic"

type R >/dev/null 2>&1 || module load -s intel R >/dev/null 2>&1
R --slave -f $drh/drtime.R --args $flist $fic $opt png
