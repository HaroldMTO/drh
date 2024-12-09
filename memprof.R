library(mfnode)

Gpar = list(mar=c(2,2,3,1)+.1,mgp=c(2.1,.6,0),tcl=-.3,cex=.83)

args = commandArgs(trailingOnly=TRUE)
patt = args[1]

if (interactive() && capabilities("X11")) {
	cat("--> interactive plots\n")
	png = dev.off = function(...) return(invisible(NULL))
	options(device.ask.default=TRUE)
} else {
	cat("--> no X11 device, sending plots to PNG files\n")
}

cat("List and parse files - pattern:",patt,"\n")
fics = dir(path=dirname(patt),pattern=basename(patt),full.names=TRUE)
if (length(fics) == 0) stop("no file found")

fmem = list()
for (i in seq(along=fics)) {
	nd = readLines(fics[i])
	indm = grep("Mem:",nd)

	val = t(matrix(intlines(nd[indm]),nrow=6))
	fmem[[i]] = val

	indd = grep("(\\d+:){2}\\d+",nd)
	inds = grep("sampling:",nd)
	if (length(indd) == 1 && length(inds) == 1) {
		d = sub("date: *","",nd[indd])
		ns = as.numeric(sub(".+\\.",".",d))
		d = as.POSIXct(d,format="%H:%M:%S")
		freq = as.numeric(sub("sampling: *","",nd[inds]))
		frac = round(ns/freq)*freq
	} else {
		d = frac = 0
		freq = 1
	}

	attr(fmem[[i]],"freq") = freq
	attr(fmem[[i]],"frac") = frac
	attr(fmem[[i]],"date") = d
}

ndim = sapply(fmem,dim)

re = ".+?(\\d+).*"
patt2 = sub("\\d+$","",patt)
if (all(regexpr(re,fics) > 0)) {
	host = as.integer(sub(re,"\\1",fics))
	hostu = unique(host)

	cat("Create PNG graphics for",length(hostu),"hosts\n")
	for (i in seq(along=hostu)) {
		ind = grep(sprintf("%s.*%d.+",patt2,hostu[i]),fics)
		nt = min(ndim[1,ind])
		used = sapply(fmem[ind],function(x) x[1:nt,2])/1024^2
		freq = attr(fmem[[ind[1]]],"freq")
		frac = attr(fmem[[ind[1]]],"frac")
		d1 = attr(fmem[[ind[1]]],"date")+frac
		d = d1+seq(nt)*freq
		tt = c("Memory usage",sprintf("%d processes on host %d",dim(used)[2],hostu[i]))
		png(sprintf("memprof.%s.png",hostu[i]))
		xlab = sprintf("Time (start: %s)",format(d1,"%H:%M:%S"))
		matplot(d,used,type="l",lty=1,main=tt,xlab=xlab,ylab="Memory (Gb)",
			col=grey.colors(4,end=.5),xaxt="n")
		axis.POSIXct(1,d,format="%M:%S")
		grid()
		dev.off()

		if (nt > 20) {
			ix = which.max(diff(rowMeans(used)))
			ntx = nt%/%20
			indx = ix+seq(-ntx,ntx)
			indx = indx[indx > 0 & indx <= nt]
			png(sprintf("memprofx.%s.png",hostu[i]))
			matplot(d[indx],used[indx,],type="l",lty=1,main="Zoom at max",xlab=xlab,
				ylab="Memory (Gb)",col=grey.colors(4,end=.5),xaxt="n")
			axis.POSIXct(1,d[indx],format="%M:%S")
			grid()
			dev.off()
		}
	}
} else {
	ind = seq(along=fmem)
	if (length(ind) > 100) {
		catt("--> limit files to 100 1st ones\n")
		ind = ind[1:100]
	}

	nt = min(ndim[1,ind])
	used = sapply(fmem[ind],function(x) x[1:nt,2])/1024^2
	freq = attr(fmem[[ind[1]]],"freq")
	frac = attr(fmem[[ind[1]]],"frac")
	d1 = attr(fmem[[ind[1]]],"date")+frac
	d = d1+seq(nt)*freq
	png("memprof.png")
	xlab = sprintf("Time (start: %s)",format(d1,"%H:%M:%S"))
	matplot(d,used,type="l",lty=1,main="Used memory",xlab=xlab,
		ylab="Memory (Gb)",col=grey.colors(4,end=.5),xaxt="n")
	axis.POSIXct(1,pretty(d),format="%H:%M:%S")
	grid()
	dev.off()
}
