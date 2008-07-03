#anger = read.csv("anger.out")
#surprise = read.csv("surprise.out")
#joy = read.csv("joy.out")
#sadness = read.csv("sadness.out")
#disgust = read.csv("disgust.out")
#valence = read.csv("valence.out")
#fear = read.csv("fear.out")

ws = read.csv("../wordsim/wordsim.out")
rte = read.csv("../rte/rte.out")
temp = read.csv("../temp2/anno.out")
wsd = read.csv("../wsd/wsd.out")

#anger = a[1:10,2:3]
#disgust = a[11:20,2:3]
#fear = a[21:30,2:3];
#joy = a[31:40,2:3];
#sadness = a[41:50,2:3]
#surprise = a[51:60,2:3]
#valence = a[61:70,2:3]

postscript("all_rest.eps", width=10.0, height = 8.0, horizontal = FALSE, onefile = FALSE, paper = "special", encoding = "TeXtext.enc")

#split.screen(c(3,2))
#screen(1)
par(mfrow=c(2,2),mar=c(4,5,3,1),oma=c(1,0,0,0),ps=30)

plot(ws, type="b", xlab="", lwd=4, cex=2, ylim=c(0.83,0.96)) # ylim=c(0,1.0))
title("word similarity")

#also we'd like to add:
# avg. Turker ITA -- we don't really have this, though.  divided up among multiple annotators.
# avg. expert ITA
# best system

#abline(h=0.4955, col="green") now we have the real data!
abline(h=0.9583, col="green", lty=5, lwd=4);
#abline(h=0.3233, col="red")

#screen(2)
plot(rte, type="b", xlab="",  lwd=4, cex=2, ylim=c(0.70, 0.92))
title("RTE")

#abline(h=0.91, col="green")
#abline(h=0.4451, col="green")
abline(h=0.91, col="green", lty=5, lwd=4)
#abline(h=0.1855, col="red")

#screen(3)
plot(temp, type="b", xlab="annotators",  lwd=4, cex=2, ylim=c(0.70, 0.95))
title("before/after")

#abline(h=0.6381, col="green")
#abline(h=0.7105, col="green", lty=5, lwd=4)
#abline(h=0.4492, col="red")

#screen(4)

plot(wsd, type="b", xlab="annotators", ylab="accuracy", lwd=4, cex=2, ylim=c(0.978,1.0))
title("WSD")

#abline(h=0.5991, col="green")
abline(h=0.98, col="red", lty=4, lwd=4)
#abline(h=0.2611, col="red")

#screen(8)
#text(.5,.5, "green is expert ITA", col="green")
#text(.5,.4, "red is best-performing system", col="red")

dev.off()

