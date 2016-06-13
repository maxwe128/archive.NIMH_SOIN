formatStructuralOutput<-function(group1=group1IgraphMeasures,group2=group2IgraphMeasures,
                                 randGroupBWDiffMetaList1,groupDiffBWList=groupDiffBWList,
                                 numberPermutations1=numberPermutations,outputDirectory=outputDirectory,nEdgesOrThreshold1=nEdgesOrThreshold,SMrange=T){
  ########Change all references to the list codedWater_pair...... to the data in Calculate_graphTheory and change input to function
  
  ROIlabels<-readLines("/x/wmn18/elliottml/GraphTheoryAnalyses/ROIlabels")
  reformDiffBW<-randGroupBWDiffMetaList1
  graphMeasureNames<-row.names(randGroupBWDiffMetaList1[[1]][[1]])
  count<-0
  ##Find SM Regime##
  SMregimeAVG<-{}
  if(file.info(paste(outputDirectory,"/unconnectedLog",analysisDate,sep=""))$size==0){
    lowSMcut<-1
  }else{
    unconnectedMax<-max(read.table(paste(outputDirectory,"/unconnectedLog",analysisDate,sep=""))[,2])
    lowSMcut<-which(nEdgesOrThreshold1==unconnectedMax)
  }
  highSMcut<-min(c(sum(group1[[1]][,11]>1.2),sum(group2[[1]][,11]>1.2)))
  print(lowSMcut)
  print(highSMcut)
  ##Avg across SM Regime within each permutaion##
  for(j in 1:length(reformDiffBW)){
    all<-abind(reformDiffBW[[j]],along=3)
    SMregime<-all[,,lowSMcut:highSMcut]
    SMregimeAVG[[j]]<-apply(X = SMregime,MARGIN = c(1,2),FUN = mean)
  }
  newSMregimeAVG<-listToMatrixByRow(SMregimeAVG)#should be 5 matrices of 10000 obs of rand Differences in the respective measure
  abindGroupDiff<-abind(groupDiffBWList,along = 3)
  ReformGroup1IgraphMeasures<-listToMatrixByRow(group1[[2]])
  ReformGroup2IgraphMeasures<-listToMatrixByRow(group2[[2]])
  SMRG1M<-abind(ReformGroup1IgraphMeasures,along=3)
  SMRG2M<-abind(ReformGroup2IgraphMeasures,along=3)
  SMRG1M<-SMRG1M[lowSMcut:highSMcut,,]
  SMRG2M<-SMRG2M[lowSMcut:highSMcut,,]
  avgSMRG1M<-apply(SMRG1M,c(2,3),FUN=mean)
  avgSMRG2M<-apply(SMRG2M,c(2,3),FUN=mean)
  zSMRG1M<-scale(avgSMRG1M)
  zSMRG2M<-scale(avgSMRG2M)
  rownames(zSMRG1M)<-ROIlabels
  rownames(zSMRG2M)<-ROIlabels
  colnames(zSMRG1M)<-rownames(group1[[2]][[1]])
  colnames(zSMRG2M)<-rownames(group1[[2]][[1]])
  rownames(avgSMRG1M)<-ROIlabels
  rownames(avgSMRG2M)<-ROIlabels
  colnames(avgSMRG1M)<-rownames(group1[[2]][[1]])
  colnames(avgSMRG2M)<-rownames(group1[[2]][[1]])
  avgGraphMeasures<-list(grp1=avgSMRG1M,grp2=avgSMRG2M)
  zGraphMeasures<-list(grp1=zSMRG1M,grp2=zSMRG2M)
  #######Hubs, recreates table 2 from Bassett paper################
  group1Hubs<-zSMRG1M[,1:4][apply(X = zSMRG1M[,1:4]>2,MARGIN = 1,FUN = sum)>.99,]
  group2Hubs<-zSMRG2M[,1:4][apply(X = zSMRG2M[,1:4]>2,MARGIN = 1,FUN = sum)>.99,]
  
  #######top pvalues in each of the BW Measures recreates Fig 3 bottom row ##################
  groupDiffBW<-groupDiffBWList
  SMregGroupDiffBW<-abind(groupDiffBW,along = 3)
  if(SMrange==T){
    SMregGroupDiffBW<-SMregGroupDiffBW[,,lowSMcut:highSMcut]
  }
  SMregGroupDiffBW<-apply(SMregGroupDiffBW,MARGIN = c(1,2),mean)
  permTestNewBW<-matrix(10,nrow=nrow(SMregGroupDiffBW),ncol(SMregGroupDiffBW))
  permTestNewBWpos<-matrix(10,nrow=nrow(SMregGroupDiffBW),ncol(SMregGroupDiffBW))
  permTestNewBWneg<-matrix(10,nrow=nrow(SMregGroupDiffBW),ncol(SMregGroupDiffBW))
  print("here")
  for(j in 1:length(newSMregimeAVG)){
    for(k in 1:ncol(newSMregimeAVG[[1]])){
      permTestNewBWpos[j,k]<-sum(newSMregimeAVG[[j]][,k]>SMregGroupDiffBW[j,k])/numberPermutations1
      permTestNewBWneg[j,k]<-sum(newSMregimeAVG[[j]][,k]<SMregGroupDiffBW[j,k])/numberPermutations1
    }    
  }
  colnames(permTestNewBW)<-ROIlabels
  colnames(permTestNewBWpos)<-ROIlabels
  colnames(permTestNewBWneg)<-ROIlabels
  highestBetweeness<-sort(c(permTestNewBWpos[1,],permTestNewBWneg[1,]))[1:10]
  highestCloseness<-sort(c(permTestNewBWpos[2,],permTestNewBWneg[2,]))[1:10]
  highestDegree<-sort(c(permTestNewBWpos[3,],permTestNewBWneg[3,]))[1:10]
  highestEigenvector<-sort(c(permTestNewBWpos[4,],permTestNewBWneg[4,]))[1:10]
  highestTransitivity<-sort(c(permTestNewBWpos[5,],permTestNewBWneg[5,]))[1:10]
  highestGraphMeasures<-list(highestBetweeness=highestBetweeness,highestCloseness=highestCloseness,highestDegree=highestDegree,
                             highestEigenvector=highestEigenvector,highestEigenvector=highestEigenvector,
                             highestTransitivity=highestTransitivity)
  
  outPut<-list(avgGraphMeasures=avgGraphMeasures,zGraphMeasures=zGraphMeasures,permTestNewBWpos=permTestNewBWpos,
               permTestNewBWneg=permTestNewBWneg,highestGraphMeasures=highestGraphMeasures,SMrange=lowSMcut:highSMcut)
  return(outPut)
  
}