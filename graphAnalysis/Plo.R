for(i in 1:15){
  rand<-erdos.renyi.game(n = 116,p.or.m = 2900,type = "gnm")
  print(average.path.length(rand))
}
allMeanLnet<-{}
allMeanCnet<-{}
allMeanAssortativity<-{}
allMeanGlobalEfficiency<-{}
allMeanLambda<-{}
allMeanGamma<-{}
allMeanSmallWorldness<-{}
for(i in 1:length(measures2bk)){
  allMeanLnet<-c(allMeanLnet,mean(measures2bk[[i]]$Lnet))
  allMeanCnet<-c(allMeanCnet,mean(measures2bk[[i]]$Cnet))
  allMeanAssortativity<-c(allMeanAssortativity,mean(measures2bk[[i]]$assortativity))
  allMeanGlobalEfficiency<-c(allMeanGlobalEfficiency,mean(measures2bk[[i]]$globalEfficiency))
  allMeanLambda<-c(allMeanLambda,mean(measures2bk[[i]]$lambda))
  allMeanGamma<-c(allMeanGamma,mean(measures2bk[[i]]$gamma))
  allMeanSmallWorldness<-c(allMeanSmallWorldness,mean(measures2bk[[i]]$smallWorldness))
}
meanMeasures<-cbind(allMeanLnet,allMeanCnet,allMeanAssortativity,allMeanGlobalEfficiency,allMeanLambda,allMeanGamma,allMeanSmallWorldness)
barplot(colMeans(meanMeasures))

plot(allMeanLnet)
lines(allMeanLnet)
plot(allMeanCnet)
lines(allMeanCnet)
plot(allMeanAssortativity)
lines(allMeanAssortativity)
plot(allMeanGlobalEfficiency)
lines(allMeanGlobalEfficiency)
plot(allMeanLambda)
lines(allMeanLambda)
plot(allMeanGamma)
lines(allMeanGamma)
plot(allMeanSmallWorldness,xlab ="cost",axes = FALSE)
axis(side=1, at=1:13,labels=as.character(seq(from = .37,to = .49,by=.01)))
axis(side=2, at=seq(from=min(allMeanSmallWorldness),to=max(allMeanSmallWorldness),by=.05))
lines(allMeanSmallWorldness)



Months <- c("May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov",
            "Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
            "Jul")
WheatI <- c(0.00, 0.97, 0.97, 0.87, 0.74, 0.64, 0.51, 0.28, 
            0.26, 0.18, 0.00, 0.00, 0.00, 0.00, 0.00)

par(lab = c(length(Months), 3, 7))     
plot(WheatI * 100, type = "s", ylim = c(0, 100), xlab = "",
     ylab = "%", main = "Irrigated Wheat", bty = "n",
     axes = FALSE)
axis(side = 1, at=1:15,labels = Months)
axis(side = 2)
