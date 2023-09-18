Gpar = list(mar=c(4,4,3,2)+.1,mgp=c(2.5,.8,0),cex=.9)

ftag = c("ifs_init","su0yoma","su0yomb","cnt3_glo","iopack","transinvh","scan2m",
	"obsv","transdirh","spcm","gpnspng","fullpos_drv")
ftag2 = c("ifsinit","su0ya","su0yb","cnt3","iopack","trinvh","scan2m","obsv","trdirh",
	"spcm","gpspng","fposdrv")
ftage = c("etransinvh","relaxgp","ecoupl1","etransdirh","espcm","gpiau")
ftage2 = c("etrinvh","relax","ecoupl","etrdirh","espcm","gpiau")

pngalt = function(...)
{
	if (ask && ! is.null(dev.list())) invisible(readline("Press enter to continue"))

	if (! hasx11) {
		stopifnot(is.null(dev.list()))
		png(...)
	}
}

pngoff = function(op)
{
	if (! hasx11) {
		invisible(dev.off())
	} else if (! missing(op)) {
		par(op)
	}
}

args = commandArgs(TRUE)

df = read.table(args[1],col.names=c("tag","tag2"))

fcat = function(...) invisible(return(NULL))
if ("verbose" %in% args) fcat = cat

lt = strsplit(readLines(args[2])," ")
ttime = lapply(lt,function(x) as.numeric(x[-1]))
names(ttime) = tolower(gsub("\\w+:","",sapply(lt,"[",1)))
ip = match(c("proc","node"),names(ttime))
stopifnot(! is.na(ip[1]))

procs = ttime[[ip[1]]]
indo = order(procs)
procs = sort(procs)
if (is.na(ip[2])) {
	nodes = rep(1,length(procs))
} else {
	nodes = ttime$node[indo]
}

im = match(df[1,1],names(ttime))
if (is.na(im)) stop(sprintf("tag '%s' not present",df$tag[1]))

tm = ttime[[im]]
s = sprintf("Time range for tag '%s' (min/max): %.4g %.4g",df$tag[1],min(tm),max(tm))

df = df[-1,]
it = na.omit(match(df$tag,names(ttime)))

ntt = sapply(ttime[it],length)
if (all(ntt == length(procs))) {
	m = simplify2array(ttime[it])
} else {
	lm = lapply(ttime[it],matrix,ncol=length(procs))
	for (i in seq(along=lm)) lm[[i]] = apply(lm[[i]],2,max)
	m = simplify2array(lm)
}

if (length(na.action(it)) > 0) {
	cat("--> tags not found:",df$tag[na.action(it)],"\n")
	dimnames(m)[[2]] = df$tag2[-na.action(it)]
} else {
	dimnames(m)[[2]] = df$tag2
}

mx = apply(m,2,max)
it0 = which(mx < min(tm)/100)
if (length(it0) > 0) {
	if (length(it0) == length(mx)) it0 = it0[-which.max(mx)]
	f = dimnames(m)[[2]]
	cat("--> zap short functions:",f[it0],"\n")
	m = m[,-it0]
}

# filter procs: keep those of min/max times, repeat until 150 bars
indp = seq(along=procs)
if (length(procs)*dim(m)[2] > 150) {
	indn = sort(unique(apply(m,2,which.min)))
	indx = sort(unique(apply(m,2,which.max)))
	indp = sort(unique(c(indn,indx)))

	# grow indp up to have 150 bars and sufficient remaining rows
	nrowmin = dim(m)[1]-dim(m)[2]
	while (length(indp)*dim(m)[2] <= 150 && length(indn) < nrowmin &&
		length(indx) < nrowmin) {
		indn = sort(unique(c(indn,apply(m[-indn,],2,which.min))))
		indx = sort(unique(c(indx,apply(m[-indx,],2,which.max))))
		indp = sort(unique(c(indp,indn,indx)))
	}

	m = m[indp,,drop=FALSE]
}

hasx11 = ! "png" %in% args && capabilities("X11")
ask = hasx11 && interactive()

if (! capabilities("X11")) cat("--> no X11 device, sending plots to PNG files\n")

prefix = sub("(./)?(\\w+)(.\\w+)?","\\2",args[1])
fcat("prefix for plot files:",prefix,"(PNG)\n")
pngalt(sprintf("%stask.png",prefix))
op = par(Gpar)
barplot(m,beside=TRUE,main=c(sprintf("DrHook total time by task, group %s",prefix),s),
	ylab="Time (s)",cex.names=.9)
pngoff(op)

pngalt(sprintf("%ssum.png",prefix))
op = par(Gpar)
ms = rowSums(m)
f = dimnames(m)[[2]]
x = barplot(t(m),names.arg=indp,legend.text=f,col=seq(along=f)+1,
	main=c(sprintf("DrHook total time by task, group %s",prefix),s),
	xlab="MPI task (guessed)",ylab="Time (s)",ylim=c(0,1.05*max(ms)),cex.names=.83,
	args.legend=list(x="top",horiz=TRUE))
nn3 = 3*max(nodes)
text(x,max(ms)/2*(1-(nodes[indp]-1)/nn3),nodes[indp],cex=.8)
pngoff(op)
