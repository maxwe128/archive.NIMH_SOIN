function standardize_clusters (template_cluster_filename, to_standardize_cluster_filename,  total_number_of_clusters)
%STANDARDIZE_CLUSTERS 		Spectral Clustering on Structural Covariance Maps
%
%
%	standardize_clusters(template_cluster_filename, to_standardize_cluster_filename)
%
%	
%
%Nicholas Turner, David (Ellis) Hershkowitz, 2013

if(~exist('template_cluster_filename','var'))
	error()
end

if(~exist('to_standardize_cluster_filename', 'var'))
	error()
end
%=======================================================================
%For TESTING
template_cluster_filename = '/x/wmn14/turnernl/CLUSTERING/BILATERAL_NOT_SIMULTANEOUS_IPS_MASK/____tmp_LSPLIT_TEST_solutions+tlrc.HEAD';
to_standardize_cluster_filename = '/x/nimbus2/FROM_Biowulf/SIN_rest/analyses/parcellation/CONSENSUS.IPS.LEFT.K15.combined+tlrc';
total_number_of_clusters = 15;

%=======================================================================
% Setting up environment
scripts_dir = '/x/wmn14/turnernl/CLUSTERING/scripts/';

% Utility locations
afni_tools = strcat(scripts_dir,'afni_matlab/matlab');


% Linking tools
addpath(genpath(afni_tools))

%=======================================================================
% Loading Data

[template, template_info] = BrikLoad(template_cluster_filename);
[to_standardize, to_standardize_info] = BrikLoad(to_standardize_cluster_filename);

%=======================================================================
for cluster_solution_to_standardize = 2:total_number_of_clusters
	disp(strcat('Standardizing clusters for ', int2str(cluster_solution_to_standardize), 'solution...'))
	%Count voxels in each cluster and total x,y,zs of each cluster in template and absolute voxel overlap

	voxels_in_clusters_in_template = zeros(3, cluster_solution_to_standardize);
	totalXYZs_of_template_cluster = zeros(3, cluster_solution_to_standardize);

	voxels_in_clusters_in_to_standardize= zeros(3, cluster_solution_to_standardize);
	totalXYZs_of_to_standardize_cluster = zeros(3, cluster_solution_to_standardize);

	voxel_overlap_matrix = zeros(cluster_solution_to_standardize, cluster_solution_to_standardize);

	totalVoxelsInTemplateClusters = 0;

	totalVoxelsInToStandardizeClusters = 0;

	[rows, columns, backs, clusters] = size(to_standardize);

		for currRow = 1:rows
			for currCol = 1:columns
				for currBack = 1:backs
					currClusterValTemplate = template(currRow, currCol, currBack, cluster_solution_to_standardize-1);
					if currClusterValTemplate > 0
						voxels_in_clusters_in_template(:, currClusterValTemplate) = voxels_in_clusters_in_template(1, currClusterValTemplate) + 1;
						totalXYZs_of_template_cluster(1, currClusterValTemplate) = totalXYZs_of_template_cluster(1, currClusterValTemplate) + currRow;
						totalXYZs_of_template_cluster(2, currClusterValTemplate) = totalXYZs_of_template_cluster(2, currClusterValTemplate) + currCol;
						totalXYZs_of_template_cluster(3, currClusterValTemplate) = totalXYZs_of_template_cluster(3, currClusterValTemplate) + currBack;
						totalVoxelsInTemplateClusters = totalVoxelsInTemplateClusters + 1;
					end
					currClusterValToStandardize = to_standardize(currRow, currCol, currBack, cluster_solution_to_standardize-1);
					if currClusterValToStandardize > 0
						voxels_in_clusters_in_to_standardize(:, currClusterValToStandardize) = voxels_in_clusters_in_to_standardize(1, currClusterValToStandardize) + 1;
						totalXYZs_of_to_standardize_cluster(1, currClusterValToStandardize) = totalXYZs_of_to_standardize_cluster(1, currClusterValToStandardize) + currRow;
						totalXYZs_of_to_standardize_cluster(2, currClusterValToStandardize) = totalXYZs_of_to_standardize_cluster(2, currClusterValToStandardize) + currCol;
						totalXYZs_of_to_standardize_cluster(3, currClusterValToStandardize) = totalXYZs_of_to_standardize_cluster(3, currClusterValToStandardize) + currBack;
						totalVoxelsInToStandardizeClusters = totalVoxelsInToStandardizeClusters +1;
					end
					if currClusterValToStandardize > 0 & currClusterValTemplate > 0
					voxel_overlap_matrix(currClusterValTemplate, currClusterValToStandardize) = voxel_overlap_matrix(currClusterValTemplate, currClusterValToStandardize) + 1;
					end
				end

			end

		end


	%============================================
	%Calculate overlaps as a percentage of cluster sizes

	voxel_overlap_matrix_percentages = zeros(cluster_solution_to_standardize, cluster_solution_to_standardize);
	for row = 1:cluster_solution_to_standardize
		for column = 1:cluster_solution_to_standardize
			voxel_overlap_matrix_percentages(row, column) = voxel_overlap_matrix(row, column)*2/(voxels_in_clusters_in_template(1, row) + voxels_in_clusters_in_to_standardize(1, column));
		end
	end


	%=======================================================================
	%Calculate centroid of clusters using totalXYZs divided by number of voxels in each cluster

	% template_cluster_centroids = totalXYZs_of_template_cluster ./ voxels_in_clusters_in_template;
	% to_standardize_cluster_centroids = totalXYZs_of_to_standardize_cluster ./ voxels_in_clusters_in_to_standardize;

	%============================================
	%GREEDY SOLUTION Calculate likely cluster matches based on centroids -- in the matrix a 1 indicates a likely cluster and a 0 indicates clusters whose centroids are so far that they are unlikely to be matched


	% %	================================
	% %	Calculate centroid distances
	% 	centroidDistances = zeros(cluster_solution_to_standardize, cluster_solution_to_standardize);
	% 	for row = 1:cluster_solution_to_standardize
	% 		for column = 1:cluster_solution_to_standardize
	% 			centroidDistances(row, column) = sqrt((template_cluster_centroids(1, row)-to_standardize_cluster_centroids(1, column))^2+(template_cluster_centroids(2, row)-to_standardize_cluster_centroids(2, column))^2+(template_cluster_centroids(3, row)-to_standardize_cluster_centroids(3, column))^2);
	% 		end
	% 	end

	% 	centroidCloseness = centroidDistances;
	% 	for row = 1:cluster_solution_to_standardize
	% 		for column = 1:cluster_solution_to_standardize
	% 			centroidCloseness(row, column) = 1/centroidDistances(row, column);
	% 		end
	% 	end

	% 	maxCloseness = max(max(centroidCloseness, [], 1));

	% 	for row = 1:cluster_solution_to_standardize
	% 		for column = 1:cluster_solution_to_standardize
	% 			centroidCloseness(row, column) = centroidCloseness(row, column)/maxCloseness;
	% 		end
	% 	end

	% 	%Calculate score matrix

	% 	scoreMatrix =  voxel_overlap_matrix_percentages;




	% likely_cluster_candidate = zeros(cluster_solution_to_standardize, cluster_solution_to_standardize);
		
	% for current_cluster = 1:cluster_solution_to_standardize
	% 	while(1)
	% 		[maxValue, maxIndx] = max(scoreMatrix(current_cluster,:),[],2);
	% 		likely_cluster_candidate(current_cluster, maxIndx) = 1;
	% 		 if sum(likely_cluster_candidate(:, maxIndx)) ~= 1
	% 		 	likely_cluster_candidate(current_cluster, maxIndx) = 0;
	% 		 	scoreMatrix(current_cluster, maxIndx) = 0;
	% 		 else
	% 		 	break
	% 		 end
	% 	 end
	% end


	%============================================
	%Non-Greedy SOLUTION Calculate likely cluster matches based on centroids -- in the matrix a 1 indicates a likely cluster and a 0 indicates clusters whose centroids are so far that they are unlikely to be matched

	scoreMatrix =  voxel_overlap_matrix_percentages;




	likely_cluster_candidate = zeros(cluster_solution_to_standardize, cluster_solution_to_standardize);
		
	maxVals = zeros(1, cluster_solution_to_standardize);

	tempScoreMatrix = scoreMatrix;
%Assign best, unique maxes row wise
	for current_cluster = 1:cluster_solution_to_standardize
		  while(1)
			[maxValue, maxIndx] = max(tempScoreMatrix(current_cluster,:),[],2);
				if maxValue == 0
					maxIndx = mod (floor(rand*1000), cluster_solution_to_standardize) + 1;
				end
			likely_cluster_candidate(current_cluster, maxIndx) = 1;
			   if sum(likely_cluster_candidate(:, maxIndx)) ~= 1
			   	 likely_cluster_candidate(current_cluster, maxIndx) = 0;
			   	 tempScoreMatrix(current_cluster, maxIndx) = 0;

			 
			   else
			   	break
			   end

		   end
	end




		%Assign top 2 non-unique maxes row wise as long as max is not 0
	tempScoreMatrix = scoreMatrix;
	for index = 1:2
		for current_cluster = 1:cluster_solution_to_standardize
				[maxValue, maxIndx] = max(tempScoreMatrix(current_cluster,:),[],2);
				if index == 1
					maxVals(current_cluster) = maxValue;
				end
				if maxValue ~= 0
					likely_cluster_candidate(current_cluster, maxIndx) = 1;
					tempScoreMatrix(current_cluster, maxIndx) = 0;
				end

		end
	end



	

	%Assign top 2 non-unique maxes column wise that aren't 0s

	tempScoreMatrix = scoreMatrix;

	 for index = 1:2
		for current_cluster = 1:cluster_solution_to_standardize
				[maxValue, maxIndx] = max(tempScoreMatrix(:, current_cluster),[],1);

				if maxValue ~= 0
					likely_cluster_candidate(maxIndx, current_cluster) = 1;
					tempScoreMatrix(maxIndx, current_cluster) = 0;
				end

		end
	 end









	%Assign maxes column wise
	% tempScoreMatrix = scoreMatrix;
	% for current_cluster = 1:cluster_solution_to_standardize
	% 	while(1)
	% 		[maxValue, maxIndx] = max(tempScoreMatrix(current_cluster,:),[],2);
	% 			maxVals(current_cluster) = maxValue;
	% 			if maxValue == 0
	% 				maxIndx = mod (floor(rand*1000), cluster_solution_to_standardize) + 1;
	% 			end
	% 		likely_cluster_candidate(current_cluster, maxIndx) = 1;
	% 		 if sum(likely_cluster_candidate(:, maxIndx)) ~= 1
	% 		 	likely_cluster_candidate(current_cluster, maxIndx) = 0;
	% 		 	tempScoreMatrix(current_cluster, maxIndx) = 0;

			 
	% 		 else
	% 		 	break
	% 		 end
	% 	 end
	% end


	range_to_look_in = 0;
	totalPossibleCombinations = 1;
		totalPossibleCombinations = 1;
		 for row = 1:cluster_solution_to_standardize
		 	totalPossibleCombinations = totalPossibleCombinations*sum(likely_cluster_candidate(row, :));
		 end
	hasBeenFilledOut = (sum(max(likely_cluster_candidate(:,:))) == cluster_solution_to_standardize) & sum(max(likely_cluster_candidate, [], 2))== cluster_solution_to_standardize;

	timeToBreak = 0;

	while 1
		range_to_look_in = range_to_look_in + .01;
		if range_to_look_in > .8
			break
		end

		for row = 1:cluster_solution_to_standardize
			maxValue = maxVals(row);
			effectiveRange = range_to_look_in;
			for column = 1 :cluster_solution_to_standardize
				if likely_cluster_candidate(row, column) ~= 1  & scoreMatrix(row, column) > maxValue-effectiveRange %& scoreMatrix(row, column) > 0 &(scoreMatrix(row, column) ~= maxValue)
					likely_cluster_candidate(row, column) = 1;
					sumOfRow = sum(likely_cluster_candidate(row, :));
						totalPossibleCombinations = totalPossibleCombinations * sumOfRow/ (sumOfRow-1);
%					timeToBreak = totalPossibleCombinations > (cluster_solution_to_standardize^5) & hasBeenFilledOut;
					if timeToBreak
						break
					end 
				end

				if timeToBreak
					break
				end 

			end
			if timeToBreak
				break
			end 
		end
							timeToBreak = totalPossibleCombinations > (cluster_solution_to_standardize^5) & hasBeenFilledOut;

	%Set rest of column for locked in guys to 0
	% for row = 1 :cluster_solution_to_standardize
	% 	for column = 1: cluster_solution_to_standardize
	% 		sumAtThatRow = sum(likely_cluster_candidate( row, :));
	% 		if ((likely_cluster_candidate(row, column) ==1) & sumAtThatRow == 1)
	% 			likely_cluster_candidate(1:row-1, column) = 0;
	% 			if row < cluster_solution_to_standardize
	% 				likely_cluster_candidate(row+1:cluster_solution_to_standardize, column) = 0;
	% 			end

	% 		end
	% 	end
	% end


	hasBeenFilledOut = (sum(max(likely_cluster_candidate(:,:))) == cluster_solution_to_standardize) & sum(max(likely_cluster_candidate, [], 2)) == cluster_solution_to_standardize;
		%totalPossibleCombinations = 1;
		% for row = 1:cluster_solution_to_standardize
		% 	totalPossibleCombinations = totalPossibleCombinations*sum(likely_cluster_candidate(row, :));
		% end

		timeToBreak = totalPossibleCombinations > (cluster_solution_to_standardize^5) & hasBeenFilledOut;
		if timeToBreak
			break
		end 

	end




	%Set rest of column for locked in guys to 0
	% for tempRow = 1:cluster_solution_to_standardize
	% 	row = cluster_solution_to_standardize + 1 - tempRow;
	% 	for column = 1: cluster_solution_to_standardize
	% 		sumAtThatRow = sum(likely_cluster_candidate( row, :));
	% 		if ((likely_cluster_candidate(row, column) ==1) & sumAtThatRow == 1)
	% 			likely_cluster_candidate(1:row-1, column) = 0;
	% 			if row < cluster_solution_to_standardize
	% 				likely_cluster_candidate(row+1:cluster_solution_to_standardize, column) = 0;
	% 			end

	% 		end
	% 	end
	% end
	% %Set rest of row for locked in guys to 0
	% for row = 1:cluster_solution_to_standardize
	% 	for column = 1: cluster_solution_to_standardize
	% 		sumAtThatColumn = sum(likely_cluster_candidate(:, column));
	% 		if ((likely_cluster_candidate(row, column) ==1) & sumAtThatColumn == 1)
	% 			likely_cluster_candidate(row, 1:column-1) = 0;
	% 			if column < cluster_solution_to_standardize
	% 				likely_cluster_candidate(row, column+1:cluster_solution_to_standardize) = 0;
	% 			end

	% 		end
	% 	end
	% end


	%=======================================================================
	%Calculate likely cluster matches based on centroids -- in the matrix a 1 indicates a likely cluster and a 0 indicates clusters whose centroids are so far that they are unlikely to be matched
	%
	%likely_cluster_candidate = zeros(total_number_of_clusters, total_number_of_clusters);
	%
	%inverseOfThreshold = 1;
	%totalPossibilities = 1000000;
	%while totalPossibilities > 50000
	%	for row = 1:total_number_of_clusters
	%		for column = 1:total_number_of_clusters
	%			threshold = (voxels_in_clusters_in_template(1, row) + voxels_in_clusters_in_to_standardize(1, column))/inverseOfThreshold;
	%			if sqrt((template_cluster_centroids(1, row)-to_standardize_cluster_centroids(1, column))^2+(template_cluster_centroids(2, row)-to_standardize_cluster_centroids(2, column))^2+(template_cluster_centroids(3, row)-to_standardize_cluster_centroids(3, column))^2) < threshold
	%				likely_cluster_candidate(row, column) = 1;
	%			end
	%		end
	%	end
	%	inverseOfThreshold = inverseOfThreshold + 1;
	%	%CalculatetotalPossibilities
	%end

	%============================================

	%Calculate total possible combinations -- as stored by "currTotal" -- that are likely (factorial of number of clusters in thet non-ideal case) 


	currTotal = zeros(1, cluster_solution_to_standardize);
	for currCluster = 1:cluster_solution_to_standardize
		[currTotalRows, currTotalColumns] = size(currTotal);
			currTotalTemp = zeros(currTotalRows*sum(likely_cluster_candidate(currCluster, :)), currTotalColumns);
			placeInTemp = 1;
		for currMatch = 1:cluster_solution_to_standardize

			if likely_cluster_candidate(currCluster, currMatch)
				
				for rowInPossibilities = 1:currTotalRows
					tempRow = currTotal(rowInPossibilities, :);
				

					tempRow(currMatch) = currCluster;

						currTotalTemp (placeInTemp, :) =  tempRow;
					placeInTemp = placeInTemp + 1;
					
				end
			end
		end

		[currTotalTempRows, currTotalTempColumns] = size(currTotalTemp);
		index = 1;
		while index <= currTotalTempRows
			if length(find(currTotalTemp(index, :))) ~= currCluster
				 currTotalTemp([index], :) = [];
				 currTotalTempRows = currTotalTempRows -1;
			
			else index = index + 1;
			end

		end

		currTotal = currTotalTemp;
	end


	%============================================
	%Calculate percent overlap for each likely combination

	[rows columns] = size(currTotal);
	overlapScores = zeros(1, rows);

	for index = 1:rows
		runningTotal = 0;
		combinationInQuestion = currTotal(index, :);
		for element = 1:cluster_solution_to_standardize
			runningTotal = runningTotal + voxel_overlap_matrix_percentages(combinationInQuestion(element), element);
		end
		overlapScores(index) = runningTotal/cluster_solution_to_standardize;
	end

	%============================================
	%Find best of possible likely solutions from maximal overlap and create reassignment_vector using this

	indexOfCombinationWithBestScore = find(overlapScores==(max(max(overlapScores))));
	[possibilities, clusters] = size(currTotal);
	bestScore = overlapScores(indexOfCombinationWithBestScore);
	disp(strcat('considering ', int2str(possibilities) , ' possibilities'))
	disp(strcat('best score is ', num2str(bestScore)));
	reassignment_vector = currTotal(indexOfCombinationWithBestScore, :)

	%============================================
	%Loop through to_standardize and actually reassign values
		to_std_vol = to_standardize(:,:,:,cluster_solution_to_standardize-1);
		to_std_ref = to_std_vol;
		for i = 1:length(reassignment_vector)

			to_std_vol(to_std_ref == i) = reassignment_vector(i);


		end
		to_standardize(:,:,:,cluster_solution_to_standardize-1) = to_std_vol;

		% for currRow = 1:rows
		% 	for currCol = 1:columns
		% 		for currBack = 1:backs
		% 			currClusterVal = to_standardize(currRow, currCol, currBack, cluster_solution_to_standardize-1);
		% 			if currClusterVal > 0
		% 				disp('this')
		% 				disp(to_standardize(currRow, currCol, currBack, cluster_solution_to_standardize-1))
		% 				to_standardize(currRow, currCol, currBack, cluster_solution_to_standardize-1) = reassignment_vector(currClusterVal);
		% 				disp('changed to')
		% 				disp(reassignment_vector(currClusterVal))

		% 			end
					
		% 		end

		% 	end

		% end

end
%=======================================================================
%Saving Data as BRIK

OPT.View = '+tlrc';

OPT.Prefix = strcat('ELLISTEST');

disp(strcat('WRITING BRIK: ',OPT.Prefix,'+tlrc'))

WriteBrik(to_standardize(:,:,:,:),to_standardize_info,OPT);	


quit;