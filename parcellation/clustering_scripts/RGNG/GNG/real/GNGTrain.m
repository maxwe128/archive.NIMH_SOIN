function [optcenter,allmdlvalue] = GNGTrain(dataset,center,prenumnode)
% dataset --------- the data used
% center ---------- the initial cluster center positions
% prenumnode ----------- the predefined maximum number of clusters to grow
% optcenter ----------- the obtained cluster center positions corrresponding to the minimal description length
% actcenter -------- the cluster center positions when the number of cluster center is equal to the actual one
% allmdlvalue --------- the MDL value caculated at each growth stage

rand('state',0);
GNG.dataset=dataset;

%Initialize the GNG structure
GNG=InitGNG(GNG,center,prenumnode);

%Training GNG network
[optcenter,allmdlvalue]=TrainGNG(GNG);