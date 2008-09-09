source("dlanalysis/main.R")   # symlink please, github.com/brendano/dlanalysis

load_stuff <- function() {
  tasks = c('rte','zaenen_rte','temp','wsd')
  many_u <<- list()
  many_a <<- list()
  for (t in tasks) {
    msg("Loading",t)
    many_a[[t]] <<- load_categ_anno(paste('data/',t,'.standardized.tsv',sep=''))
    many_u[[t]] <<- agg_to_unit(many_a[[t]])
  }
  for (t in c('anger','disgust','fear','joy','sadness','surprise','valence','wordsim')) {
    many_a[[t]] <<- load_numeric_anno(paste('data/',t,'.standardized.tsv',sep=''))
  }
}

load_affect <- function(valence=FALSE) {
  a=list()
  tasks = c('anger','disgust','fear','joy','sadness','surprise')
  if (valence) tasks=c(tasks,'valence')
  # for (t in c('valence','anger','disgust','fear','joy','sadness','surprise')) { 
  for (t in tasks) {
    cat("",t)
    a1=load_numeric_anno(paste('data/',t,'.standardized.tsv',sep=''))
    a1$orig_id=factor(paste(t,a1$orig_id,sep='-'))
    a1$task=t
    a = rbind(a,a1) 
  }
  cat("\n")
  a$task=factor(a$task)
  a
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

run_anno_samples <- function(full_a, size=5, replications=20, ngroup=10, ...) {
  msg("Running anno samples with size=",size,"and",replications,"replications.")
  dfapply(1:replications, function(iter) {
    cat("sample replication #",iter,"\n")
    a = anno_sample_via_workers(full_a, size)
    u = agg_to_unit(a)
    x = xval_preds(a,u, splits=xval_splits(a,u, ngroup=ngroup), ...)
    
    ret = list()
    ret$raw_acc = mean(u$plurality == u$gold)
    ret$calib_acc = mean(x$label == u$gold)
    est_report(x,u)
    ret
  })
}

# run_anno_samples_numeric <- function(full_a, size=5, replications=20, ...) {
#   msg("Running anno samples with size=",size,"and",replications,"replications.")
#   dfapply(1:replications, function(iter) {
#     # cat("sample replication #",iter,"\n")
#     a = anno_sample_via_workers(full_a, size)
#     u = agg_to_unit(a)
#     x = xval_preds(a,u, splits=xval_splits(a,u, loo=TRUE), ...)
#     x<<-x
#     ret = list()
#     ret$raw_cor = cor(u$mean, u$gold)
#     ret$calib_cor = cor(x$mean, u$gold)
#     # cat(sprintf("size %3d  raw cor: %.3f  calib cor: %.3f", size, cor(u$mean,u$gold), cor(x$mean,u$gold)))
#     # cat(sprintf("raw cor: %.3f  ", ret$raw_cor))
#     cat(sprintf("%.3f vs %.3f  ", ret$raw_cor, ret$calib_cor))
#     ret
#   })
# }

# run_stuff <- function(full_a, sizes=2:9, replications=100) {
#   # listsave= replicate(max(sizes), list())
#   for (iter in 1:replications) {
#     msg("Replication #", iter)
#     
#     for (size in sizes) {
#       a = anno_sample_via_workers(full_a, size)
#       u = agg_to_unit(a)
#       x = xval_preds(a,u, ngroup=10, rand=T)
#       r = list()
#       r$raw_cor = cor(u$mean, u$gold)
#       r$calib_cor = cor(x$mean, u$gold, use='pairwise.complete.obs')
#       # cat(sprintf("size %3d  raw cor: %.3f  calib cor: %.3f", size, cor(u$mean,u$gold), cor(x$mean,u$gold)))
#       # cat(sprintf("raw cor: %.3f  ", ret$raw_cor))
#       cat(sprintf("size=%2d: %.3f vs %.3f\n", size, r$raw_cor, r$calib_cor))
#       
#       listsave[[size]] <<- rbind(listsave[[size]], r)
#     }
#   }
# }


calib_an <- function(a,u, s, ...) {
  w = worker_an(a[s$atrain,], ...)
  # w = acc_based_llr(w)
  est = label_posterior(w,a)
  
  ret = list()
  ret$plur_acc = mean(u$plur[s$test] == u$gold[s$test])
  ret$calib_acc = mean(est$label[s$test] == u$gold[s$test])
  ret$est = est
  ret$w = w
  class(ret) = 'acc_results'
  ret
}

calib_xan <- function(a,u, ngroup=10) {
  
}

print.acc_results <- function(r) {
  cat(sprintf("PLURALITY: %.3f  CALIB: %.3f\n", r$plur_acc, r$calib_acc)) 
  print(names(r))
}

est_report <- function(est,u,s=NULL) {
  filter = if(is.null(s)) rep(T,nrow(u)) else s$test
  cat(sprintf("PLURALITY: %.3f  CALIB: %.3f\n", 
    mean(u$plurality[filter] == u$gold[filter]), 
    mean(est$label[filter] == u$gold[filter])))
}

whoaplot <- function() {
  stuff <- function(i) {
    points(calib_acc~raw_acc, data=rte_resample_vary[[i]], xlim=c(.7,.95), ylim=c(.7,.95),  col=rainbow(9)[i])
    m = lm(calib_acc~raw_acc,data=rte_resample_vary[[i]])
    abline(reg=m, col=rainbow(9)[i])
    print(i)
    print(coef(m))
  }
  par(mfrow=c(2,2))
  plot(0,ylim=c(.6,.93),xlim=c(.6,.93))
  for(i in 2:3)  stuff(i)
  plot(0,ylim=c(.6,.93),xlim=c(.6,.93))
  for(i in 4:5)  stuff(i)
  plot(0,ylim=c(.8,.93),xlim=c(.8,.93))
  for(i in 6:7)  stuff(i)
  plot(0,ylim=c(.8,.93),xlim=c(.8,.93))
  for(i in 8:9)  stuff(i) 
}

if (FALSE) {
  
  sizes = 2:9
  for (size in sizes)   {
    gridsearch_results[[size]] = list()
    for(ps in c(2^-10,.5,1,2,5,10)) for(t in c(-1,0,20,40,60,100)) {
      gridsearch_results[[ paste(size,ps,t) ]] = list()
    }      
  }
  
}

gridsearch <- function() {

  for(iter in 1:5) {
    for (size in sizes) {
      try({
        
      msg("REPLICATION",iter,"SIZE",size)
      a=anno_sample_via_workers(many_a[['rte']],size); u=agg_to_unit(a); a_samp=a; s=train_test_split(a,u,rand=T)

      for(ps in c(2^-10,.5,1,2,5)) for(t in c(-1,0,20,50)) {
        cat(ps," ",t,"\t");
        x = xval_preds(a,u,ngroup=10, pseudocount=ps, globalize_tail_cutoff=t)
        # w=worker_an(a[s$atrain,], pseudocount=ps, globalize_tail_cutoff=t)
        # w<<-w; x=label_posterior(w,a)
        # est_report(x[s$test,], u[s$test,])  
        est_report(x,u)
        gridsearch_results <<- rbind(gridsearch_results, 
          list(size=size,ps=ps,t=t, acc=sum(x$label==u$gold)))
      }
      save.image()
      })      
    }
  }
    
}

mse <- function(x,y) { mean( (x-y)**2 )}


cont_test <- function() {
  for (t in c('anger','disgust','fear','joy','sadness','surprise','valence','wordsim')) {
    a = load_numeric_anno(paste('data/',t,'.standardized.tsv',sep=''))
    u = agg_to_unit(a)
    x = xval_preds(a,u, splits=xval_splits(a,u,loo=TRUE), ngroup=10, model_fn=fit_anno_model)
    
    cat(sprintf("%10s  raw cor: %.3f  calib cor: %.3f", t, cor(u$mean,u$gold), cor(x$mean,u$gold)))
    cat("\n")
  }
  
}

# run_stuff <- function(full_a, sizes=2:9, replications=100) {
#   # listsave= replicate(max(sizes), list())
#   for (iter in 1:replications) {
#     msg("Replication #", iter)
#     
#     for (size in sizes) {
#       a = anno_sample_via_workers(full_a, size)
#       u = agg_to_unit(a)
#       x = xval_preds(a,u, ngroup=10, rand=T)
#       r = list()
#       r$raw_cor = cor(u$mean, u$gold)
#       r$calib_cor = cor(x$mean, u$gold, use='pairwise.complete.obs')
#       # cat(sprintf("size %3d  raw cor: %.3f  calib cor: %.3f", size, cor(u$mean,u$gold), cor(x$mean,u$gold)))
#       # cat(sprintf("raw cor: %.3f  ", ret$raw_cor))
#       cat(sprintf("size=%2d: %.3f vs %.3f\n", size, r$raw_cor, r$calib_cor))
#       
#       listsave[[size]] <<- rbind(listsave[[size]], r)
#     }
#   }
# }


# > a=list(); for (t in c('valence','anger','disgust','fear','joy','sadness','surprise')) { print(t); a1=load_numeric_anno(paste('data/',t,'.standardized.tsv',sep=''));  a1$orig_id=factor(paste(t,a1$orig_id,sep='-')); a1$task=t;  a<<-rbind(a,a1) };  a$task=factor(a$task)


# gogo <- function() {
#   timeit({
#     xvals <<- replicate(max(sizes), list())
#     raws <<- replicate(max(sizes), list())
#     for (size in sizes) {
#       msg(size)
#       r = replicate(2*choose(10,size), {
#         a2=anno_sample_via_workers(a, size)
#         u2=agg_to_unit(a2)
#         cor(u2$mean,u2$gold)
#       })
#       raws[[size]] <<- r
# 
#       r = new_xval(a,u,use='cm',size=size,replications=Inf,no_priors=T)
#       xvals[[size]] <<- r
# 
#     }
#     
#   })
# }

plot_results <- function(x, ylim=NULL, ...) {
  calib = sapply(sizes, function(i) mean(unlist(x[[i]][,'calib_cor'])))
  raw = sapply(sizes, function(i) mean(unlist(x[[i]][,'raw_cor'])))
  if (is.null(ylim)) ylim = c(min(c(calib,raw)-.05),max(c(calib,raw)+.05) )
  print(raw)
  print(calib)
  plot(sizes, raw, type='o', ylim=ylim, ...)
  lines(sizes, calib, type='o', col='blue')
}
plot_results2 <- function(x, ylim=NULL, ...) {
  calib = sapply(sizes, function(i) mean(unlist(x[[i]][,'calib_acc'])))
  raw = sapply(sizes, function(i) mean(unlist(x[[i]][,'raw_acc'])))
  if (is.null(ylim)) ylim = c(min(c(calib,raw)-.05),max(c(calib,raw)+.05) )
  print(raw)
  print(calib)
  plot(sizes, raw, type='o', ylim=ylim, ...)
  lines(sizes, calib, type='o', col='blue')
}


gogo2 <- function(a_all, use=NULL) {
  # listsave= replicate(10, list())
  msg("MODEL: ",use)
  msg("SIZES: ", sizes)
  for (iter in 1:40) {
    msg("Replication #", iter)
    
    for (size in sizes) {
      # a = anno_sample_via_workers(a_all, size)
      a = anno_sample_simple(a_all, size)
      u = agg_to_unit(a)
      x = xval3000(a, use=use)
      r = list()
      r$raw_cor = cor(x$raw, u$gold)
      r$calib_cor = cor(x$calib, u$gold, use='pairwise.complete.obs')
      cat(sprintf("size %3d  raw cor: %.3f  calib cor: %.3f\n", size, r$raw_cor, r$calib_cor))
      
      listsave[[size]] <<- rbind(listsave[[size]], r)
    }
  }
}

gogo3 <- function(a_all, replications=40, ...) {
  # listsave= replicate(10, list())
  msg("PARAMS: ")
  print(list(...))
  msg("SIZES: ", sizes)
  for (iter in 1:replications) {
    msg("Replication #", iter)
    
    for (size in sizes) {
      # a = anno_sample_via_workers(a_all, size)
      a = anno_sample_simple(a_all, size)
      u = agg_to_unit(a)
      x = xval_preds(a, u, ...)
      r = list()
      r$raw_acc = fair_plurality_acc(u)
      r$calib_acc = mean(x$label == u$gold, na.rm=T)
      a<<-a; u<<-u; x<<-x; r<<-r
      cat(sprintf("size %3d  raw acc: %.3f  calib acc: %.3f\n", size, r$raw_acc, r$calib_acc))
      
      listsave[[size]] <<- rbind(listsave[[size]], r)
    }
  }
}


xval_report <- function(x,u) {
  x$calib[is.na(x$calib)] = 0
  
  cat(sprintf("raw %.3f  calib %.3f  ", safecor(x$raw,u$gold), safecor(x$calib,u$gold)))
  cat(sprintf(" is a gain of %.1f%%", 100*(safecor(x$calib,u$gold)-safecor(x$raw,u$gold))))
  cat("\n")
}





plot_goldcalib_final <- function() {

  # temp_final_worker_model_acc = read.delim("temp_final_worker_model_acc.tsv")
  # rte_final_worker_model_acc = read.delim("rte_final_worker_model_acc")
  
  # ws = read.csv("../wordsim/wordsim.out")
  rte = read.csv("graphs/rte.out")
  # temp = read.csv("../temp2/anno.out")
  wsd = read.csv("graphs/wsd.out")


      postscript("goldcalib.eps", width=10.0, height = 4.0, horizontal = FALSE, onefile = FALSE, paper = "special", encoding = "TeXtext.enc")
  

      # split.screen(c(2,1))
      # screen(1)

  # par(mfrow=c(1,2),mar=c(4,5,3,1),oma=c(1,0,0,0),ps=30)
  par(mfrow=c(1,2),mar=c(4,5,3,1),oma=c(1,0,0,0),ps=25)


      # screen(1)
  plot(rte$annotations, rte$accuracy, type="b", lwd=4, cex=2, ylim=c(0.70, .95), ylab="accuracy", xlab="annotators",axes=F, frame.plot=T)
  axis(2,c(.7,.8,.9));  axis(2,seq(.7,.95, .05), labels=F, tick=T)
  lines(2:10, rte_final_worker_model_acc$calib[2:10], type="b", col="blue",  lwd=4, cex=2, pch=22)
  title("RTE")

      #abline(h=0.91, col="green")
      #abline(h=0.4451, col="green")
  abline(h=0.91, col="green", lty=5, lwd=4)
      #abline(h=0.1855, col="red")

      # screen(2)
  # plot(temp, type="b", xlab="annotators",  lwd=4, cex=2, ylim=c(0.70, 0.95))
  plot(temp_final_worker_model_acc$raw, type="b", xlab="annotators",  lwd=4, cex=2, ylim=c(0.70, 0.95), ylab="",axes=F, frame.plot=T)
  lines(2:10, temp_final_worker_model_acc$calib[2:10], type="b", xlab="annotators",  col='blue', lwd=4, cex=2, ylim=c(0.70, 0.95), pch=22)
  axis(2,c(.7,.8,.9));  axis(2,seq(.7,.95, .05), labels=F, tick=T)
    title("before/after")


legend("bottomright",legend=c("Gold calibrated","Naive voting"), inset=.05, pch=c(22,19), col=c('blue','black'), cex=.9, y.intersp=1.2)

  dev.off()

  
}




plot_workerfun_final <- function() {
  
  # w = read.delim("workers.tsv")
  # plot(acc~num, data=w, xlab="number of annotations", ylab="accuracy", main="")
  
  acc = w$acc
  cond = w$num<=40
  acc[cond] = jitter(acc[cond], 4)
  acc[cond & acc>1] =   acc[cond & acc>1] - (max(acc) - 1)
  
  
  postscript("workers.eps", width = 4.0, height = 4.0, horizontal = FALSE, onefile = FALSE, paper = "special", encoding = "TeXtext.enc")
  par(oma=c(1,0,0,0),ps=14)
  
  plot(w$num,acc, xlab="number of annotations", ylab="accuracy", main="", cex=1.2)
  
  dev.off()
}





dlanalysis$weirdass_replication_fun <- function(a,u, size=2, replications=40, ...) {
  N = 10
  replications = min(choose(N,size),replications)
  combo_matrix = combn(N, size)
  combos = sample(1:choose(N,size), replications)
  msg("Replications=",replications," on combinations=",choose(N,size))
  
  dfapply(levels(a$orig_id), function(uid) {
    inds = shuffle(which(a$orig_id==uid))
    # supermodel = fit_anno_model(a[a$orig_id!=uid,])
    x = dfapply(1:replications, function(i) {
      
      workers = a$X.amt_w[ inds[combo_matrix[,i]] ]
      atrain = trim_levels(a[a$X.amt_w %in% workers & a$orig_id != uid,])
      # print(atrain)
      m = fit_anno_model(atrain)
      # m = fit_anno_model(atrain, prior_mean=supermodel$prior_mean, prior_sd=supermodel$prior_sd)
      # print(m)
      p = label_posterior(m, trim_levels(a[a$orig_id==uid,]),
            ...)
      # print(p)
      list(calib=p$mean, raw=-42)
      # list(calib=p$mean, raw=a$response[inds[combo_matrix[,i]]])
      # list(calib=runif(1), raw=mean(a$response[inds[combo_matrix[,i]]]))
    })
    cat(sprintf("%s: gold %3s  full %.1_4f  calib %.1_4f  raw %.1_4f  ::  %s  ::  [CI %s]\n", 
        uid, u[uid,'gold'], u[uid,'mean_response'], mean(x$calib), mean(x$raw), 
        if(nrow(x)<=10) paste(sprintf("%.1_4f",sort(x$calib)),collapse=' ') else "", 
        paste( sprintf("%.1_4f",try(t.test(x$calib)$conf.int)), collapse=' ')
    ))

    list(calib=mean(x$calib), raw=mean(x$raw))
  })
}
