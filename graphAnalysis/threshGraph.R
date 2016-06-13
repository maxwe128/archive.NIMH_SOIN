threshGraph<-function(connectivityMatrix1,connectivityMatrix2={},equi,nEdgesOrThreshold,thresholdDirection,outputDirectory){
  maxK<-(ncol(connectivityMatrix1)*(ncol(connectivityMatrix1)-1))/2 #maximum number of edges
  #this is the case where you want equisparse graphs, will be used most of the time
  if(equi=="sparse"){
      if(nEdgesOrThreshold>maxK){
        print("k exceeds the limit on the possible number of edges")
        stop()
      } 
      threshTally<-{}
    threshcorGroupData<-connectivityMatrix1
    diag(threshcorGroupData)<-0
    threshcorGroupData<-as.matrix(threshcorGroupData)
    graph<-graph.adjacency(threshcorGroupData)
    threshold<-1
    threshChange<--.1
    count<-1
    #This while loop attemps to find the right threshold so that the graph has k edges. It switches the magnitude and direction of threshold
    #changing whenever k got too small or big. Also exits and throws error if more than 1000 attempts at adjusting threshold does not 
    #converge on the right k. If this happens it is almost cerainly the case where you have multiple edges that are the same, so you can't
    #just loose one. 
    #print("finding threshold")
    while((sum(threshcorGroupData>threshold)/2)!=nEdgesOrThreshold){#attempts to find threshold that makes the # of edges equal to k
      #cat("+"); flush.console()
      threshold<-threshold+threshChange
      count<-count+1
      #print(sum(threshcorGroupData>threshold)/2)
      if((sum(threshcorGroupData>threshold)/2)>nEdgesOrThreshold && threshChange<0 | (sum(threshcorGroupData>threshold)/2)<nEdgesOrThreshold && threshChange>0){
        threshChange<-threshChange*-.1
      }
      if(count==1000){
        print(paste("More than 1000 tries to find converging threshold...., moving on to next k. No data for edges =",nEdgesOrThreshold))
        stop(paste("remove",nEdgesOrThreshold,"nEdgesOrThreshold from your analysis input if you want this to run"))
      }
    }
    if((sum(threshcorGroupData>threshold)/2)==nEdgesOrThreshold){
      #print("threshold converged, binarizing graphs")
      #print(paste("threshold is",threshold))
      threshTally<<-c(threshTally,threshold)
      holderGraph<-threshcorGroupData #need this in the case that the threshold has to drop below 0, make sure to use because before I had this I had to spend a couple hours troubleshooting to find that I need this
      threshcorGroupData[holderGraph < threshold]<-0
      threshcorGroupData[holderGraph >= threshold]<-1
      igraph1<-graph.adjacency(threshcorGroupData)
      if(clusters(graph =igraph1)$no!=1){
        print("the graph is not fully connected which may influence graph measure calculations")
        message<-paste(as.character(nEdgesOrThreshold))
        write.table(message,file = paste(outputDirectory,"unconnectedLog",analysisDate,sep = ""),append = T,col.names =F )
        numNotFullyConnected<<-numNotFullyConnected+1
      }
      return(threshcorGroupData)
    }else{print(paste("no thresholding convergence, number of edges in graph is",sum(threshcorGroupData>threshold)/2,"k is",nEdgesOrThreshold))}
  }
  #this is the case where you want equithresholded matrices, less common route
  if(equi=="thresh"){
    threshcorGroupData<-connectivityMatrix1
    diag(threshcorGroupData)<-0
    #threshcorGroupData<-as.matrix(threshcorGroupData)
    threshcorGroupData[threshcorGroupData < nEdgesOrThreshold]<-0
    threshcorGroupData[threshcorGroupData >= nEdgesOrThreshold]<-1
    igraph1<-graph.adjacency(threshcorGroupData)
    if(clusters(graph =igraph1)$no!=1){
      print("the graph is not fully connected which may influence graph measure calculations")
    }
    return(threshcorGroupData)
  }
}