MAKEFLAGS += --no-print-directory

# ne pas mettre ~ pour P : il faut un chemin absolu
P = $(HOME)/proc/drh
B = ~/bin

.PHONY: all install drh

all:

install:
	! git status --porcelain 2>/dev/null | grep -qvE "^\?\? "
	make drh
	make $B/drh.sh
	make $B/drdiff.sh
	make $B/wall.sh
	make $B/mem.sh
	if git status >/dev/null 2>&1; then \
		grep -q $(shell git log -1 --pretty=format:%h 2>/dev/null) $P/version || \
			git log -1 --oneline >> $P/version; \
	fi

drh:
	mkdir -p $P
	cp -uv cpu.R drdiff.R wall.R mem.R memprof.R drtime.R $P

$B/drh.sh: drh.sh
	sed -re "s:drh=.+:drh=$P:" drh.sh > $B/drh.sh
	chmod a+x $B/drh.sh

$B/drdiff.sh: drdiff.sh
	sed -re "s:drh=.+:drh=$P:" drdiff.sh > $B/drdiff.sh
	chmod a+x $B/drdiff.sh

$B/wall.sh: wall.sh
	sed -re "s:drh=.+:drh=$P:" wall.sh > $B/wall.sh
	chmod a+x $B/wall.sh

$B/drtime.sh: drtime.sh
	sed -re "s:drh=.+:drh=$P:" drtime.sh > $B/drtime.sh
	chmod a+x $B/drtime.sh

$B/mem.sh: mem.sh
	sed -re "s:drh=.+:drh=$P:" mem.sh > $B/mem.sh
	chmod a+x $B/mem.sh

$B/memprof.sh: memprof.sh
	sed -re "s:drh=.+:drh=$P:" memprof.sh > $B/memprof.sh
	chmod a+x $B/memprof.sh
