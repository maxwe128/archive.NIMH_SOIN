#Edited because of bug in code so that the saved objects have different names

codedWater_onOffPolortGroupResid10000<-Calculate_GraphTheory(dataList = "/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/onOffPolResidList",nEdgesOrThreshold = getEdgesFromPercent(8:49,116),analysisType = "group",comparison = T,threshType = "positive",edgeType = "partial",structuralData = T,numberPermutations = 10000,brainWide = T,pairedPerm=T,outputDirectory = "/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/onOffPolGroupResidWD/")
saveRDS(codedWater_onOffPolortGroupResid10000,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onOffPolortGroupResid10000")
saveRDS(group1IgraphMeasures,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onOffPolortGroupResid10000_On")
saveRDS(group2IgraphMeasures,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onOffPolortGroupResid10000_Off")
remove(codedWater_onOffPolortGroupResid10000)

correctedBetweenessPos<-p.adjust(codedWater_onOffPolortGroupResid10000[[8]]$permTestNewBWpos[1,],"fdr")
correctedBetweenessPos[correctedBetweenessPos<.025]##Areas where Group1(on) is larger
correctedBetweenessNeg<-p.adjust(codedWater_onOffPolortGroupResid10000[[8]]$permTestNewBWneg[1,],"fdr")
correctedBetweenessNeg[correctedBetweenessNeg<.025]#Areas where group 2(Con) is larger


correctedMatrixPos<-apply(codedWater_onOffPolortGroupResid10000[[8]]$permTestNewBWpos,MARGIN = 1,p.adjust,"fdr")
correctedMatrixPos[apply(correctedMatrixPos<.025,MARGIN = 1,sum,na.rm=T)>0,]
correctedMatrixNeg<-apply(codedWater_onOffPolortGroupResid10000[[8]]$permTestNewBWneg,MARGIN = 1,p.adjust,"fdr")
correctedMatrixNeg[apply(correctedMatrixNeg<.025,MARGIN = 1,sum,na.rm=T)>0,]
