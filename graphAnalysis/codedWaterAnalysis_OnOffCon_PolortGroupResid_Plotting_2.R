require(ggplot2)
OnGroupData<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onConPolortGroupResid10000_On_2")
ConGroupData<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onConPolortGroupResid10000_Con_2")
OffGroupData<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onOffPolortGroupResid10000_Off")
onOffContrast<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onOffPolortGroupResid10000")
onOffGraphData<-onOffContrast[[8]]
remove(onOffContrast)
onConContrast<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_onConPolortGroupResid10000_2")
onConGraphData<-onConContrast[[8]]
remove(onConContrast)
OffConContrast<-readRDS("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/savedObjects/codedWater_offConPolortGroupResid10000_2")
OffConGraphData<-OffConContrast[[8]]
remove(OffConContrast)

correctedBetweenessOnOffPos<-p.adjust(onOffGraphData$permTestNewBWpos[1,],"fdr")
correctedBetweenessOnOffPos[correctedBetweenessOnOffPos<.025]##Areas where Group1(on) is larger
correctedBetweenessOnOffNeg<-p.adjust(onOffGraphData$permTestNewBWneg[1,],"fdr")
correctedBetweenessOnOffNeg[correctedBetweenessOnOffNeg<.025]#Areas where group 2(off) is larger

correctedBetweenessOnConPos<-p.adjust(onConGraphData$permTestNewBWpos[1,],"fdr")
correctedBetweenessOnConPos[correctedBetweenessOnConPos<.025]##Areas where Group1(on) is larger
correctedBetweenessOnConNeg<-p.adjust(onConGraphData$permTestNewBWneg[1,],"fdr")
correctedBetweenessOnConNeg[correctedBetweenessOnConNeg<.025]#Areas where group 2(off) is larger

correctedBetweenessOffConPos<-p.adjust(OffConGraphData$permTestNewBWpos[1,],"fdr")
correctedBetweenessOffConPos[correctedBetweenessOffConPos<.025]##Areas where Group1(on) is larger
correctedBetweenessOffConNeg<-p.adjust(OffConGraphData$permTestNewBWneg[1,],"fdr")
correctedBetweenessOffConNeg[correctedBetweenessOffConNeg<.025]#Areas where group 2(off) is larger


onOffNodesPos<-which(correctedBetweenessOnOffPos<.025)
onOffNodesNeg<-which(correctedBetweenessOnOffNeg<.025)
onConNodesPos<-which(correctedBetweenessOnConPos<.025)
onConNodesNeg<-which(correctedBetweenessOnConNeg<.025)
offConNodesPos<-which(correctedBetweenessOffConPos<.025)
offConNodesNeg<-which(correctedBetweenessOffConNeg<.025)
onOffContrastPosMeanValues<-rbind(onOffGraphData$avgGraphMeasures$grp1[onOffNodesPos,1],onOffGraphData$avgGraphMeasures$grp2[onOffNodesPos,1],onConGraphData$avgGraphMeasures$grp2[onOffNodesPos,1])
onOffContrastNegMeanValues<-rbind(onOffGraphData$avgGraphMeasures$grp1[onOffNodesNeg,1],onOffGraphData$avgGraphMeasures$grp2[onOffNodesNeg,1],onConGraphData$avgGraphMeasures$grp2[onOffNodesNeg,1])
onConContrastPosMeanValues<-rbind(onConGraphData$avgGraphMeasures$grp1[onConNodesPos,1],onOffGraphData$avgGraphMeasures$grp2[onConNodesPos,1],onConGraphData$avgGraphMeasures$grp2[onConNodesPos,1])
onConContrastNegMeanValues<-rbind(onOffGraphData$avgGraphMeasures$grp1[onConNodesNeg,1],onOffGraphData$avgGraphMeasures$grp2[onConNodesNeg,1],onConGraphData$avgGraphMeasures$grp2[onConNodesNeg,1])
offConContrastPosMeanValues<-rbind(onOffGraphData$avgGraphMeasures$grp1[offConNodesPos,1],onOffGraphData$avgGraphMeasures$grp2[offConNodesPos,1],onConGraphData$avgGraphMeasures$grp2[offConNodesPos,1])
offConContrastNegMeanValues<-rbind(onOffGraphData$avgGraphMeasures$grp1[offConNodesNeg,1],onOffGraphData$avgGraphMeasures$grp2[offConNodesNeg,1],onConGraphData$avgGraphMeasures$grp2[offConNodesNeg,1])
groupOrder<-c("On","Off","Con")
#groupOrder<-c("on","off","con")
#areaNamesOnOffContrast<-c(rep(colnames(onOffContrastPosMeanValues),each = 3),rep(colnames(onOffContrastNegMeanValues),each = 3))
#onOffContrastMatrixForPlot<-as.data.frame(cbind(c(c(onOffContrastPosMeanValues),onOffContrastNegMeanValues),areaNamesOnOffContrast,rep(groupOrder,8)))
#colnames(onOffContrastMatrixForPlot)<-c("betweeness","area","group")
#ggplot(data=onOffContrastMatrixForPlot, aes(x=area, y=betweeness, fill=group)) + geom_bar(stat="identity", position=position_dodge())

#####ON OFF
onOffContrastMatrixForPlot<-as.data.frame(cbind(c(onOffContrastPosMeanValues),rep(rownames(colnames(onOffContrastPosMeanValues),each = 3),rep(groupOrder,4)))
colnames(onOffContrastMatrixForPlot)<-c("betweeness","area","group")
ggplot(data=onOffContrastMatrixForPlot, aes(x=area, y=betweeness, fill=group)) + geom_bar(stat="identity", position=position_dodge())+ggtitle("On Off Positive")

onOffContrastMatrixForPlot<-as.data.frame(cbind(c(onOffContrastNegMeanValues),rep(rownames(as.matrix(correctedBetweenessOnOffNeg[correctedBetweenessOnOffNeg<.025])),each = 3),rep(groupOrder,1)))
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


#####Hub Analysis#######
controlsHubs<-onConGraphData[[2]]$grp2[,"degree"][onConGraphData[[2]]$grp2[,"degree"]>2]
controlHubNodes<-which(onConGraphData[[2]]$grp2[,"degree"]>2)
onOffGraphData$permTestNewBWpos[,controlHubNodes]
onOffGraphData$permTestNewBWneg[,controlHubNodes]
t(apply(onOffGraphData$permTestNewBWneg[,controlHubNodes],MARGIN = 1,FUN = p.adjust))

onConGraphData$permTestNewBWpos[,controlHubNodes]
onConGraphData$permTestNewBWneg[,controlHubNodes]
t(apply(onConGraphData$permTestNewBWneg[,controlHubNodes],MARGIN = 1,FUN = p.adjust))

OffConGraphData$permTestNewBWpos[,controlHubNodes]
OffConGraphData$permTestNewBWneg[,controlHubNodes]
t(apply(OffConGraphData$permTestNewBWneg[,controlHubNodes],MARGIN = 1,FUN = p.adjust))



correctedMatrixPos<-apply(OffConGraphData$permTestNewBWpos,MARGIN = 1,p.adjust,"fdr")
correctedMatrixPos[apply(correctedMatrixPos<.025,MARGIN = 1,sum,na.rm=T)>0,]
correctedMatrixNeg<-apply(OffConGraphData$permTestNewBWneg,MARGIN = 1,p.adjust,"fdr")
correctedMatrixNeg[apply(correctedMatrixNeg<.025,MARGIN = 1,sum,na.rm=T)>0,]


onConGraphData$permTestNewBWpos[,apply(onConGraphData$permTestNewBWpos<.025,MARGIN = 1,sum,na.rm=T)>0]
