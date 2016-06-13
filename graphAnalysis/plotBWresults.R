#work in progress, on backburner until you figure out what to make of findings

plotBWresults<-function(calcGraphTheory_Output,measure,node){
  reformCodedWater_onOff<-listToMatrixByRow(calcGraphTheory_Output[[7]])
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
  axisMax<-max(ReformGroup1IgraphMeasures[[measure]][,node],ReformGroup2IgraphMeasures[[measure]][,node])
  plot(ReformGroup1IgraphMeasures[[measure]][,node],col="blue",type="o",ylab="transitivity",xlab="cost",axes=T)
  lines(ReformGroup2IgraphMeasures[[measure]][,node],col="red",type="o")
  #title(main="TransitivityNode1", col.main="black", font.main=4)
  #axis(1, at=seq(from = 1,to =nrow(ReformGroup1IgraphMeasures[[1]]),by=5),lab=as.character(seq(from = 10,to = 50,by=5)))
  #axis(2, at=seq(from = 0,to = max(axisMax),by=axisMax/10),lab=as.character(seq(from = 0,to = .4,by=.1)))
  legend(1, axisMax, c("Off","On"), cex=0.8, col=c("blue","red"), pch=21:22, lty=1:2)
  
  randMeanTransitivity<-{}
  randMeanMeas<-{}
  randSeMeas<-{}
  for(i in 1:nrow(ReformGroup1IgraphMeasures[[1]])){
    print(i)
    reformSparsity<-listToMatrixByRow(codedWater_onOFF[[5]][[i]])
    randMeanMeas[i]<-mean(reformSparsity[[measure]][,node])
    randSeMeas[i]<-sd(reformSparsity[[measure]][,node])/sqrt(length(reformSparsity[[measure]][,node]))
  }
  groupDiff<-ReformGroup1IgraphMeasures[[2]]-ReformGroup2IgraphMeasures[[2]]
  groupDiffAtNode<-groupDiff[,node]
  plot(randMeanMeas,col="blue",type="o",ylab="transitivity",xlab="cost",axes=T)
  lines(groupDiffAtNode,col="red",type="o")
  title(main="TransitivityNode1", col.main="black", font.main=4)
  axis(1, at=seq(from = 1,to = 41,by=5),lab=as.character(seq(from = 10,to = 50,by=5)))
  axis(2, at=seq(from = 0,to = .4,by=.1),lab=as.character(seq(from = 0,to = .4,by=.1)))
  legend(1, .4, c("Off","On"), cex=0.8, col=c("blue","red"), pch=21:22, lty=1:2)
  
}