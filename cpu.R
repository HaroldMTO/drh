library(parallel)

# guess node number by threads binding
node = NULL
if (file.exists("linux_bind.txt")) {
	nd = readLines("linux_bind.txt")
	l = strsplit(nd,":")
	thread = sapply(l,function(x) regexpr("1",x)[1])
	node = -thread
	inode = 1
	while (TRUE) {
		it = duplicated(node,seq(inode))
		i = node <= 0
		if (all(! i)) break
		node[i & ! it] = inode
		inode = inode+1
	}
} else {
	cat("--> no file linux_bind.txt\n")
}

args = strsplit(commandArgs(trailingOnly=TRUE),split="=")
cargs = lapply(args,function(x) unlist(strsplit(x[-1],split=":")))
names(cargs) = sapply(args,function(x) x[1])

files = dir(path=cargs$path,pattern="drhook\\.prof\\.[0-9]")
off = 0
if (any(basename(files) == "drhook.prof.0")) off = 1

nf = length(files)

N = 128
if ("nfiles" %in% names(cargs)) {
	N = as.integer(cargs$nfiles)
	if (N == 0) N = nf
}

if (N < nf) {
	#ind = sample(nf,N+as.integer((nf-N)^.8))
	ind = sample(nf,N+as.integer(sqrt(nf-N)))
	cat("--> selecting",length(ind),"files among",nf,"initial file list\n")
	files = files[ind]
}

# convert from lexical to numeric order
procs = off+as.integer(gsub("drhook\\.prof\\.","",files))

files = files[order(procs)]
procs = sort(procs)

cat("Read",nf,"DrHook files\n")
l = lf = vector("list",length(files))
for (i in seq(along=files)) {
	nd = readLines(paste(cargs$path,files[i],sep="/"))
	l[[i]] = grep("\"?[a-z]\\w+\"?@[0-9]+(:.+)? *$",nd,ignore.case=TRUE,value=TRUE)
	l[[i]] = gsub("\\w+>|\"|odb\\w+ - +|:\\w+\\.[hc]$","",l[[i]])
	l[[i]] = gsub("(\\w+):@?","\\1:",l[[i]])
	l[[i]] = gsub(": +",":",l[[i]])
	stopifnot(all(regexpr("[a-z]\\w+@\\d+ *$",l[[i]],ignore.case=TRUE) > 0))
	#lt[[i]] = sapply(strsplit(gsub("^ +","",l[[i]]),split=" +"),function(x) as.numeric(x[4:6]))
	lf[[i]] = sapply(l[[i]],substring,97,USE.NAMES=FALSE)
}

l = unlist(l)

times = sapply(strsplit(gsub("^ +","",l),split=" +"),function(x) as.numeric(x[4:6]))
funs = unlist(lf)
stopifnot(all(regexpr("(\\w+[:%])*\\w+@\\d+$",funs) > 0))
#funs = sapply(strsplit(l,split="  +"),"[",10)
#funs = gsub(": +",":",sapply(l,substring,97,USE.NAMES=FALSE))
cat("Nb of functions-threads:",length(funs),"\n")

#foncs = unique(sort(gsub("\\*?((\\w+: *)?\\w+)@[0-9]+","\\1",funs)))
foncs = unique(sort(gsub("((\\w+: *)*\\w+)@[0-9]+","\\1",funs)))

cat("Nb of functions:",length(foncs),"\n")

ntask = function(f) length(which(sapply(lf,function(fun) any(regexpr(f,fun) > 0))))
ntaskf = unlist(mclapply(foncs,ntask,mc.cores=16))

cons = file(sprintf("%s/drself.txt",cargs$path),open="w")
cont = file(sprintf("%s/drtot.txt",cargs$path),open="w")

cat("proc",procs,"\n",file=cons)
cat("proc",procs,"\n",file=cont)

if (! is.null(node)) {
	node = node[procs]
	cat("node",node,"\n",file=cons)
	cat("node",node,"\n",file=cont)
}

#indf = vector("integer",length(foncs))

sfoncs = sprintf("\\<%s@",foncs)
lind = mclapply(sfoncs,grep,funs,mc.cores=16)
indf = sapply(lind,"[",1)
times = t(times)
cat("call",times[indf,3],"\n",file=cons)
cat("call",times[indf,3],"\n",file=cont)
cat("ntask",ntaskf,"\n",file=cons)
cat("ntask",ntaskf,"\n",file=cont)

for (i in seq(along=foncs)) {
	cat(foncs[i],times[lind[[i]],1],"\n",file=cons)
	cat(foncs[i],times[lind[[i]],2],"\n",file=cont)
}

close(cons)
close(cont)
