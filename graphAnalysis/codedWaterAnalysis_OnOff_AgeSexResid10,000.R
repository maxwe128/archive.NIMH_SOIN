codedWater_onOffResid10000<-Calculate_GraphTheory(dataList = "/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/onOffResidList.txt",nEdgesOrThreshold = getEdgesFromPercent(8:48,116),analysisType = "group",comparison = T,threshType = "positive",edgeType = "partial",structuralData = T,numberPermutations = 10000,brainWide = T,pairedPerm=T,outputDirectory = "/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/onOffResidWD/")

saveRDS(codedWater_onOffResid10000,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onOffResidAgeSex10000")
saveRDS(group1IgraphMeasures,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onOffResidAgeSex10000_On")
saveRDS(group2IgraphMeasures,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onOffResidAgeSex10000_Off")


correctedBetweenessPos<-p.adjust(codedWater_onOffResid10000[[8]]$permTestNewBWpos[1,],"fdr")
correctedBetweenessPos[correctedBetweenessPos<.025]##Areas where Group1(on) is larger
correctedBetweenessNeg<-p.adjust(codedWater_onOffResid10000[[8]]$permTestNewBWneg[1,],"fdr")
correctedBetweenessNeg[correctedBetweenessNeg<.025]#Areas where group 2(off) is larger

correctedMatrixPos<-apply(codedWater_onOffResid10000[[8]]$permTestNewBWpos,MARGIN = 1,p.adjust,"fdr")
correctedMatrixPos[apply(correctedMatrixPos<.025,MARGIN = 1,sum,na.rm=T)>0,]
correctedMatrixNeg<-apply(codedWater_onOffResid10000[[8]]$permTestNewBWneg,MARGIN = 1,p.adjust,"fdr")
correctedMatrixNeg[apply(correctedMatrixNeg<.025,MARGIN = 1,sum,na.rm=T)>0,]
