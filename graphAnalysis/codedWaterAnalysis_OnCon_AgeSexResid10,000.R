codedWater_OnConResid10000<-Calculate_GraphTheory(dataList = "/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/onConResidList.txt",nEdgesOrThreshold = getEdgesFromPercent(8:50,116),analysisType = "group",comparison = T,threshType = "positive",edgeType = "partial",structuralData = T,numberPermutations = 10000,brainWide = T,pairedPerm=F,outputDirectory = "/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/onConResidWD/")
saveRDS(codedWater_OnConResid10000,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onConResidAgeSex10000")
saveRDS(group1IgraphMeasures,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onConResidAgeSex10000_On")
saveRDS(group2IgraphMeasures,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onConResidAgeSex10000_Con")

correctedBetweenessPos<-p.adjust(codedWater_OnConResid10000[[8]]$permTestNewBWpos[1,],"fdr")
correctedBetweenessPos[correctedBetweenessPos<.025]##Areas where Group1(on) is larger
correctedBetweenessNeg<-p.adjust(codedWater_OnConResid10000[[8]]$permTestNewBWneg[1,],"fdr")
correctedBetweenessNeg[correctedBetweenessNeg<.025]#Areas where group 2(Con) is larger

controlsHubs<-codedWater_OnConResid10000[[8]][[2]]$grp2[,1][codedWater_OnConResid10000[[8]][[2]]$grp2[,1]>2]

correctedMatrixPos<-apply(codedWater_OnConResid10000[[8]]$permTestNewBWpos,MARGIN = 1,p.adjust,"fdr")
correctedMatrixPos[apply(correctedMatrixPos<.025,MARGIN = 1,sum,na.rm=T)>0,]
correctedMatrixNeg<-apply(codedWater_OnConResid10000[[8]]$permTestNewBWneg,MARGIN = 1,p.adjust,"fdr")
correctedMatrixNeg[apply(correctedMatrixNeg<.025,MARGIN = 1,sum,na.rm=T)>0,]
