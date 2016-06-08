function [averageSTDForEachClusterSolution] = calculateAverageStandardDeviationAcrossClusters()
%STRUCT_SPECTRAL_CLUSTERING 		Spectral Clustering on Structural Covariance Maps
%
%
%	struct_spectral_clustering(data_filename, ROI_filename, k)
%
%	
%
% David (Ellis) Hershkowitz, Nick Turner, 2013

if(~exist('totalClusters','var'))
	totalClusters = 15;
end

% if(~exist('nameOfFiles','var'))
% 	error
% end
%===========================================================================
	%Errors for improper variable inputs
	% [status, string] = system('ls');
	% [row col] = size(string);
	% if row ~= 0
	% 	error('Start in an empty directory. I do not want my script messing something up when it rms...')
	% end

%=======================================================================
% Setting up environment
scripts_dir = '/x/wmn14/turnernl/CLUSTERING/scripts/';

% Utility locations
afni_tools = strcat(scripts_dir,'afni_matlab/matlab');

% Linking tools
addpath(genpath(afni_tools))

%=======================================================================
% CALL NICKS FUNCTION

STDOfSTD = zeros(1, totalClusters-1);
averageSTDForEachClusterSolution = zeros(1, totalClusters-1);
minOfSTDs = zeros(1, totalClusters-1);
maxOfSTDs = zeros(1, totalClusters-1);

%Loop through cluster solutions

for currClusterSolution = 2:totalClusters
	solutionName = strcat('GRSTDMAPS_k',int2str(currClusterSolution), '+tlrc');

	currentSolution = BrikLoad(solutionName);
	[rows columns backs clusters] = size(currentSolution);
	reshapeCurrentSolution = reshape(currentSolution, 1, rows*columns*backs, clusters);
	[one voxelsInSolution clusters] = size(reshapeCurrentSolution);
	averageSTDsForAllClustersInThisSolution = zeros(1, currClusterSolution);

	%Loop through clusters
	for currCluster = 1:currClusterSolution
		sumOfSTDsForThisCluster = sum(reshapeCurrentSolution(1, :, currCluster));
		averageSTDForThisCluster = sumOfSTDsForThisCluster/voxelsInSolution;
		averageSTDsForAllClustersInThisSolution(currCluster) = averageSTDForThisCluster;
	end
	averageSTDsForAllClustersInThisSolution
	averageSTDForThisSolution = mean(averageSTDsForAllClustersInThisSolution);
	averageSTDForEachClusterSolution(currClusterSolution-1) = averageSTDForThisSolution;
end;