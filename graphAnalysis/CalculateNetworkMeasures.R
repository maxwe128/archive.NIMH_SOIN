CalculateConnectivityMeasures<-function(Igraph_of_interest){
  #input requires a Igraph adjacency matrix
  #add Measures here to influence output of Calculate_GraphTheory
  indIgraph_Measure<-{}
  ##############Calculation of relevant Graph Measures##########
  #Characteristic path length
  average.path.length<-average.path.length(Igraph_of_interest, directed=F, unconnected=TRUE)
  #Knet or the average degree or number of connections of each node
  c <- clusters(Igraph_of_interest)#groups all nodes into the same group if they are connected to any other node in a group
  vsl <- which(which.max(c$csize)==c$membership)
  Knet<-mean(degree(Igraph_of_interest, vsl))
  #Clustering Coefficient, Cnet or Transitivity, make sure this is the same as from the previous analyses
  Cnet<-transitivity(Igraph_of_interest,type="global")#ratio of triangles and connected triples in the graph
  #Assortativity, MAKE SURE THIS IS THE SAME AS PREVIOUS ANALYSES
  assortativity<-assortativity.degree(Igraph_of_interest,directed=F)
  #Average path length and its inverse, global efficiency
  averagePathLength<-average.path.length(Igraph_of_interest, directed=F, unconnected=T)
  globalEfficiency<-1/average.path.length(Igraph_of_interest, directed=F, unconnected=F)

  indIgraph_Measure<-cbind(average.path.length,Knet,Cnet,assortativity,globalEfficiency)
  print(indIgraph_Measure)
  return(indIgraph_Measure)
  #############################################################################
}