CalculateBrainWideConnectivityMeasures<-function(Igraph_of_interest){
  #brain wide Measures (has a measure for each node)
  betweenness<-betweenness(Igraph_of_interest,directed=F)
  closeness<-closeness(Igraph_of_interest)
  degree<-degree(Igraph_of_interest)
  eigenvector<-evcent(Igraph_of_interest,directed = F)
  #centralityMeasures<-rbind(betweenness,closeness,degree,eigenvector)
  transitivity<-transitivity(Igraph_of_interest,type = "local")
  brainWideMeasures<-rbind(betweenness,closeness,degree,eigenvector$vector,transitivity)
  row.names(brainWideMeasures)<-c("betweenness","closeness","degree","eigenvector","transitivity")
  return(brainWideMeasures)
}