Gpar = list(mar=c(2,2,3,1)+.1,mgp=c(2.1,.6,0),tcl=-.3,cex=.83)

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

args = commandArgs(trailingOnly=TRUE)
node = args[1]

cat(". CPU graphics for file",args[2],"on node",node,"\n")
nd = readLines(args[2])
ind = grep("ectrans",nd)

l = strsplit(sub("^ +","",nd[ind]),split=" +")
pids = unique(as.integer(sapply(l,"[",1)))
pid = as.integer(sapply(l,"[",1))
cpu = as.numeric(sapply(l,"[",9))
virt = sapply(l,"[",5)
virt = sub("(\\d)$","\\1/1024^3",virt)
virt = sub("kb$","/1024^2",virt,ignore.case=TRUE)
virt = sub("mb$","/1024",virt,ignore.case=TRUE)
virt = sub("g$","",virt,ignore.case=TRUE)
virt = sapply(parse(text=virt),eval)

# some tasks may be missing (already ended)
nt = min(sapply(pids,function(x) length(which(pid==x))))

np = length(pids)
mcpu = mvirt = matrix(nrow=nt,ncol=np)

for (i in seq(along=pids)) {
	ii = which(pid == pids[i])
	length(ii) = nt
	mcpu[,i] = cpu[ii]
	mvirt[,i] = virt[ii]
}

hasx11 = capabilities("X11") && interactive()
ask = hasx11
if (! hasx11) cat("--> no X11 device, sending plots to PNG files\n")

leg = paste("pid",pids)
if (np > 4) leg = c(paste("pid",pids[1:4]),"...")

pngalt(sprintf("mem.%s.png",node))
op = par(Gpar,mfrow=c(3,1))

dt = .2
xlab = "Event 'top --delay=0.2s'"

ti = seq(dim(mcpu)[1])
matplot(ti,mcpu,type="l",main=c("CPU activity (workload)",node),xlab=xlab,
	ylab="CPU load (%)",lty=1,xaxt="n",yaxt="n")
axis(1,pretty(ti,high.u.bias=0))
axis(2,pretty(mcpu,high.u.bias=0))
legend("topleft",leg,lty=1,col=seq(along=leg),inset=.01)
abline(h=100,col="grey",lty=2)

ti = seq(dim(mvirt)[1])
matplot(ti,mvirt,type="l",main=c("Virtual memory usage",node),xlab=xlab,
	ylab="Memory (Gb)",lty=1,xaxt="n",yaxt="n")
axis(1,pretty(ti,high.u.bias=0))
axis(2,pretty(mvirt,high.u.bias=0))
legend("topleft",leg,lty=1,col=seq(along=leg),cex=.8,inset=.01)

if (! file.exists(args[3])) {
	plot(1,type="n",main=c("GPU memory usage",""),xlab="",ylab="",xaxt="n",yaxt="n")
	text(1,1,"no GPU file",col=2)
	pngoff(op)
	quit("no")
}

cat(". GPU graphics\n")
nd = readLines(args[3])
l = strsplit(sub("^ +","",nd),split=",")
gpus = unique(as.integer(sapply(l,"[",1)))
gpu = as.integer(sapply(l,"[",1))
mem = sapply(l,"[",2)
mem = sub("mib$","/1024",mem,ignore.case=TRUE)
mem = sapply(parse(text=mem),eval)

np = length(gpus)
nt = length(l)/np
mmem = matrix(nrow=nt,ncol=np)
for (i in seq(along=gpus))  mmem[,i] = mem[gpu == gpus[i]]

leg = paste("GPU",gpus)
if (np > 4) leg = c(paste("GPU",gpus[1:4]),"...")

xlab = "Event 'nvidia-smi --delay=0.2s'"
ti = seq(dim(mmem)[1])
matplot(mmem,type="l",main=c("GPU memory usage",node),xlab=xlab,ylab="Memory (Gb)",
	lty=1,xaxt="n",yaxt="n")
axis(1,pretty(ti,high.u.bias=0))
axis(2,pretty(mmem,high.u.bias=0))
legend("topleft",leg,lty=1,col=seq(along=leg),cex=.8,inset=.01)
pngoff(op)
