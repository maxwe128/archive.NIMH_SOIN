##Originally ran with mistakes in averaging across SMRefime, changed saved names second time through

codedWater_onOffResidFixed10000<-Calculate_GraphTheory(dataList = "/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/onOffResidList.txt",nEdgesOrThreshold = getEdgesFromPercent(5:49,116),analysisType = "group",comparison = T,threshType = "positive",edgeType = "partial",structuralData = T,numberPermutations = 10000,brainWide = T,pairedPerm=T,outputDirectory = "/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/onOffResidWD/")

saveRDS(codedWater_onOffResidFixed10000,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onOffResidAgeSexFixed10000_2")
saveRDS(group1IgraphMeasures,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onOffResidAgeSexFixed10000_On_2")
saveRDS(group2IgraphMeasures,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onOffResidAgeSexFixed10000_Off_2")
remove(codedWater_onOffResidFixed10000)

correctedBetweenessPos<-p.adjust(codedWater_onOffResidFixed10000[[8]]$permTestNewBWpos[1,],"fdr")
correctedBetweenessPos[correctedBetweenessPos<.025]##Areas where Group1(on) is larger
correctedBetweenessNeg<-p.adjust(codedWater_onOffResidFixed10000[[8]]$permTestNewBWneg[1,],"fdr")
correctedBetweenessNeg[correctedBetweenessNeg<.025]#Areas where group 2(off) is larger

correctedMatrixPos<-apply(codedWater_onOffResidFixed10000[[8]]$permTestNewBWpos,MARGIN = 1,p.adjust,"fdr")
correctedMatrixPos[apply(correctedMatrixPos<.025,MARGIN = 1,sum,na.rm=T)>0,]
correctedMatrixNeg<-apply(codedWater_onOffResidFixed10000[[8]]$permTestNewBWneg,MARGIN = 1,p.adjust,"fdr")
correctedMatrixNeg[apply(correctedMatrixNeg<.025,MARGIN = 1,sum,na.rm=T)>0,]
