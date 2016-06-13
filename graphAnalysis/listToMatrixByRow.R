listToMatrixByRow<-function(inputList){
  tempMatrix<-{}
  newList<-list()
  for(j in 1:nrow(inputList[[1]])){
    tempMatrix<-{}
    for(i in 1:length(inputList)){
      tempMatrix<-rbind(tempMatrix,inputList[[i]][j,])
    }
    newList[[j]]<-tempMatrix
  }
  return(newList)
}