function [result]=GNGrunreal(dataset,inicenter,noisenum,prenode);
rand('state',0);
% dataset -------- the data used
% inicenter -------- the initial cluster center positions
% noisenum --------- the number of noise point added to the dataset
% result -------- the clustering results and some performance measures
% prennode --------- the predefined maximum number of clusters to grow

% Normalize the dataset
[dataset,dataset]=Normalization(dataset,dataset);

[optcenter,mdlvalue] = GNGTrain(dataset,inicenter,prenode);
temptrain=dataset(1:size(dataset,1)-noisenum,:);
[pq] = PQvalue(optcenter,temptrain);
[value,minindex]=min(mdlvalue);
optcounter=minindex+1;

result.optcounter=optcounter; % The number of prototypes founded
result.pq=pq; % PQ value
result.mdlvalue=mdlvalue; % The MDL value from 2 to the "prenode"
plot(2:size(result.mdlvalue,2)+1,result.mdlvalue,'r-');