library(parallel)

# guess node number by threads binding
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

args = strsplit(commandArgs(trailingOnly=TRUE),split="=")
cargs = lapply(args,function(x) unlist(strsplit(x[-1],split=":")))
names(cargs) = sapply(args,function(x) x[1])

files = dir(pattern="drhook\\.prof\\.[0-9]")
nf = length(files)

ind = seq(along=node) %in% procs
if (any(! ind)) cat("--> DrHook files missing for procs:",which(! ind),"\n")

if ("nfiles" %in% names(cargs) && (N=as.integer(cargs$nfiles)) > 0 && N < nf) {
	ftask = as.integer(gsub("drhook\\.prof\\.","",files))
	files = files[ftask <= N]
	nf = length(files)
	cat("--> limiting files to",nf,"1st ones\n")
}

if (nf > 128) {
	cat("--> selecting 128 files among",nf,"initial file list\n")
	ind = sample(nf,128+as.integer((nf-128)^.8))
	files = files[ind]
} else {
	cat("-->",nf,"DrHook files read\n")
}

# convert from lexical to numeric order
procs = as.integer(gsub("drhook\\.prof\\.","",files))

files = files[order(procs)]
node = node[sort(procs)]
procs = sort(procs)

l = vector("list",length(files))
for (i in seq(along=files)) {
	nd = readLines(files[i])
	l[[i]] = grep("\\w+@[0-9]+ *$",nd,value=TRUE)
}

l = unlist(l)

times = sapply(strsplit(gsub("^ +","",l),split=" +"),function(x) as.numeric(x[4:6]))
#funs = sapply(strsplit(l,split="  +"),"[",10)
funs = gsub(": +",":",sapply(l,substring,97,USE.NAMES=FALSE))
cat("Nb of functions-threads:",length(funs),"\n")

#foncs = unique(sort(gsub("\\*?((\\w+: *)?\\w+)@[0-9]+","\\1",funs)))
foncs = unique(sort(gsub("((\\w+: *)*\\w+)@[0-9]+","\\1",funs)))
cat("Nb of functions:",length(foncs),"\n")

cons = file("drself.txt",open="w")
cont = file("drtot.txt",open="w")

cat("proc",procs,"\n",file=cons)
cat("proc",procs,"\n",file=cont)
cat("node",node,"\n",file=cons)
cat("node",node,"\n",file=cont)

indf = vector("integer",length(foncs))

sfoncs = sprintf("\\<%s@",foncs)
lind = mclapply(sfoncs,grep,funs,mc.cores=8)
indf = sapply(lind,"[",1)
times = t(times)
cat("call",times[indf,3],"\n",file=cons)
cat("call",times[indf,3],"\n",file=cont)

for (i in seq(along=foncs)) {
	cat(foncs[i],times[lind[[i]],1],"\n",file=cons)
	cat(foncs[i],times[lind[[i]],2],"\n",file=cont)
}

close(cons)
close(cont)
