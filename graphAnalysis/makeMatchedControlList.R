ConDemInfo<-read.csv("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/PET Water Controls MASTERLIST_DYR.csv")
SZDemInfo<-read.csv("/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/codedWaterSZdemInfo.csv")
ConDemInfo<-ConDemInfo[,c(3,19,20,21,22)]
SZDemInfo<-as.data.frame(SZDemInfo[,c(2,3,13,14,17,23)])
SZDemInfo<-SZDemInfo[1:37,]
ConDemInfo<-ConDemInfo[1:342,]
ageSZ<-mean(SZDemInfo$Age.at.ON)
perFemale<-sum(SZDemInfo$Sex==2)/37
tentativeConList<-ConDemInfo[c(192,229,243,304,250,302,173,296,185,334,339,329,162,256,161,268,303,324,176,168,337,135,330,183,195,224,209,310,265,322,236,241,142,169,170,171,160),]
ageCon<-mean(tentativeConList$Age.at.Scan)
conPerFemale<-sum(tentativeConList$Sex=="F")/37
nameSplit<-strsplit(as.character(tentativeConList$Name),",")
conLastNames<-matrix(unlist(nameSplit),ncol=37)[1,]
conLastNames<-tolower(conLastNames)
write.table(conLastNames,"/x/wmn18/elliottml/GraphTheoryAnalyses/codedWaterAnalysis/controlLastNames",sep = "",col.names = F,row.names=F,quote = F)
