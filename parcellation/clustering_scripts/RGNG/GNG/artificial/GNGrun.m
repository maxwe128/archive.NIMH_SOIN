function [result]=GNGrun(dataset,inicenter,realcenter,noisenum,prenode);

% dataset -------- the data used
% inicenter -------- the initial cluster center positions
% realcenter -------- the actual cluster positions
% noisenum --------- the number of noise point added to the dataset
% result -------- the clustering results and some performance measures
% prennode --------- the predefined maximum number of clusters to grow

[optcenter,actcenter,mdlvalue] = GNGTrain(dataset,inicenter,prenode,size(realcenter,1));
temptrain=dataset(1:size(dataset,1)-noisenum,:);
[counter,E,value] = runmultimod(actcenter,temptrain,realcenter)
[pq] = PQvalue(optcenter,temptrain);
[value,minindex]=min(mdlvalue);
optcounter=minindex+1;

result.optcounter=optcounter; % The number of prototypes founded
result.pq=pq; % PQ value
result.mdlvalue=mdlvalue; % The MDL value from 2 to the "prenode"

% Performance measures when the number of prototype is equal to the actual number of clusters
result.findnodes=counter; % The number of clusters founded when the number of prototype is equal to the actual number of clusters 
result.mse=value; % Mean square error from obtained cluster centers to actual cluster centers
result.E=E; % Average quantization error for each node

plot(2:size(result.mdlvalue,2)+1,result.mdlvalue,'r-');