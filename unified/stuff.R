source("dlanalysis/main.R")

load_stuff <- function() {
  tasks = c('rte','zaenen_rte','temp','wsd')
  many_u <<- list()
  many_a <<- list()
  for (t in tasks) {
    msg("Loading",t)
    many_a[[t]] <<- load_categ_anno(paste(t,'.standardized.tsv',sep=''))
    many_u[[t]] <<- agg_to_unit(many_a[[t]])
  }
}

plot_stuff <- function() {
  tasks = c('rte','zaenen_rte','temp','wsd')
  par(mfrow=c(2,2))
  for (t in tasks) {
    print(t)
    plot_vertical_thresh(many_u[[t]], main=paste(t,"(",many_u[[t]]@target," is yes)"), sub="")
  }
}

limit_analyses <- function(lims) {
  par(mfrow=c(4,4))
  for (lim in lims) {
    
    a2=anno_subset(a,limit=lim); u=agg_to_unit(a2); w=worker_an(a2,pseudocount=2^-10); conf=posterior_given_workers(w,a2)[,u@target]
    
    plot_vertical_thresh2(u,list(list("",.5)), conf=u[,u@target]/lim , ylim_auto=T, main=paste("Uncalibrated lim=",lim))
    plot_vertical_thresh2(u,list(list("",0)),conf=conf,ylim_auto=T, main=paste("Worker modeled lim=",lim))
  }
}

analyze_anno <- function(a, ...) {
  u = agg_to_unit(a)
  ret = list()
  ret$raw_acc = mean( u$plurality == u$gold)
  r = xval_by_unit(a,u, ngroup=10, ...)
  ret$calib_acc = mean(r$cv.fit == u$gold)
  ret
}

run_anno_samples <- function(full_a, size=5, replications=10, ...) {
  msg("Running anno samples with",replications,"replications.")
  sapply(1:replications, function(iter) {
    cat("run ",iter,", sampling\n")
    a = timeit(anno_sample_via_workers(full_a, size))
    r = timeit(analyze_anno(a, ...))
    print(r)
    r
  })
}