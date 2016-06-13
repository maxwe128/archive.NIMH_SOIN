CalculateConnectivityMeasures<-function(Igraph_of_interest){
  #input requires a Igraph adjacency matrix
  #add Measures here to influence output of Calculate_GraphTheory
  indIgraph_Measure<-{}
  ###Creation of a matching random graph with same number of edges and vertices####
  rand<-erdos.renyi.game(n = vcount(Igraph_of_interest),p.or.m = ecount(Igraph_of_interest),type = "gnm")
  ##############Calculation of relevant Graph Measures##########
  #Characteristic path length
  average.path.length<-average.path.length(Igraph_of_interest, directed=F, unconnected=TRUE)
  #Knet or the average degree or number of connections of each node
  c <- clusters(Igraph_of_interest)#groups all nodes into the same group if they are connected to any other node in a group
  vsl <- which(which.max(c$csize)==c$membership)
  Knet<-mean(degree(Igraph_of_interest, vsl))
  #Clustering Coefficient, Cnet or Transitivity, make sure this is the same as from the previous analyses
  Cnet<-transitivity(Igraph_of_interest,type="global")#ratio of triangles and connected triples in the graph
  Crand<-transitivity(rand,type="global")
  gamma<-Cnet/Crand
  #Assortativity, MAKE SURE THIS IS THE SAME AS PREVIOUS ANALYSES
  assortativity<-assortativity.degree(Igraph_of_interest,directed=F)
  #Average path length(lnet) and its inverse, global efficiency
  Lnet<-average.path.length(Igraph_of_interest, directed=F, unconnected=T)
  globalEfficiency<-1/average.path.length(Igraph_of_interest, directed=F, unconnected=F)
  Lrand<-average.path.length(rand,directed = F,unconnected =(clusters(graph =rand)$no!=1))
  lambda<-Lnet/Lrand
  #small worldness
  smallWorldness<-lambda/gamma
  #proof of Consistency
  nEdges<-ecount(Igraph_of_interest)
  #Checks for fully connected graph
  fullyConnected<-clusters(graph =Igraph_of_interest)$no==1
  #####Final output of Measures#####
  indIgraph_Measure<-cbind(Lnet,Lrand,Knet,Cnet,Crand,assortativity,globalEfficiency,nEdges,lambda,gamma,smallWorldness,fullyConnected)
  #print(indIgraph_Measure)
  return(indIgraph_Measure)
  #############################################################################
}

