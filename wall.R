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

fcat = function(...) invisible(return(NULL))
if ("verbose" %in% args) fcat = cat

lt = strsplit(readLines(args[2])," ")
ttime = lapply(lt,function(x) as.numeric(x[-1]))
names(ttime) = tolower(gsub("\\w+:","",sapply(lt,"[",1)))

pattern = args[1]
if ("word" %in% args) pattern = sprintf("\\<%s\\>",args[1])
ind = which(regexpr(tolower(pattern),names(ttime)) > 0)
if (length(ind) == 0) stop(sprintf("pattern '%s' not found",pattern))

ip = match("proc",names(ttime))
stopifnot(! is.na(ip))

procs = ttime[[ip]]
indo = order(procs)
procs = sort(procs)

hasx11 = capabilities("X11")
ask = hasx11 && interactive()

if (! hasx11) cat("--> no X11 device, sending plots to PNG files\n")

nf = length(procs)

for (i in ind) {
	cat("Function",names(ttime)[i],"\n")
	if (all(ttime[[i]] == 0)) {
		cat("--> time=0, no graph\n")
		next
	}

	t2 = ttime[[i]]
	h = max(t2)*c(.75,.9)
	titre = paste("Wall-times for",names(ttime)[i])

	pngalt(sprintf("%s.png",names(ttime)[i]))

	if (length(t2) < length(procs)) {
		fcat(". threads, tasks:",length(t2),length(procs),"\n")
		titre[2] = "1 thread per task"
		plot(t2,type="h",ylim=c(0,max(t2)),main=titre,xlab="MPI task",ylab="Time (s)",
			xaxt="n")
		axis(1,procs[1:length(t2)])
		abline(h=h,lty=2)
		text(1,.99*h,sprintf("%d%%",c(75,90)),cex=.7,pos=3)

		pngoff()
	} else {
		fcat(". threads, tasks:",length(t2)%/%length(procs),length(procs),"\n")
		stopifnot(length(t2) %% length(procs) == 0)

		t2 = matrix(t2,ncol=length(procs))
		t2 = t2[,indo,drop=FALSE]
		op = par(mfrow=c(2,1),cex=.83)

		titre[2] = sprintf("%d threads per task",dim(t2)[1])
		boxplot(t2,range=0,main=titre,xlab="MPI task",ylab="Time (s)",xaxt="n")
		axis(1,seq(along=procs),procs)
		abline(h=h,lty=2)
		text(1,.99*h,sprintf("%d%%",c(75,90)),cex=.7,pos=3)

		pnx = apply(t2,2,function(x) diff(range(x))/max(x))
		ix = which.max(pnx)
		titre = sprintf("Wall times for threads, task #%d",ix)
		plot(t2[,ix],type="h",ylim=c(0,max(t2[,ix])),main=titre,xlab="Unordered threads",
			ylab="Time (s)")
		h1 = max(t2[,ix])*c(.75,.9)
		abline(h=h1,lty=2)
		text(1,.99*h1,sprintf("%d%%",c(75,90)),cex=.7,pos=3)

		pngoff(op)
	}
}
