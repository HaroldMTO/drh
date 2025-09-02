#!/bin/sh

drh=~/util/drh

usage()
{
	echo "Description:
	Produce files comparing self and total times (DrHook) between 2 runs of ARPIFS binaries

Usage:
	drdiff.sh DIR1 [DIR2] [-f] [-h]

Options:
	DIR[i] are directories containing files produced by drh.sh (drself.txt and drtot.txt)
	DIR1 points to the reference job, DIR2 points to the job to compare (default: '.')
	-f: force the update of self.txt and tot.txt, disregarding timestamp
	-h: print this help and exit normally"
}

set -e

d1=""
d2=""
alias force=false

while [ $# -ne 0 ]
do
	case $1 in
	-f) alias force=true;;
	-h)
		usage
		exit
		;;
	*)
		if [ -z "$d1" ]
		then
			d1=$1
		elif [ -z "$d2" ]
		then
			d2=$1
		fi
		;;
	esac

	shift
done

if [ -z "$d1" ]
then
	echo "error: see 'drdiff.sh -h' for help" >&2
	exit 1
fi

[ -z "$d2" ] && d2=.

ls -d $d1 $d2 >/dev/null

if [ $d1/drself.txt -nt self.txt ] || [ $d2/drself.txt -nt self.txt ] || force
then
	type R >/dev/null 2>&1 || module load -s intel R >/dev/null 2>&1

	R --slave -f $drh/drdiff.R --args $d1/drself.txt $d2/drself.txt > self.txt
	R --slave -f $drh/drdiff.R --args $d1/drtot.txt $d2/drtot.txt > tot.txt
fi
