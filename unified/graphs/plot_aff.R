#anger = read.csv("anger.out")
#surprise = read.csv("surprise.out")
#joy = read.csv("joy.out")
#sadness = read.csv("sadness.out")
#disgust = read.csv("disgust.out")
#valence = read.csv("valence.out")
#fear = read.csv("fear.out")

a = read.delim("turk_corr_vs_rest_for_R.out", sep="\t")

anger = a[1:10,2:3]
disgust = a[11:20,2:3]
fear = a[21:30,2:3];
joy = a[31:40,2:3];
sadness = a[41:50,2:3]
surprise = a[51:60,2:3]
valence = a[61:70,2:3]

postscript("all_emo.eps", width=10.0, height = 12.0, horizontal = FALSE, onefile = FALSE, paper = "special", encoding = "TeXtext.enc")

#split.screen(c(3,2))
#screen(1)
par(mfrow=c(3,2),mar=c(4,5,3,1),oma=c(1,0,0,0),ps=30)
plot(anger, type="b", xlab="", lwd=4, cex=2 ) # ylim=c(0,1.0))
title("anger")

#also we'd like to add:
# avg. Turker ITA -- we don't really have this, though.  divided up among multiple annotators.
# avg. expert ITA
# best system

#abline(h=0.4955, col="green") now we have the real data!
abline(h=0.4593, col="green", lty=5, lwd=4);
#abline(h=0.3233, col="red")

#screen(2)
plot(disgust, type="b", xlab="",  lwd=4, cex=2)
title("disgust")

#abline(h=0.4451, col="green")
abline(h=0.5829, col="green", lty=5, lwd=4)
#abline(h=0.1855, col="red")

#screen(3)
plot(fear, type="b", ylim=c(0.4,0.72),xlab="",  lwd=4, cex=2)
title("fear")

#abline(h=0.6381, col="green")
abline(h=0.7105, col="green", lty=5, lwd=4)
#abline(h=0.4492, col="red")

#screen(4)

plot(joy, type="b", xlab="",  lwd=4, cex=2, ylim=c(0.32,0.65))
title("joy")

#abline(h=0.5991, col="green")
abline(h=0.5961, col="green", lty=5, lwd=4)
#abline(h=0.2611, col="red")

#screen(5)
plot(sadness, type="b", xlab="annotators", lwd=4, cex=2, ylim=c(0.55,0.80))
title("sadness")

#abline(h=0.6819, col="green")
abline(h=0.6449, col="green", lty=5, lwd=4)
#abline(h=0.4098, col="red")

#screen(6)
plot(surprise, type="b", xlab="annotators", lwd=4, cex=2)
title("surprise")

#abline(h=0.3607, col="green")
abline(h=0.4644, col="green", lty=5, lwd=4)
#abline(h=0.1671, col="red")

#screen(7)
#plot(valence, type="b", ylim=c(0,1.0))
#title("valence")
##abline(h=0.7801, col="green")
#abline(h=0.7594, col="green")
#abline(h=0.4770, col="red")

#screen(8)
#text(.5,.5, "green is expert ITA", col="green")
#text(.5,.4, "red is best-performing system", col="red")

dev.off()

