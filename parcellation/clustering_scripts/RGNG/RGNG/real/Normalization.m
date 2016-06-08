function [trainset,testset] = Normalization(trainset,testset)
trainsize=size(trainset,1);
Dataset=[trainset;testset];
[row,column] = size(Dataset);
NormData = [];
for i = 1:column-1
    plustemp = (max(Dataset(:,i))+min(Dataset(:,i)))/2;
    minustemp = (max(Dataset(:,i))-min(Dataset(:,i)))/2;
    if (minustemp~=0) & (~(max(Dataset(:,i))==1 & min(Dataset(:,i))==-1))
        NormData = [NormData,(Dataset(:,i)-plustemp)/minustemp];
    else
        NormData=[NormData,Dataset(:,i)];
    end
end
Dataset=[NormData,Dataset(:,column)];
trainset=Dataset(1:trainsize,:);
Dataset(1:trainsize,:)=[];
testset=Dataset;
