#Consider creating a bash wrapper around this script to use a mask to grab avg values for each individual or group which would
#then be passed into this function as a list of those files
#currently data needs to be in form of x columns by y rows, where each x is an node and each y is an observation at that node.
#in the individual level each y is an individuals separate observation(Example: 1 run of the nback, or 1 TR during rest fMRI)
#output is a matrix of relevant graph theory values for the individual and or group passed in as dataList. Need to run for each group
#separately(at this point, may want to Change) as well as 

#############################Input Assumptions######################################
#1) data in the data list is in the form of columns=nodes and rows= observations. Observations are within individuals in individual
#level analysis. In group analysis observations are one data point from each individual
#2) If comparision is True then the dataList is a list of lists. In individual analyses the original list has one entry for each group  to be compared and 
#each entry is a list of locations of the data files. In group level, the list is the pointer to each group data file.
#3) For the nEdgesOrThreshold arg you either give it a number between 0 and 1 which creates equithresholded matrices, or you enter an
#integer which creates equisparse matrices. This is done by calling the threshGraph function. You can also input multiple numbers e.g c(1,5,50) which will
#allow for multiple thresholding and do the entire calculation for each threshold. Consider using getEdgesFromPercent.R if you want to pass in percents to
#the nEdgesorThreshold argument. Example: getEdgesFromPercent(1:99,116) would give you the # of edges need to fill a graph 1:99% full given the graph has 
#116 nodes. Warning: the # of edges will be rounded so that they always have integer values

##############################Things to add to pipeline################################
#1)add in dynamic sliding window calculations across individuals dataset to get variability of measures
#2)Figure out what to do when thresholding doesnt converge, how to deal with in comparisons
#3)Figure out how you want to do permutation testing
#4)Add in windowed thresholding
#5)brainwaver? wavelet decompostion analysis
#6)
#7)
#8)add in directed matrices
#9)add in weighted matrices

Calculate_GraphTheory<-function(dataList, nEdgesOrThreshold, analysisType="group", outputDirectory="/x/wmn18/elliottml/GraphTheoryAnalyses/prototypePipeline/", comparison=FALSE,prefix="NetworkMeasures", threshType="positive",edgeType="pearson",structuralData=F, numberPermutations=10000,brainWide=T,pairedPerm){
  #check for each of the necessary args
  #checks for presence of data
  require("igraph")
  require("corpcor")
  require("abind")
  source("/x/wmn18/elliottml/GraphTheoryAnalyses/scripts/getEdgesFromPercent.R")
  source("/x/wmn18/elliottml/GraphTheoryAnalyses/scripts/CalculateConnectivityMeasures.R")#function i wrote to clean up network measure calculations
  source("/x/wmn18/elliottml/GraphTheoryAnalyses/scripts/permutationTest.R")
  source("/x/wmn18/elliottml/GraphTheoryAnalyses/scripts/threshGraph.R")
  source("/x/wmn18/elliottml/GraphTheoryAnalyses/scripts/getGraphMeasures.R")
  source('/x/wmn18/elliottml/GraphTheoryAnalyses/scripts/listToMatrixByRow.R')
  source('/x/wmn18/elliottml/GraphTheoryAnalyses/scripts/CalculateBrainWideConnectivityMeasures.R')
  source('/x/wmn18/elliottml/GraphTheoryAnalyses/scripts/metaListRearrange.R')
  source('/x/wmn18/elliottml/GraphTheoryAnalyses/scripts/formatStructuralOutput.R')
  gt<-function(x,y){t<-x>y;return(t)}
  lt<-function(x,y){t<-x<y;return(t)}
  file.create(paste(outputDirectory,"/unconnectedLog",Sys.Date(),sep=""))
  analysisDate<<-Sys.Date()
  if(missing(dataList)){
    stop("no List of dataFiles, exitting......")
  }
  #Handles nEdgesOrThreshold
  if(max(nEdgesOrThreshold)>-1 && max(nEdgesOrThreshold)<1){
    print("This is an equiTHRESHOLD analysis")
    sparseOrThresh<-"thresh"
  }else if(max(nEdgesOrThreshold)>=1){
    print("This is an equiSPARSE analysis")
    sparseOrThresh<-"sparse"
  }else{
    stop("you entered and invalid nEdgesOrThreshold value")
  }
  #Handles analysis type and computes graphs based on Type and above inputs
  if(analysisType=="individual" && comparison==FALSE){
    print("performing individual level analysis")
    indIgraph_Measures<-getGraphMeasures(dataList = dataList,nEdgesOrThreshold=nEdgesOrThreshold,sparseOrThresh = sparseOrThresh,threshType=threshType,edgeType=edgeType,structuralData=structuralData,brainWide=brainWide)
    write.table(indIgraph_Measures,file=paste(outputDirectory,prefix,"_table_",format(Sys.time(),"%m%d%y.%H%M"),".txt",sep=""))
  }
  
  #group dataList without comparison should be a file where each input is a path to the individuals datasets in each group(a list of lists)
  if(analysisType=="group"&&comparison==FALSE){
    print("performing group level analysis")
    groupData<-as.matrix(read.table(dataList))
    for(j in 1:length(groupData)){
      groupIgraph_Measures<-getGraphMeasures(dataList = as.character(groupData[j]),nEdgesOrThreshold=nEdgesOrThreshold,sparseOrThresh = sparseOrThresh,threshType=threshType,edgeType=edgeType,structuralData=structuralData,brainWide=brainWide)
      write.table(groupIgraph_Measures,file=paste(outputDirectory,prefix,"_","Group",j,"_table_",format(Sys.time(),"%m%d%y.%H%M"),".txt",sep=""))
    }
  }
  if(analysisType=="individual"&&comparison==TRUE){##may not need to make don't see why I would do individual analyses
    print("this type of analysis is not implemented yet. Does not seem to have utility, ask Max if you think it does")
  }
  if(analysisType=="group"&&comparison==TRUE){
    print("performing group level analysis")
    groupData<-as.matrix(read.table(dataList))
    for(j in 1:length(groupData)){
      assign(paste("group",j,"IgraphMeasures",sep = ""),getGraphMeasures(dataList = as.character(groupData[j]),nEdgesOrThreshold=nEdgesOrThreshold,sparseOrThresh = sparseOrThresh,threshType=threshType,edgeType=edgeType,structuralData=structuralData,brainWide=brainWide,outputDirectory=outputDirectory),envir = .GlobalEnv)
      assign(paste("group",j,"IgraphMeasures",sep = ""),getGraphMeasures(dataList = as.character(groupData[j]),nEdgesOrThreshold=nEdgesOrThreshold,sparseOrThresh = sparseOrThresh,threshType=threshType,edgeType=edgeType,structuralData=structuralData,brainWide=brainWide,outputDirectory=outputDirectory),envir = .GlobalEnv)
      #write.table(paste("group",j,"IgraphMeasures"),file=paste(outputDirectory,prefix,"_","Group",j,"_table_",format(Sys.time(),"%m%d%y.%H%M"),".txt",sep=""))
    }
    if(nrow(groupData)==1){#this is the case where the permutation testing is with random graphs do establish significance
      print("performing metric comparisons with random graphs")
      for(j in 1:length(group1IgraphMeasures[[1]])){
        randMeasures<-{}
        for(i in 1:nrow(group1IgraphMeasures[[j]])){
          randGraph<-erdos.renyi.game(n=vcount(graph1Igraph),p.or.m=ecount(graph1Igraph),type="gnm",)
          randMeasures<-rbind(randMeasure,CalculateConnectivityMeasures(Igraph_of_interest = randGraph))
        }
        permResults<-permutationTest(group1IgraphMeasures,randMeasures)
        print(permResults)
      }
    }else{#this is the case where permutation testing is with another group to establish differences between groups
      if(structuralData==F){
        for(j in 1:length(group1IgraphMeasures)){
          permResults<-permutationTest(group1IgraphMeasures[[j]],group2IgraphMeasures[[j]])
          print(permResults)
        }
      }else{#This is when you want to do permutation testing with Structural type data
        group1List<-read.table(as.character(groupData[1,]))
        group2List<-read.table(as.character(groupData[2,]))
        group1Measures<-group1IgraphMeasures[[1]]
        group2Measures<-group2IgraphMeasures[[1]]
        group1BWmeasures<-group1IgraphMeasures[[2]]
        group2BWmeasures<-group2IgraphMeasures[[2]]
        group1Size<-nrow(group1List)
        group2Size<-nrow(group2List)
        bothList<-rbind(group1List,group2List)
        bothListPaired<-cbind(group1List,group2List)
        randDifferencesList<-vector("list",numberPermutations)#right now the indexing is [[x]] is the permutation and the rows in [[x]] is the difference at a threshold in [[X]]
        randGroupBWDiffMetaList<-{}
        groupDifferencesMatrix<-{}
        groupDiffBWList<-{}
        for(j in 1:length(nEdgesOrThreshold)){
          groupDifference<-group1IgraphMeasures[[1]][j,]-group2IgraphMeasures[[1]][j,]
          groupDifferencesMatrix<-rbind(groupDifferencesMatrix,groupDifference)
          groupDiffBWList[[j]]<-group1BWmeasures[[j]]-group2BWmeasures[[j]]
        }      
          time<-proc.time()
          timeElapsed<-as.integer(as.matrix(time)[3,])
          for(i in 1:numberPermutations){
            randGroupDifferences<-{}
            randGroupBWDiffList<-{}
            if(pairedPerm==F){
              allRand<-sample(as.matrix(bothList,nrow(bothList),replace=F))
              group1Rand<-as.matrix(allRand[1:nrow(group1List)])
              group2Rand<-as.matrix(allRand[(nrow(group1List)+1):(nrow(group1List)+nrow(group2List))])
            }
            if(pairedPerm==T){
              ##This should be used when you have two groups with the same subjects in each group
              pairedList<-matrix(apply(X = bothListPaired,MARGIN = 1,FUN = sample),nrow=2)
              group1Rand<-pairedList[1,]
              group2Rand<-pairedList[2,]
            }
            write.table(group1Rand,paste(outputDirectory,"group1Rand.txt",sep=""))
            write.table(group2Rand,paste(outputDirectory,"group2Rand.txt",sep=""))         
            group1RandMeasures<-getGraphMeasures(paste(outputDirectory,"group1Rand.txt",sep=""),sparseOrThresh = "sparse",nEdgesOrThreshold = nEdgesOrThreshold,threshType = threshType,edgeType=edgeType,structuralData = structuralData,brainWide=brainWide,outputDirectory=outputDirectory)
            group2RandMeasures<-getGraphMeasures(paste(outputDirectory,"group2Rand.txt",sep=""),sparseOrThresh = "sparse",nEdgesOrThreshold = nEdgesOrThreshold,threshType = threshType,edgeType=edgeType,structuralData = structuralData,brainWide=brainWide,outputDirectory=outputDirectory)
            for(j in 1:length(nEdgesOrThreshold)){
              randGroupDifferences<-rbind(randGroupDifferences,group2RandMeasures[[1]][j,]-group1RandMeasures[[1]][j,])
              randGroupBWDiffList[[j]]<-group2RandMeasures[[2]][[j]]-group1RandMeasures[[2]][[j]]
            }
            randDifferencesList[[i]]<-randGroupDifferences
            randGroupBWDiffMetaList[[i]]<-randGroupBWDiffList#woah this just got meta bro, The structure is randGroupBWDiffMetaList[[permutation]][[sparsity]]
            print(paste(i/numberPermutations*100,"% done"))
            timeLeft<-timeElapsed*(1/(i/numberPermutations))/60
            print(paste(timeLeft,"minutes remaining"))
          }
        file.remove(paste(outputDirectory,"group1Rand.txt",sep=""))
        file.remove(paste(outputDirectory,"group2Rand.txt",sep=""))
        
        #permutation testing to get a p-value
        reformRandDiff<-listToMatrixByRow(randDifferencesList)#makes a list where each entry in a list is a matrix of all permutations of one sparsity. Should make perm testing easier       
        permTestResults<-{}
        reformRandGroupBWDiffMetaList<-metaListRearrange(randGroupBWDiffMetaList)
        permTestBWList<-{}
        sumPermTestBWList<-{}
        for(sparsity in 1:length(nEdgesOrThreshold)){
          permTestResults<-rbind(permTestResults,apply(X = reformRandDiff[[sparsity]]>groupDifferencesMatrix[sparsity,],2,sum))
          permTestBWList[[sparsity]]<-lapply(reformRandGroupBWDiffMetaList[[sparsity]],FUN=gt,y=groupDiffBWList[[sparsity]])
          sumPermTestBWList[[sparsity]]<-Reduce("+",permTestBWList[[sparsity]])/numberPermutations#sums up all permutation results so that you have list where the proportion of rand differences greater than actual difference is shown
        }
        
        permTestResults<-permTestResults/numberPermutations
        row.names(permTestResults)<-as.character(nEdgesOrThreshold)
        ROIlabels<-readLines("/home/eisenbergd/scripts/networkmeasuresprep/ROIlabels")
        structOutput<-formatStructuralOutput(group1 = group1IgraphMeasures,group2=group2IgraphMeasures,randGroupBWDiffMetaList1 = randGroupBWDiffMetaList,groupDiffBWList =groupDiffBWList,outputDirectory = outputDirectory,nEdgesOrThreshold1 = nEdgesOrThreshold,numberPermutations1 = numberPermutations)
        groupOutput<-list(groupDifferencesMatrix,reformRandDiff,permTestResults,groupDiffBWList,reformRandGroupBWDiffMetaList,permTestBWList,sumPermTestBWList,structOutput)
        names(groupOutput)<-c("groupDiff","randDiff","permTestResults","groupDiffBW","RandGroupDiffBW","permTestResultsBW","sumPermTestBWList","structOutput")
        return(groupOutput)
        }

      
    }
  if(analysisType!="group" && analysisType!="individual"){
    stop("incompatible analysis type....Exiting")
  }
}
  #potential 3d graphing example
  #cords<-layout.fruchterman.reingold(threshcorSim_igraph,dim=3)
  #rglplot(threshcorSim_igraph,layout=cords)
  
  #for(i in 1:length(two_bk_files)){two_bk_files_long<-paste("/x/wmn21/elliottml/GraphTheoryAnalyses/data/nbackROIrawLocal","/",two_bk_files[i],sep="")}
  
}

