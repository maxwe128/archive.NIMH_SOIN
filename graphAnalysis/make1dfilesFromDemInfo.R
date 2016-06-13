SZdemInfo<-read.csv("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/codedWaterSZdemInfo.csv")
SZdemInfo<-SZdemInfo[1:37,]
SZdemInfo<-SZdemInfo[order(SZdemInfo[,2]),]
SZdemInfo<-SZdemInfo[,c(2,3,13:21,23:24)]
SZdemInfo$Sex[SZdemInfo$Sex==1]<--1
SZdemInfo$Sex[SZdemInfo$Sex==2]<-1
SZAgeSex<-cbind(SZdemInfo$Age.at.ON,SZdemInfo$Sex)
write.table(scale(SZdemInfo$Age.at.ON,scale=F),"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/SZage.1d",quote = F,sep = "",col.names = F,row.names=F)
write.table(SZdemInfo$Sex,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/SZsex.1d",quote = F,sep = "",col.names = F,row.names=F)
write.table(scale(SZdemInfo$AcuteAge,scale = F),"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/SZacuteAge.1d",quote = F,sep = "",col.names = F,row.names=F)
write.table(scale(SZdemInfo$Handedness,scale=F),"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/SZhand.1d",quote = F,sep = "",col.names = F,row.names=F)
write.table(scale(SZdemInfo$CPZeq,scale=F),"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/SZcpzEQ.1d",quote = F,sep = "",col.names = F,row.names=F)
####Controls###
matchedCon<-read.csv("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/controlWaterDemInfo.csv")
matchedCon<-matchedCon[,c(3,19,20)]
conLastNames<-as.vector(read.table("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/controlLastNames"))
matchedCon$Name<-tolower(matchedCon$Name)
newMatchedCon<-matchedCon[c(192,229,243,304,250,302,173,296,185,334,339,329,162,256,161,268,303,324,176,168,337,135,330,183,195,224,209,310,265,322,236,241,142,169,170,171,160),]
write.table(scale(newMatchedCon$Age.at.Scan,scale=F),"/x/wmn18/elliottml/GraphTheoryAnalyses/data//codedPetWater//matchedControls/controlAge1d")
newMatchedCon$Sex<-as.integer(newMatchedCon$Sex)
newMatchedCon$Sex[newMatchedCon$Sex==2]<--1
newMatchedCon$Sex[newMatchedCon$Sex==3]<-1
colnames(SZAgeSex)<-colnames(newMatchedCon[,c(2,3)])
write.table(newMatchedCon$Sex,"/x/wmn18/elliottml/GraphTheoryAnalyses/data//codedPetWater//matchedControls/controlSex1d",quote = F,sep = "",col.names = F,row.names=F)
write.table(scale(newMatchedCon$Age.at.Scan,scale=F),"/x/wmn18/elliottml/GraphTheoryAnalyses/data//codedPetWater//matchedControls/controlAge1d",quote = F,sep = "",col.names = F,row.names=F)
groupResid1d<-rbind(SZAgeSex,SZAgeSex,newMatchedCon[,c(2,3)])
groupResid1d$Age.at.Scan<-scale(groupResid1d$Age.at.Scan,scale=F)
write.table(groupResid1d$Age.at.Scan,"/x/wmn18/elliottml/GraphTheoryAnalyses/data//codedPetWater/groupResidAge1d",quote = F,sep = "",col.names = F,row.names=F)
write.table(groupResid1d$Sex,"/x/wmn18/elliottml/GraphTheoryAnalyses/data//codedPetWater/groupResidSex1d",quote = F,sep = "",col.names = F,row.names=F)