function bestScores = standardize_clusters (template_cluster_filename, to_standardize_cluster_filename, outputFileName, absoluteAgreement)
%STANDARDIZE_CLUSTERS 		Correspondence of clustering results
%
% standardize_clusters(template_cluster_filename, to_standardize_cluster_filename)
% 	output_filename, absolute_agreement)
% 
% Finding the best possible index matching between the template and 'toStandardize'
%  solution sets
%
% =======================================================================
%
% REQUIRED ARGUMENTS:
%
% template_cluster_filename - cluster solutions file to act as a template
%
% to_standardize_cluster_filename - solutions file to standardize to the template
%              	NOTE: the maximum k-value of this file must match the template
%
% output_filename - output 'standardized' filename prefix
%
% =======================================================================
%
% OPTIONAL ARGUMENTS:
%
% absolute_agreement - whether or not to standardize the clusters using
%                      absolute agreement (don't really remember what this is,
%                      but it's not that useful)%                      
%
%David (Ellis) Hershkowitz, Nicholas Turner, 2013



% WARNING: messy code, I (Nick) can't document nearly as well as my own
%  luckily, Ellis documented some of this himself
%=======================================================================
% Argument Handling

if(~exist('template_cluster_filename','var'))
	print_documentation()
	disp('no template_cluster_filename argument passed! exiting...')
	exit;
end

if(~exist('to_standardize_cluster_filename', 'var'))
	print_documentation()
	disp('no to_standardize_cluster_filename argument passed! exiting...')
	exit;
end

if(~exist('outputFileName', 'var'))
	print_documentation()
	disp('no outputFilename argument passed! exiting...')
	exit;
end

if(~exist('absoluteAgreement', 'var'))
	absoluteAgreement = 0;
end

%=======================================================================
% Setting up environment
% COMMENT OUT THIS CODE IF YOU WISH TO COMPILE THE SCRIPT
% The scripts used within MUST be within the path when you do
%  see compile_matlab_command.py
scripts_dir = '/x/wmn14/turnernl/CLUSTERING/scripts/';

% Utility locations
afni_tools = strcat(scripts_dir,'afni_matlab/matlab');


% Linking tools
addpath(afni_tools);

%=======================================================================
% Loading Data

[template, template_info] = BrikLoad(template_cluster_filename);
[to_standardize, to_standardize_info] = BrikLoad(to_standardize_cluster_filename);

%=======================================================================
%Reshape data so that masks fit in the same space
[rows, columns, backs, clusters] = size(to_standardize);
[rowsTS, columnsTS, backsTS, clustersTS] = size(to_standardize);
[rowsT, columnsT, backsT, clustersT] = size(template);

%maximum number of clusters?
total_number_of_clusters = clusters + 1;
bestScores = zeros(total_number_of_clusters - 1,1);
reshapeTemplate = reshape(template, rowsT*columnsT*backsT, 1, clustersT);
reshapeToStandardize = reshape(to_standardize, rowsTS*columnsTS*backsTS, 1, clustersTS);
disp('Data reshaped, looping through clusters...')
%=======================================================================

upperBoundOnPossibilities = 10000000000;
for cluster_solution_to_standardize = total_number_of_clusters:-1:2
	 upperBoundOnPossibilities = upperBoundOnPossibilities/2;

	disp(strcat('Standardizing clusters for', {' '}, int2str(cluster_solution_to_standardize), ' solution...'))

	%Count voxels in each cluster and total x,y,zs of each cluster in template and absolute voxel overlap

	voxels_in_clusters_in_template = zeros(3, cluster_solution_to_standardize);

	voxels_in_clusters_in_to_standardize= zeros(3, cluster_solution_to_standardize);

	voxel_overlap_matrix = zeros(cluster_solution_to_standardize, cluster_solution_to_standardize);



		clustSolutionTemplate = reshapeTemplate(:, 1, cluster_solution_to_standardize-1);
		clustSolutionToStandardize = reshapeToStandardize(:, 1, cluster_solution_to_standardize-1);

		clustSolutionTemplate(clustSolutionTemplate == 0) = [];
		clustSolutionToStandardize(clustSolutionToStandardize == 0) = [];

		[voxelsInTemplate,  one] = size(clustSolutionTemplate); 
		[voxelsInToStandardize, one] = size(clustSolutionToStandardize); 

		if voxelsInTemplate ~= voxelsInToStandardize
			voxelsInTemplate
			voxelsInToStandardize
			disp(strcat('There are not equal voxels in the two masks for the cluster solution of k= ', int2str(cluster_solution_to_standardize)))
			error('Unequal masks')
		end

		for index = 1:voxelsInTemplate
			voxels_in_clusters_in_template(:, clustSolutionTemplate(index)) = voxels_in_clusters_in_template(1, clustSolutionTemplate(index)) + 1;
			voxels_in_clusters_in_to_standardize(:, clustSolutionToStandardize(index)) = voxels_in_clusters_in_to_standardize(1, clustSolutionToStandardize(index)) + 1;

			voxel_overlap_matrix(clustSolutionTemplate(index), clustSolutionToStandardize(index)) = voxel_overlap_matrix(clustSolutionTemplate(index), clustSolutionToStandardize(index))+1;
		end

	%============================================
	%Calculate overlaps as a percentage of cluster sizes
	if ~absoluteAgreement
		voxel_overlap_matrix_percentages = zeros(cluster_solution_to_standardize, cluster_solution_to_standardize);
		for row = 1:cluster_solution_to_standardize
			for column = 1:cluster_solution_to_standardize
				voxel_overlap_matrix_percentages(row, column) = voxel_overlap_matrix(row, column)*2/(voxels_in_clusters_in_template(1, row) + voxels_in_clusters_in_to_standardize(1, column));
			end
		end
	else 
		voxel_overlap_matrix_percentages = zeros(cluster_solution_to_standardize, cluster_solution_to_standardize);
		for row = 1:cluster_solution_to_standardize
			for column = 1:cluster_solution_to_standardize
				voxel_overlap_matrix_percentages(row, column) = voxel_overlap_matrix(row, column)/voxelsInTemplate;
			end
		end
	end


	%============================================
	%Preliminary naive work marks top 2 maxes of columns and rows as likely pairings. Additionally, it is ensured that each column recieves a unique assignment at the very least(i.e. the "greedy" solution)

	scoreMatrix =  voxel_overlap_matrix_percentages;%Could theoretically use scoring other than just voxel_overlap_percentages

	likely_cluster_candidate = zeros(cluster_solution_to_standardize, cluster_solution_to_standardize);%A matrix of booleans that marks likely pairings of clusters as true (i.e. 1)
		
	maxVals = zeros(1, cluster_solution_to_standardize);%Stores max values of each row

	tempScoreMatrix = scoreMatrix;
	%Assign best, unique maxes row wise -- if best pairing is a 0, a random pairing is chosen
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

	%Assign top 2 non-unique maxes column wise that are not 0s
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

	%============================================
	%Look within a range below the max of each row, increasing the range until a rough number of possible pairings is reached (rough because it ignores overlaps) threshold 
	% is just barely met -- the threshold is stored by "upperBoundOnPossibilities" or increase range until it reaches 80%


	%Get an initial value for the rough number of possible combinations (the actual number is much lower as a result of the dissallowance for more than one cluster being matched to another)
	totalPossibleCombinations = 1;
	for row = 1:cluster_solution_to_standardize
			totalPossibleCombinations = totalPossibleCombinations*sum(likely_cluster_candidate(row, :));
	end

	%Initialize variables
	range_to_look_in = 0;
	timeToBreak = 0;

	%Loop until range gets to 80% or upper bound on rough number of possibilities is met
	while 1
		range_to_look_in = range_to_look_in + .01;

		for row = 1:cluster_solution_to_standardize
			maxValue = maxVals(row);
			effectiveRange = range_to_look_in;
			for column = 1 :cluster_solution_to_standardize
				if likely_cluster_candidate(row, column) ~= 1  & scoreMatrix(row, column) > maxValue-effectiveRange 
					likely_cluster_candidate(row, column) = 1;
					sumOfRow = sum(likely_cluster_candidate(row, :));
						totalPossibleCombinations = totalPossibleCombinations * sumOfRow/ (sumOfRow-1);
						exceededPossibilities = totalPossibleCombinations > (upperBoundOnPossibilities);
						timeToBreak = timeToBreak | exceededPossibilities;
						if exceededPossibilities
							likely_cluster_candidate(row, column) = 0;
							totalPossibleCombinations = totalPossibleCombinations*(sumOfRow-1)/sumOfRow;
						end
				end
				end
			end


			%Break as necessary
			if range_to_look_in > .8
				break
			end

			if timeToBreak
				break
			end 
	end

		%============================================

		%Calculate all possible combinations given the likely pairings -- as stored by "currTotal" -- for the preliminary work

		currTotal = zeros(1, cluster_solution_to_standardize);

		for currCluster = 1:cluster_solution_to_standardize
			[currTotalRows, currTotalColumns] = size(currTotal);

			idx = currTotal == 0;
			zerosInColumns = sum(idx, 1);
			relevantColumns = likely_cluster_candidate(currCluster, :);
			zerosInMatchedColumns = zerosInColumns .* relevantColumns;
			nextNumberOfPossibilities = sum(zerosInMatchedColumns);

			currTotalTemp = zeros(nextNumberOfPossibilities, currTotalColumns);
			placeInTemp = 1;

			for rowOfCurrTotal = 1:currTotalRows
				%Grab row of currTotal
				currentRowOfCurrTotal = currTotal(rowOfCurrTotal, :);
					%Loop across likely candidates for cluster and where there is a likely candidate and a 0 in the current row of currTotal, add the concatanated vector to currTotalTemp
					for currColumnOfLikelyCandidates = 1:cluster_solution_to_standardize
						if likely_cluster_candidate(currCluster, currColumnOfLikelyCandidates)
							if currentRowOfCurrTotal(currColumnOfLikelyCandidates) == 0
								rowToAdd = currentRowOfCurrTotal;
								rowToAdd(currColumnOfLikelyCandidates) = currCluster;
								currTotalTemp(placeInTemp, :) = rowToAdd;
								placeInTemp = placeInTemp + 1; 
							end
						end

					end

			end
			currTotal=currTotalTemp;
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
		if ~absoluteAgreement
			overlapScores(index) = runningTotal/cluster_solution_to_standardize;
		else
			overlapScores(index) = runningTotal;
		end
	end

	%============================================
	%Find best of possible likely solutions from maximal overlap and create reassignment_vector using this

	indexOfCombinationWithBestScore = find(overlapScores==(max(max(overlapScores))));
	[rows, columns] = size(indexOfCombinationWithBestScore);

	if columns > 1
		indexOfCombinationWithBestScore = indexOfCombinationWithBestScore(1, 1);
	end

	reassignment_vector = currTotal(indexOfCombinationWithBestScore, :);

	[rows, columns] = size(reassignment_vector);
	if rows > 1
		reassignment_vector = reassignment_vector(1, :);
	end

	%============================================
	%Display stuff so it looks cool
	[possibilities, clusters] = size(currTotal);
	disp(strcat({'--considering'}, {' '}, int2str(possibilities) ,{' '} , {'possibilities'}))

	bestScore = overlapScores(indexOfCombinationWithBestScore);
	bestScores(cluster_solution_to_standardize) = bestScore;
	disp(strcat('--best score is',{' '}, num2str(bestScore)));

	% reassignment_vector

	%============================================
	%Loop through to_standardize and actually reassign values
	to_std_vol = to_standardize(:,:,:,cluster_solution_to_standardize-1);
	to_std_ref = to_std_vol;

	for i = 1:length(reassignment_vector)
		to_std_vol(to_std_ref == i) = reassignment_vector(i);
	end

	to_standardize(:,:,:,cluster_solution_to_standardize-1) = to_std_vol;



end
%=======================================================================
%Save standardized clusters as BRIK

OPT.View = '+tlrc';

OPT.Prefix = outputFileName;

disp(strcat('WRITING BRIK: ',OPT.Prefix,'+tlrc'))

WriteBrik(to_standardize(:,:,:,:),to_standardize_info,OPT);	

quit;
end

function print_documentation()

	%the ONLY reason I'm doing this is that it's decently easy with sublime text...
	disp('STANDARDIZE_CLUSTERS 		Correspondence of clustering results')
	disp(' ')
	disp('standardize_clusters(template_cluster_filename, to_standardize_cluster_filename)')
	disp('	output_filename, absolute_agreement)')
	disp(' ')
	disp('Finding the best possible index matching between the template and "toStandardize"')
	disp(' solution sets')
	disp(' ')
	disp('=======================================================================')
	disp(' ')
	disp('REQUIRED ARGUMENTS:')
	disp(' ')
	disp('template_cluster_filename - cluster solutions file to act as a template')
	disp(' ')
	disp('to_standardize_cluster_filename - solutions file to standardize to the template')
	disp('             	NOTE: the maximum k-value of this file must match the template')
	disp(' ')
	disp('output_filename - output "standardized" filename prefix')
	disp(' ')
	disp('=======================================================================')
	disp(' ')
	disp('OPTIONAL ARGUMENTS:')
	disp(' ')
	disp('absolute_agreement - whether or not to standardize the clusters using')
	disp('                     absolute agreement (don"t really remember what this is,')
	disp('                     but it"s not that useful)%                      ')
	disp(' ')
	disp('David (Ellis) Hershkowitz, Nicholas Turner, 2013')

end