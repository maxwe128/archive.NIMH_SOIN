dataDir<-"/x/wmn21/elliottml/GraphTheoryAnalyses/data/nbackROIrawLocal/"
zero_bk_files<-list.files("/x/wmn21/elliottml/GraphTheoryAnalyses/data/nbackROIrawLocal",pattern = "*0bk*")
two_bk_files<-list.files("/x/wmn21/elliottml/GraphTheoryAnalyses/data/nbackROIrawLocal",pattern = "*2bk*")
i=1
for(file in zero_bk_files){
  dataFileName<-paste(dataDir,file,sep="")#complete path to each 0back file
  print(dataFileName)
  temp<-read.table(dataFileName)#temp is the raw acticty of each run in each of the 116 ROIS
  corName<-paste("corTable_",strsplit(zero_bk_files[i], "_")[[1]][3],"_0bk",sep="")#name in form corTable_R"name"_0bk
  assign(corName,cor(temp))#creates the cor table with the corName
  i=i+1#allows you to step through the filenames in zero_bk_files
  
  #next create a matrix to store the important measures in for each participant, would also be nice to get the 
  graphMeasuresName<-paste("graphMeasures",strsplit(zero_bk_files[i], "_")[[1]][3])
  assign(graphMeasuresname,{})#Change to be the size of the wanted matrix
  
  }
}
#make the same as above for the 2back








#use to check which files are missing nback runs
#if(nrow(temp) < 7){
 # print(dataFileName)
  #nrow<-nrow(temp)
  #print(dataFileName)
  #print(nrow)