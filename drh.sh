#!/bin/sh

drh=~/util/drh

set -e

if echo $* | grep -qE '(^| +)-\w*h'
then
	echo "Description:
	Gather DrHook profiling data in a couple of text files (namely drself.txt \
and drtot.txt), mainly for subsequent processing by drdiff.sh

Usage:
	drh.sh [DIR] [-n N] [-f] [-h]

Options:
	DIR: path to a directory with 'drhook.prof' files (default: current directory)
	-n: restrict input file list to N 1st ones
	-f: force execution, even when drself.txt is newer than drhook.prof.1

Details:
	Files produced are not updated when profiling files (namely drhook.prof.1) \
are newer than a previously produced drself.txt, except when option '-f' is used."
	exit
fi

nfiles=0
force=0
dir=""

while [ $# -ne 0 ]
do
	case $1 in
		-n)
			nfiles=$2
			shift
			;;
		-f)
			force=1
			;;
		-h)
			;;
		*)
			if [ "$dir" ]
			then
				echo "Error: unknown option '$1'" >&2
				exit 1
			fi

			dir=$1
			;;
	esac

	shift
done

if [ "$dir" ] && echo "$dir" | grep -qE '[^ ] [^ ]'
then
	echo "Error: no space authorized in directory" >&2
	exit 1
else
	(cd "$dir" >/dev/null)
	dir=.
fi

drhp=$(find $dir -name drhook.prof.\* | sort | head -1)
if [ -z "$drhp" ]
then
	echo "--> no Dr Hook profiling files in '$dir'" >&2
	exit
fi

if [ ! -s drself.txt ] || [ $drhp -nt drself.txt ] || [ $force -eq 1 ]
then
	type R >/dev/null 2>&1 || module load -s intel R >/dev/null 2>&1

	R --slave -f $drh/cpu.R --args path=$dir nfiles=$nfiles
fi

