install.packages("igraph", dependencies=T)
library("igraph", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")
rawData<-read.table("/x/wmn21//elliottml/BCT/rawData_PETWaterAVGs.txt")#data File with rows as subjects avg rst state activity and colums are 116 segments of the brain created by /x/wmn21/elliottml/BCT/PET_MNI_N27_EZ_ML.nii
corTable<-as.matrix(cor(rawData))
#Thresholding the cor Matrix
plot(corTable)
corTable2[abs(corTable) < .5] <- 0
corTable2[abs(corTable) < .5] <- 0
test<-44
