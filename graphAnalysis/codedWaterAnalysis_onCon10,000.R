codedWater_OnCon10000<-Calculate_GraphTheory(dataList = "/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/onConList",nEdgesOrThreshold = getEdgesFromPercent(10:48,116),analysisType = "group",comparison = T,threshType = "positive",edgeType = "partial",structuralData = T,numberPermutations = 10000,brainWide = T,pairedPerm=F,outputDirectory = "/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/onConWD/")reformPermData<-listToMatrixByRow(codedWater_onCon1000[[7]])
source('/x/wmn18/elliottml/GraphTheoryAnalyses/scripts/listToMatrixByRow.R')
source('/x/wmn18/elliottml/GraphTheoryAnalyses/scripts/CalculateBrainWideConnectivityMeasures.R')
source('/x/wmn18/elliottml/GraphTheoryAnalyses/scripts/metaListRearrange.R')

##save important objects##
saveRDS(codedWater_OnCon10000,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_OnCon10,000")
saveRDS(group1IgraphMeasures,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_OnCon10,000_group1")
saveRDS(group2IgraphMeasures,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_OnCon10,000_group2")
codedWater_OnCon10000<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_OnCon10,000")
group1IgraphMeasures<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_OnCon10,000_group1")
group2IgraphMeasures<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_OnCon10,000_group2")
reformDiffBW<-metaListRearrange(codedWater_OnCon10000[[5]])
##The small world fully connected regime is from 19:47 or index 10 to 38 in data, this is where all matrices are connected and group1 and 2 matrices have small worldness values of more than 1.2.
#may want to restrict small worldness cutoff by all graphs instead of just group 1 and 2

#This averages differences across sparsity within small world regime
ROIlabels<-readLines("/x/wmn18/elliottml/GraphTheoryAnalyses/ROIlabels")
library(abind)
count<-0
SMregimeAVG<-{}
for(j in 1:length(reformDiffBW)){
  all<-abind(reformDiffBW[[j]],along=3)
  SMregime<-all[,,6:39]
  SMregimeAVG[[j]]<-apply(X = SMregime,MARGIN = c(1,2),FUN = mean)
}
newSMregimeAVG<-listToMatrixByRow(SMregimeAVG)#should be 5 matrices of 10000 obs of rand Differences in the respective measure
abindGroupDiff<-abind(codedWater_OnCon10000[[4]],along = 3)
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
groupDiffBW<-codedWater_OnCon10000[[4]]
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

#####adjusted P-Values######
adjPosB<-p.adjust(permTestNewBWneg[1,],method="fdr")
adjNegB<-p.adjust(permTestNewBWpos[1,],method="fdr")
highestBadj<-sort(c(adjNegB,adjPosB))[1:10]

##areas significantly different between controls and meds to be compared in on vs off###
onVsConPos<-as.data.frame(permTestNewBWpos[1:5,][,apply(X = permTestNewBWpos[1:5,]<.005 ,MARGIN = 2,FUN = sum,na.rm=T)>.99])
onVsConNeg<-as.data.frame(permTestNewBWneg[1:5,][,apply(X = permTestNewBWneg[1:5,]<.005 ,MARGIN = 2,FUN = sum,na.rm=T)>.99])
areasPos<-colnames(onVsConPos)
areasNeg<-colnames(onVsConNeg)

saveRDS(areasNeg,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/areasNeg")
saveRDS(areasPos,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/areasPos")

avgDiff<-avgSMRG1M-avgSMRG2M
rownames(avgDiff)<-ROIlabels
#onMedsSZ has has smaller centrality measure in Left PCC than controls


######Areas that are "significant"(gt 2sds) in controls#####
saveRDS(permTestNewBWneg,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/onConPermTestBWneg10,000")
saveRDS(avgSMRG2M,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/conAvg10,000")
conHubs<-zSMRG2M[,1:4][apply(X = zSMRG2M[,1:4]>2,MARGIN = 1,FUN = sum)>.99,]
conHubAreas<-rownames(conHubs)
saveRDS(conHubAreas,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/conHubAreas10,000")
conHubs1000<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/conHubAreas")
