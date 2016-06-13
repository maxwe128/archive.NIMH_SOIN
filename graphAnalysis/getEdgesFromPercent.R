#gives you the number of edges that you need to retain in your graph if you want x% of connections retatained
#main use is to facilitate input into Calculate_GraphTheory.R so that you dont have to manually calculate the number of edges you want.

getEdgesFromPercent<-function(percents,numberOfNodes,directed=F){
  maxEdges<-(numberOfNodes*(numberOfNodes-1))/2
  return(round((percents/100)*maxEdges))
}