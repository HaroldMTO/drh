args = commandArgs(trailingOnly=TRUE)

lf1 = strsplit(readLines(args[1]),split=" +")
lf2 = strsplit(readLines(args[2]),split=" +")

f1 = sapply(lf1,"[",1)
f2 = sapply(lf2,"[",1)

t1 = lapply(lf1,function(x) as.numeric(x[-1]))
t2 = lapply(lf2,function(x) as.numeric(x[-1]))

ip = match(c("proc","call","node"),f2)
ntask = length(t2[[ip[1]]])
ntt = max(sapply(t2[-ip],length))
if (ntt %% ntask != 0) warning("some calls are not multiples of tasks")
nt = as.integer(ntt/ntask)

calls = as.integer(t2[[ip[2]]])

if (any(! is.na(ip))) {
	f2 = f2[-na.omit(ip)]
	t2 = t2[-na.omit(ip)]
}

stopifnot(length(f2) == length(calls))

tt = numeric(length(f2))
st = character(length(f2))

for (i in seq(along=f2)) {
	q2 = quantile(t2[[i]],c(0,.5,1))
	tt[i] = q2[3]
	s2 = sprintf("% 8.3f",q2)
	npi = min(ntask,length(t2[[i]]))
	nti = as.integer(length(t2[[i]])/npi)
	sn = nti
	if (npi > 1) sn = sprintf("%dx%d",npi,nti)

	ind = match(tolower(f2[i]),tolower(f1))
	if (is.na(ind)) {
		ind = match(tolower(f2[i]),tolower(gsub("\\w+:","",f1)))
		if (is.na(ind)) {
			st[i] = sprintf("%28s %6d %3s %s",gsub("\\w+:","",f2[i]),calls[i],sn,
				paste(s2,collapse=" "))
			next
		}
	}

	s = sprintf("% 8.3f",q2-quantile(t1[[ind]],c(0,.5,1)))
	st[i] = sprintf("%28s %6d %3s %s %s",gsub("\\w+:","",f2[i]),calls[i],sn,
		paste(s2,collapse=" "),paste(s,collapse=" "))
}

ind = order(tt,decreasing=TRUE)
writeLines(st[ind])
