codedWater_onOFF<-Calculate_GraphTheory(dataList = "/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/onOffGroupList.txt",nEdgesOrThreshold = getEdgesFromPercent(10:50,116),analysisType = "group",comparison = T,threshType = "positive",edgeType = "partial",structuralData = T,numberPermutations = 1000,brainWide = T)
reformCodedWater_onOff<-listToMatrixByRow(codedWater_onOFF[[7]])
cdLT<-lapply(reformCodedWater_onOff,FUN = lt,y=.05)
cdGT<-lapply(reformCodedWater_onOff,FUN = gt,y=.95)
redCdGT<-{}
redCdLT<-{}
for(i in 1:length(cdGT)){
  redCdGT<-rbind(redCdGT,apply(X = cdGT[[i]],MARGIN = 2,FUN = sum,na.rm=T))
  redCdLT<-rbind(redCdLT,apply(X = cdLT[[i]],MARGIN = 2,FUN = sum,na.rm=T))
  print(i)
}
ReformGroup1IgraphMeasures<-listToMatrixByRow(group1IgraphMeasures[[2]])#output is a List where entries are each Measure and rows are each cost
ReformGroup2IgraphMeasures<-listToMatrixByRow(group2IgraphMeasures[[2]])
reformDiffGroup12<-listToMatrixByRow(codedWater_onOFF[[4]])

plot(ReformGroup1IgraphMeasures[[3]][,64],col="blue",type="o",ylab="transitivity",xlab="cost",axes=F)
lines(ReformGroup2IgraphMeasures[[3]][,64],col="red",type="o")
title(main="TransitivityNode1", col.main="black", font.main=4)
axis(1, at=seq(from = 1,to = 41,by=5),lab=as.character(seq(from = 10,to = 50,by=5)))
axis(2, at=seq(from = 0,to = .4,by=.1),lab=as.character(seq(from = 0,to = .4,by=.1)))
legend(1, .4, c("Off","On"), cex=0.8, col=c("blue","red"), pch=21:22, lty=1:2)

node<-1#indicates node you want to graph meas for
randMeanTransitivity<-{}
meas<-5#This value indicates the graph measure you want to use in graphing
randMeanMeas<-{}
randSeMeas<-{}
for(i in 1:41){
  print(i)
  reformSparsity<-listToMatrixByRow(codedWater_onOFF[[5]][[i]])
  randMeanMeas[i]<-mean(reformSparsity[[meas]][,node])
  randSeMeas[i]<-sd(reformSparsity[[meas]][,node])/sqrt(length(reformSparsity[[meas]][,node]))
}
groupDiff<-ReformGroup1IgraphMeasures[[2]]-ReformGroup2IgraphMeasures[[2]]
groupDiffAtNode<-groupDiff[,node]
plot(randMeanMeas,col="blue",type="o",ylab="transitivity",xlab="cost",axes=T)
lines(groupDiffAtNode,col="red",type="o")
title(main="TransitivityNode1", col.main="black", font.main=4)
axis(1, at=seq(from = 1,to = 41,by=5),lab=as.character(seq(from = 10,to = 50,by=5)))
axis(2, at=seq(from = 0,to = .4,by=.1),lab=as.character(seq(from = 0,to = .4,by=.1)))
legend(1, .4, c("Off","On"), cex=0.8, col=c("blue","red"), pch=21:22, lty=1:2)

#do this for a few of the best findings
#Also consider plotting the difference between group1 and group2 along with the rand permutation differences with an error bar 