metaListRearrange<-function(inputList){
  tempList<-{}
  newList<-{}
  for(i in 1:length(inputList[[1]])){
    for(j in 1:length(inputList)){
      tempList[[j]]<-inputList[[j]][[i]]
    }
    newList[[i]]<-tempList
  }
  return(newList)
}