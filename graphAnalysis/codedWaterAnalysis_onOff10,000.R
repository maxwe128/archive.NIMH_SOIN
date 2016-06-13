codedWater_pairedOnOFF10000<-Calculate_GraphTheory(dataList = "/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/onOFFlist",
                                                   nEdgesOrThreshold = getEdgesFromPercent(10:48,116),analysisType = "group",comparison = T,
                                                   threshType = "positive",edgeType = "partial",structuralData = T,numberPermutations = 10000,
                                                   brainWide = T,pairedPerm=T,
                                                   outputDirectory = "/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/onOffWD")

reformPermData<-listToMatrixByRow(codedWater_onCon1000[[7]])
##save important objects##
saveRDS(codedWater_pairedOnOFF10000,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onOff10,000")
saveRDS(group1IgraphMeasures,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onOff10,000_group1")
saveRDS(group2IgraphMeasures,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onOff10,000_group2")

reformDiffBW<-metaListRearrange(codedWater_pairedOnOFF10000[[5]])
##The small world fully connected regime is from 19:47 or index 10 to 38 in data, this is where all matrices are connected and group1 and 2 matrices have small worldness values of more than 1.2.
#may want to restrict small worldness cutoff by all graphs instead of just group 1 and 2

#This averages differences across sparsity within small world regime
library("abind")
ROIlabels<-readLines("/x/wmn18/elliottml/GraphTheoryAnalyses/ROIlabels")
graphMeasureNames<-row.names(codedWater_pairedOnOFF10000[[7]][[1]])
count<-0
SMregimeAVG<-{}
for(j in 1:length(reformDiffBW)){
  all<-abind(reformDiffBW[[j]],along=3)
  SMregime<-all[,,6:39]
  SMregimeAVG[[j]]<-apply(X = SMregime,MARGIN = c(1,2),FUN = mean)
}
newSMregimeAVG<-listToMatrixByRow(SMregimeAVG)#should be 5 matrices of 10000 obs of rand Differences in the respective measure
abindGroupDiff<-abind(codedWater_pairedOnOFF10000[[4]],along = 3)
SMregimeGroupDiff<-abindGroupDiff[,,6:39]
avgGroupDiff<-apply(SMregimeGroupDiff,c(1,2),FUN=mean)
ReformGroup1IgraphMeasures<-listToMatrixByRow(group1IgraphMeasures[[2]])
ReformGroup2IgraphMeasures<-listToMatrixByRow(group2IgraphMeasures[[2]])
SMRG1M<-abind(ReformGroup1IgraphMeasures,along=3)
SMRG2M<-abind(ReformGroup2IgraphMeasures,along=3)
SMRG1M<-SMRG1M[6:39,,]
SMRG2M<-SMRG2M[6:39,,]
avgSMRG1M<-apply(SMRG1M,c(2,3),FUN=mean)
avgSMRG2M<-apply(SMRG2M,c(2,3),FUN=mean)
zSMRG1M<-scale(avgSMRG1M)
zSMRG2M<-scale(avgSMRG2M)
rownames(zSMRG1M)<-ROIlabels
rownames(zSMRG2M)<-ROIlabels
colnames(zSMRG1M)<-rownames(group1IgraphMeasures[[2]][[1]])
colnames(zSMRG2M)<-rownames(group1IgraphMeasures[[2]][[1]])
#######Hubs, recreates table 2 from Bassett paper################
zSMRG1M[,1:4][apply(X = zSMRG1M[,1:4]>2,MARGIN = 1,FUN = sum)>.99,]
zSMRG2M[,1:4][apply(X = zSMRG2M[,1:4]>2,MARGIN = 1,FUN = sum)>.99,]
 
#######top pvalues in each of the BW Measures recreates Fig 3 bottom row ##################
groupDiffBW<-codedWater_pairedOnOFF10000[[4]]
SMregGroupDiffBW<-abind(groupDiffBW,along = 3)
SMregGroupDiffBW<-apply(SMregGroupDiffBW,MARGIN = c(1,2),mean)
permTestNewBW<-matrix(10,nrow=nrow(SMregGroupDiffBW),ncol(SMregGroupDiffBW))
permTestNewBWpos<-matrix(10,nrow=nrow(SMregGroupDiffBW),ncol(SMregGroupDiffBW))
permTestNewBWneg<-matrix(10,nrow=nrow(SMregGroupDiffBW),ncol(SMregGroupDiffBW))
for(j in 1:length(newSMregimeAVG)){
  for(k in 1:ncol(newSMregimeAVG[[1]])){
    permTestNewBWpos[j,k]<-sum(newSMregimeAVG[[j]][,k]>SMregGroupDiffBW[j,k])/10000
    permTestNewBWneg[j,k]<-sum(newSMregimeAVG[[j]][,k]<SMregGroupDiffBW[j,k])/10000
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
highestGraphMeasures<-list(highestBetweeness=highestBetweeness,highestCloseness=highestCloseness,highestDegree=highestDegree,highestEigenvector=highestEigenvector,highestEigenvector=highestEigenvector,highestTransitivity=highestTransitivity)

####analysis based on areas that were the most different based on onCon contrast#########
onSZsigAreasNeg<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects//areasNeg")
onSZsigAreasPos<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects//areasPos")
permTestNewBWneg[,onSZsigAreasNeg]
permTestNewBWpos[,onSZsigAreasPos]

avgDiff<-avgSMRG1M-avgSMRG2M
rownames(avgDiff)<-ROIlabels

#onMeds has smaller centrality measures in PCC than OffMeds

##Control hub Investigation#####
saveRDS(permTestNewBWneg,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/onOffPermTestBWneg10,000")
saveRDS(avgSMRG1M,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/onMedsAvg10,000")
saveRDS(avgSMRG2M,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/offMedsAvg10,000")
onConPermTestBWneg<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/onConPermTestBWneg10,000")
offConPermTestBWneg<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/OffConPermTestBWneg10,000")
onOffPermTestBWneg<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/onOffPermTestBWneg10,000")
OnData<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/onMedsAvg10,000")
ConData<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/conAvg10,000")
OffData<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/offMedsAvg10,000")
onDiffFromControl<-OnData-ConData
offDiffFromControl<-OffData-ConData
controlHubs<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/conHubAreas10,000")
permTestNewBWpos[,controlHubs]
permTestNewBWneg[,controlHubs]

row.names(offConPermTestBWneg)<-graphMeasureNames
row.names(onConPermTestBWneg)<-graphMeasureNames
row.names(onOffPermTestBWneg)<-graphMeasureNames
onConPermTestBWneg[,controlHubs]
offConPermTestBWneg[,controlHubs]
onOffPermTestBWneg[,controlHubs]

####Plotting#######
relevantOnDiffFromControl<-onDiffFromControl[controlHubs,]
relevantOffDiffFromControl<-offDiffFromControl[controlHubs,]

df <- data.frame(relevantOffDiffFromControl[,1],
                 relevantOnDiffFromControl[,1],
                 x = controlHubs)

ylim <- with(df, range(relevantOffDiffFromControl[,1], relevantOnDiffFromControl[,1])) ## compute y axis limits

plot(relevantOffDiffFromControl[,1] ~ x, data = df, pch = 20, col = "blue", ylim = ylim,type="")
points(relevantOnDiffFromControl[,1] ~ x, data = df, pch = 20, col = "red")

