getGraphMeasures<-function(dataList,sparseOrThresh,nEdgesOrThreshold,threshType="positive",edgeType="pearson",structuralData,brainWide,outputDirectory){
  numNotFullyConnected<<-0
  if(structuralData==F){
    numNotFullyConnected<<-0
    threshTally<<-{}#made to keep track of the thresholds for each equisparse graph to find outliers
    gt6dataList<-{}
    excludedIndices<-{}
    dataListRead<-read.table(dataList)
    for(i in 1:nrow(dataListRead)){
      checkFile<-read.table(as.character(dataListRead[i,]))
      if(nrow(checkFile)>6){#This sets the cutoff for individual analyses to 7 observations for each node
        gt6dataList<-c(gt6dataList,as.character(dataListRead[i,]))
      }else{
        excludedIndices<<-as.matrix(c(excludedIndices,i))
        #r[-excludedIndices,]#use this format to remove multiple rows if you decide it is important to have the same sample size for both groups  
      }
      #print(paste("Row indices",excludedIndices,"have been excluded because there was not enough data in those rows of this data:",dataList))
    }   
    allIndIgraph_Measures<-list()
    
    for(i in 1:length(nEdgesOrThreshold)){#loops through all thresholds that you want to calculate graph metrics and stores them in a list
      inIDlist<-{}
      indMeasures<-{}
      notConnected<-{}
      for(ind in gt6dataList){#grabs everything after the last / in the path name, so you need the entire path!!!
        listSplitSlashes<-strsplit(ind,"/")#method for grabbing the file name and using it to name matrices
        indIDposition<-length(listSplitSlashes[[1]])
        assign("indID",listSplitSlashes[[1]][indIDposition])#indID is now the rawData txt file name
        inIDlist<-c(inIDlist,indID)
        print(indID)
        indRawData<-read.table(ind)
        #allows for thresholding based on strongest correlations instead of just the most positive
        indCorTable<<-cor(indRawData)
        if(edgeType=="partial"){
          indCorTable<-cor2pcor(indCorTable)
        }
        if(threshType=="abs" | threshType=="absolute value" | threshType=="absolute"){
          indCorTable<-abs(indCorTable)
        }
        threshIndCorTable<<-threshGraph(connectivityMatrix1 = indCorTable,nEdgesOrThreshold=nEdgesOrThreshold[i],equi=sparseOrThresh,thresholdDirection = threshType)#thresholds graph
        indIgraph<-graph.adjacency(threshIndCorTable,mode="undirected")#can use parameters in graph.adjacency to created weighted and directed graphs
        indMeasures<-rbind(indMeasures,CalculateConnectivityMeasures(Igraph_of_interest = indIgraph))#creates dataFrame of each individual's network measures
  
      }
      indIgraph_Measures<-data.frame(indMeasures,row.names=inIDlist)
      allIndIgraph_Measures[[i]]<-indIgraph_Measures
    }
    return(allIndIgraph_Measures)# This object is a list where each entry is the graph measure calculations for each individual at threshold,
    #so indexing with [[x]] should move you through the tables of each individuals measures by threshold.
  }else{
    allStructIgraph_Measures<-{}
    structRawData<-{}
    fileList<-read.table(dataList)#this should be a list of all file directories making up a group of structural data
    for(i in 1:nrow(fileList)){
      structRawData<-rbind(structRawData,read.table(as.character(fileList[i,])))
    }
    BWM<-{}
    for(i in 1:length(nEdgesOrThreshold)){#loops through all thresholds that you want to calculate graph metrics and stores them in a list
      structMeasures<-{}
      structCorTable<-cor(structRawData)
      if(edgeType=="partial"){
        structCorTable<-cor2pcor(structCorTable)
      }
      if(threshType=="abs" | threshType=="absolute value" | threshType=="absolute"){
        structCorTable<-abs(structCorTable)
      }
      threshStructCorTable<-threshGraph(connectivityMatrix1 = structCorTable,nEdgesOrThreshold=nEdgesOrThreshold[i],equi=sparseOrThresh,outputDirectory=outputDirectory)#thresholds graph
      structIgraph<-graph.adjacency(threshStructCorTable,mode="undirected")#can use parameters in graph.adjacency to created weighted and directed graphs
      allStructIgraph_Measures<-rbind(allStructIgraph_Measures,CalculateConnectivityMeasures(Igraph_of_interest = structIgraph))
      brainWideMeasures<-list()
      if(brainWide==T){
        BWM[[i]]<-CalculateBrainWideConnectivityMeasures(Igraph_of_interest = structIgraph)
      }
    }
    test<<-brainWideMeasures
    if(brainWide==T){
      allStructIgraph_Measures<-list(allStructIgraph_Measures,BWM)
    }
  return(allStructIgraph_Measures)# This object is a list where each entry is the graph measure calculations for each individual at threshold,
  #so indexing with [[x]] should move you through the tables of each individuals measures by threshold.
  }
 
}
