library(parallel)

files = dir(pattern="drhook\\.prof\\.[1-9]")
nf = length(files)
if (nf > 128) files = files[sample(nf,128+as.integer((nf-128)^.8))]

# convert from lexical to numeric order
procs = as.integer(gsub("drhook\\.prof\\.","",files))
files = files[order(procs)]
procs = sort(procs)

l = vector("list",length(files))
for (i in seq(along=files)) {
	nd = readLines(files[i])
	l[[i]] = grep("\\w+@[0-9]+ *$",nd,value=TRUE)
}

l = unlist(l)

times = sapply(strsplit(l,split=" +"),function(x) as.numeric(x[5:7]))
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
