OnGroupData<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onConResidAgeSex10000_On")
ConGroupData<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onConResidAgeSex10000_Con")
OffGroupData<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onOffResidAgeSex10000_Off")
onOffContrast<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onOffResidAgeSex10000")
onConContrast<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onConResidAgeSex10000")
OffConContrast<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_offConResidAgeSex10000")

correctedBetweenessOnOffPos<-p.adjust(onOffContrast[[8]]$permTestNewBWpos[1,],"fdr")
correctedBetweenessOnOffPos[correctedBetweenessPos<.025]##Areas where Group1(on) is larger
correctedBetweenessOnOffNeg<-p.adjust(onOffContrast[[8]]$permTestNewBWneg[1,],"fdr")
correctedBetweenessOnOffNeg[correctedBetweenessNeg<.025]#Areas where group 2(off) is larger

correctedBetweenessOnConPos<-p.adjust(onConContrast[[8]]$permTestNewBWpos[1,],"fdr")
correctedBetweenessOnConPos[correctedBetweenessOnConPos<.025]##Areas where Group1(on) is larger
correctedBetweenessOnConNeg<-p.adjust(onConContrast[[8]]$permTestNewBWneg[1,],"fdr")
correctedBetweenessOnConNeg[correctedBetweenessOnConNeg<.025]#Areas where group 2(off) is larger

correctedBetweenessOffConPos<-p.adjust(OffConContrast[[8]]$permTestNewBWpos[1,],"fdr")
correctedBetweenessOffConPos[correctedBetweenessOffConPos<.025]##Areas where Group1(on) is larger
correctedBetweenessOffConNeg<-p.adjust(OffConContrast[[8]]$permTestNewBWneg[1,],"fdr")
correctedBetweenessOffConNeg[correctedBetweenessOffConNeg<.025]#Areas where group 2(off) is larger

correctedMatrixPos<-apply(onOffContrast[[8]]$permTestNewBWpos,MARGIN = 1,p.adjust,"fdr")
correctedMatrixPos[apply(correctedMatrixPos<.025,MARGIN = 1,sum,na.rm=T)>0,]
correctedMatrixNeg<-apply(onOffContrast[[8]]$permTestNewBWneg,MARGIN = 1,p.adjust,"fdr")
correctedMatrixNeg[apply(correctedMatrixNeg<.025,MARGIN = 1,sum,na.rm=T)>0,]

onOffNodesPos<-which(correctedBetweenessOnOffPos<.025)
onOffNodesNeg<-which(correctedBetweenessOnOffNeg<.025)
onConNodesPos<-which(correctedBetweenessOnConPos<.025)
onConNodesNeg<-which(correctedBetweenessOnConNeg<.025)
offConNodesPos<-which(correctedBetweenessOffConPos<.025)
offConNodesNeg<-which(correctedBetweenessOffConNeg<.025)
onOffContrastPosMeanValues<-rbind(onOffContrast[[8]]$avgGraphMeasures$grp1[onOffNodesNeg,1],onOffContrast[[8]]$avgGraphMeasures$grp2[onOffNodesNeg,1],onConContrast[[8]]$avgGraphMeasures$grp2[onOffNodesNeg,1])
onOffContrastNegMeanValues<-rbind(onOffContrast[[8]]$avgGraphMeasures$grp1[onOffNodesPos,1],onOffContrast[[8]]$avgGraphMeasures$grp2[onOffNodesPos,1],onConContrast[[8]]$avgGraphMeasures$grp2[onOffNodesPos,1])
onConContrastPosMeanValues<-rbind(onConContrast[[8]]$avgGraphMeasures$grp1[onConNodesNeg,1],onOffContrast[[8]]$avgGraphMeasures$grp2[onConNodesNeg,1],onConContrast[[8]]$avgGraphMeasures$grp2[onConNodesNeg,1])
onConContrastNegMeanValues<-rbind(onOffContrast[[8]]$avgGraphMeasures$grp1[onConNodesPos,1],onOffContrast[[8]]$avgGraphMeasures$grp2[onConNodesPos,1],onConContrast[[8]]$avgGraphMeasures$grp2[onConNodesPos,1])
offConContrastPosMeanValues<-rbind(onOffContrast[[8]]$avgGraphMeasures$grp1[onOffNodesNeg,1],onOffContrast[[8]]$avgGraphMeasures$grp2[onOffNodesNeg,1],onConContrast[[8]]$avgGraphMeasures$grp2[onOffNodesNeg,1])
offConContrastNegMeanValues<-rbind(onOffContrast[[8]]$avgGraphMeasures$grp1[onOffNodesPos,1],onOffContrast[[8]]$avgGraphMeasures$grp2[onOffNodesPos,1],onConContrast[[8]]$avgGraphMeasures$grp2[onOffNodesPos,1])

#groupOrder<-c("on","off","con")
#areaNamesOnOffContrast<-c(rep(colnames(onOffContrastPosMeanValues),each = 3),rep(colnames(onOffContrastNegMeanValues),each = 3))
#onOffContrastMatrixForPlot<-as.data.frame(cbind(c(c(onOffContrastPosMeanValues),onOffContrastNegMeanValues),areaNamesOnOffContrast,rep(groupOrder,8)))
#colnames(onOffContrastMatrixForPlot)<-c("betweeness","area","group")
#ggplot(data=onOffContrastMatrixForPlot, aes(x=area, y=betweeness, fill=group)) + geom_bar(stat="identity", position=position_dodge())

#####ON OFF
onOffContrastMatrixForPlot<-as.data.frame(cbind(c(onOffContrastPosMeanValues),rep(colnames(onOffContrastPosMeanValues),each = 3),rep(groupOrder,4)))
colnames(onOffContrastMatrixForPlot)<-c("betweeness","area","group")
ggplot(data=onOffContrastMatrixForPlot, aes(x=area, y=betweeness, fill=group)) + geom_bar(stat="identity", position=position_dodge())+ggtitle("On Off Positive")

onOffContrastMatrixForPlot<-as.data.frame(cbind(c(onOffContrastNegMeanValues),rep(colnames(onOffContrastNegMeanValues),each = 3),rep(groupOrder,4)))
colnames(onOffContrastMatrixForPlot)<-c("betweeness","area","group")
ggplot(data=onOffContrastMatrixForPlot, aes(x=area, y=betweeness, fill=group)) + geom_bar(stat="identity", position=position_dodge())+ggtitle("On Off Negative")

#####ON CON
onConContrastMatrixForPlot<-as.data.frame(cbind(c(onConContrastPosMeanValues),rep(colnames(onConContrastPosMeanValues),each = 3),rep(groupOrder,6)))
colnames(onConContrastMatrixForPlot)<-c("betweeness","area","group")
ggplot(data=onConContrastMatrixForPlot, aes(x=area, y=betweeness, fill=group)) + geom_bar(stat="identity", position=position_dodge())+ggtitle("On Con Positive")

onConContrastMatrixForPlot<-as.data.frame(cbind(c(onConContrastNegMeanValues),rep(colnames(onConContrastNegMeanValues),each = 3),rep(groupOrder,1)))
colnames(onConContrastMatrixForPlot)<-c("betweeness","area","group")
ggplot(data=onConContrastMatrixForPlot, aes(x=area, y=betweeness, fill=group)) + geom_bar(stat="identity", position=position_dodge())+ggtitle("On Con Negative")

#####OFF CON
offConContrastMatrixForPlot<-as.data.frame(cbind(c(offConContrastPosMeanValues),rep(colnames(offConContrastPosMeanValues),each = 3),rep(groupOrder,4)))
colnames(offConContrastMatrixForPlot)<-c("betweeness","area","group")
ggplot(data=offConContrastMatrixForPlot, aes(x=area, y=betweeness, fill=group)) + geom_bar(stat="identity", position=position_dodge())+ggtitle("Off Con Positive")

offConContrastMatrixForPlot<-as.data.frame(cbind(c(offConContrastNegMeanValues),rep(colnames(offConContrastNegMeanValues),each = 3),rep(groupOrder,4)))
colnames(offConContrastMatrixForPlot)<-c("betweeness","area","group")
ggplot(data=offConContrastMatrixForPlot, aes(x=area, y=betweeness, fill=group)) + geom_bar(stat="identity", position=position_dodge())+ggtitle("Off Con Negative")



