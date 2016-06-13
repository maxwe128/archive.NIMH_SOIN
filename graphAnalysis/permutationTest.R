########### This function takes in two matrices of group measures, where rows are observations and each column is a different measure. It
#then calculates the chances of observing the original difference between groups if the group affiliation did not exist and observations 
#in each group where mixed into two random groups. Each group has to be specified and used erdos.renyi.game to make random graphs and graph
#measure for comparison before implementing this function. 
permutationTest<-function(group1,group2,number_permutations=10000){
  if(ncol(group1)==1){#handles the case where only one graph metric needs to be compared
    diff.groups<-mean(group1)-mean(group2)
    diff.random<-NULL
    allData<-c(group1,group2)
    for(i in 1:number_permutations){
      a.random<-sample(allData,length(group1),replace = T)
      b.random<-sample(allData,length(group2),replace=T)
      diff.random[i]<-mean(b.random)-mean(a.random)
    }
    pvalue = sum(abs(diff.random) >= abs(diff.groups)) / number_permutations
    return(paste("the pvalue is: ",pvalue/number_permutations))#fix this so that it is more manipulatable form
  }
  if(ncol(group1)>1){#handles the more common case where multiple graph metrics need to be compared between groups
    diff.groups<-apply(group1,2,function(x) mean(x))-apply(group2,2,function(x) mean(x))
    allData<-rbind(group1,group2)
    diff.random<-matrix(NA,nrow=number_permutations,ncol=ncol(group1))
    colnames(diff.random)<-colnames(group1)
    pvalues<-matrix(NA,nrow=1,ncol=ncol(group1))
    colnames(pvalues)<-colnames<-(group1)
    for(j in 1:ncol(group1)){
      for(i in 1:number_permutations){
        a.random<-sample(allData[,j],length(group1[,j]),replace=T)
        b.random<-sample(allData[,j],length(group2[,j]),replace=T)
        diff.random[i,j]<-mean(b.random)-mean(a.random)
      } 
      pvalues[1,j]<-as.integer(sum(abs(diff.random[,j]) >= abs(diff.groups[j])))
    }
    return(paste("the pvalue is: ", as.integer(pvalues)/number_permutations))#fix this so that it is more manipulatable form  
  }
}

