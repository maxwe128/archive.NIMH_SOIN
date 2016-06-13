#Exploration of the Igrapg package functionality using a simulated dataset
#done on a day when linux was down so I had no other choice

#creation and formatting of data
rawSim<-replicate(100, rnorm(20)) 
corSim<-cor(rawSim)
threshcorSim<-corSim
threshcorSim[corSim < .2]<-0
threshcorSim[corSim == 1]<-0
threshcorSim[threshcorSim >= .2]<-1
image(threshcorSim,col=c("black","white"))# easy way to view adjacency matrix
threshcorSim_igraph<-graph.adjacency(threshcorSim)#have to do this so you can use igraph functions, seems to just reformat data into their unique format without changing it.

#two of the toolboxes visualization methods
plot(threshcorSim_igraph)
tkplot(threshcorSim_igraph)

#Test of functons used in previous bermanlab analyses
###################################################################################
#Characteristic path length
average.path.length(threshcorSim_igraph, directed=F, unconnected=TRUE)
#knet or the average degree or number of connections of each node
c <- clusters(threshcorSim_igraph)#groups all nodes into the same group if they are connected to any other node in a group
vsl <- which(which.max(c$csize)==c$membership)
mean(degree(threshcorSim_igraph, vsl))
#Clustering Coefficient, Cnet or Transitivity, make sure this is the same as from the previous analyses
transitivity(threshcorSim_igraph,type="global")#ratio of triangles and connected triples in the graph
#Assortativity, MAKE SURE THIS IS THE SAME AS PREVIOUS ANALYSES
assortativity.degree(threshcorSim_igraph,directed=T)
#Average path length and its inverse, global efficiency
average.path.length(threshcorSim_igraph, directed=F, unconnected=F)
1/average.path.length(threshcorSim_igraph, directed=F, unconnected=F)

#FIGURE OUT HOW TO CALCULATE LOCAL EFFICENCY, LOCAL:Ratio of # of connections between i's neighbors to total # possible
