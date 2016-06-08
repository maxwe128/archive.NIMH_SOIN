function finalScore = calculatePercentAgreement (toCalculateForFilename, toCalculateWithRespectToFilename, clusterSolutionToCalculateFor, absoluteAgreement, readinToCalculateForFileName, readinToCaclulateWithRespectToFilename)

	%David (Ellis) Hershkowitz, 2013
	%=======================================================================

	%Default variables	 
	if(~exist('toCalculateForFilename','var'))
		error()
	end

	if(~exist('toCalculateWithRespectToFilename', 'var'))
		error()
	end

	if(~exist('clusterSolutionToCalculateFor', 'var'))
		clusterSolutionToCalculateFor = 2;
	end

	if(~exist('absoluteAgreement', 'var'))
		absoluteAgreement = 0;
	end
	%=======================================================================
	% For testing
	% toCalculateForFilename = '/x/nimbus2/FROM_Biowulf/test/SIN_CONSENSUS.LEFT.K15+tlrc.HEAD';
	% toCalculateWithRespectToFilename = '/x/wmn14/turnernl/CLUSTERING/BILATERAL_NOT_SIMULTANEOUS_IPS_MASK/____tmp_LSPLIT_TEST_solutions+tlrc.HEAD';

	% toCalculateForFilename = '/x/nimbus2/FROM_Biowulf/test/SIN_CONSENSUS.LEFT.K15+tlrc.HEAD';
	% toCalculateWithRespectToFilename = '/x/wmn14/turnernl/CLUSTERING/BILATERAL_NOT_SIMULTANEOUS_IPS_MASK/____tmp_LSPLIT_TEST_solutions+tlrc.HEAD';

	% clusterSolutionToCalculateFor = 10;
	% absoluteAgreement = 0;

	%=======================================================================
	% Setting up environment
	scripts_dir = '/x/wmn14/turnernl/CLUSTERING/scripts/';

	% Utility locations
	afni_tools = strcat(scripts_dir,'afni_matlab/matlab');


	% Linking tools
	addpath(genpath(afni_tools))

	%=======================================================================
	% Loading Data
	if (~exist('readinToCalculateForFileName', 'var')  & ~exist('readinToCaclulateWithRespectToFilename', 'var'))
		[toCalculateWithRespectTo, toCalculateWithRespectTo_info] = BrikLoad(toCalculateWithRespectToFilename);
		[toCalculateFor, toCalculateFor_info] = BrikLoad(toCalculateForFilename);
	else 
		toCalculateWithRespectTo = readinToCaclulateWithRespectToFilename;
		toCalculateFor = readinToCalculateForFileName;
	end

	%=======================================================================
	%Reshape data so that the 3d voxels are crunched down into lines
	[rowsA, columnsA, backsA, clustersA] = size(toCalculateWithRespectTo);
	[rowsB, columnsB, backsB, clustersB] = size(toCalculateFor);
	if clustersA == clustersB
		clusters = clustersA;
	else
		clusters = min([clustersA clustersB]);
	end

	total_number_of_clusters = clusters + 1;
	reshapeToCalculateWithRespectTo = reshape(toCalculateWithRespectTo, rowsA*columnsA*backsA, 1, clustersA);
	reshapeToCalculateFor = reshape(toCalculateFor, rowsB*columnsB*backsB, 1, clustersB);
	%=======================================================================


	voxel_overlap_matrix = zeros(1, clusterSolutionToCalculateFor);

	%Initiliaze variables to store the number of voxels in each cluster for the two clustering schemes in question
	voxelsInEachClusterForToCalculateWithRespectTo = zeros(1, clusterSolutionToCalculateFor);
	voxelsInEachClusterForToCalculateFor = zeros(1, clusterSolutionToCalculateFor);

	%Pick out solutions for the cluster solution to calculate for
	toCalculateForClustSolution = reshapeToCalculateWithRespectTo(:, 1, clusterSolutionToCalculateFor-1);
	toCalculateWithRespectToClustSolution = reshapeToCalculateFor(:, 1, clusterSolutionToCalculateFor-1);

	%Cut out 0s from data so that two sets of data fit to the same space
	toCalculateWithRespectToClustSolution(toCalculateWithRespectToClustSolution == 0) = [];
	toCalculateForClustSolution(toCalculateForClustSolution == 0) = [];

	%Store the total voxels in a mask
	[voxelsInMask,  one] = size(toCalculateWithRespectToClustSolution); %assumes they both use the same mask

	%Loop over voxels in both masks
	for index = 1:voxelsInMask

		%If the voxels have the same values, add one to the value for that cluster in the overlap matrix
		if toCalculateWithRespectToClustSolution(index) == toCalculateForClustSolution(index)
			voxel_overlap_matrix(1, toCalculateForClustSolution(index)) =  voxel_overlap_matrix(1, toCalculateForClustSolution(index)) + 1;
		end
		%Increment the total voxels in each cluster in each mask by one at this index
		voxelsInEachClusterForToCalculateWithRespectTo(toCalculateWithRespectToClustSolution(index)) = voxelsInEachClusterForToCalculateWithRespectTo(toCalculateWithRespectToClustSolution(index)) + 1;
		voxelsInEachClusterForToCalculateFor(toCalculateForClustSolution(index)) = voxelsInEachClusterForToCalculateFor(toCalculateForClustSolution(index))  + 1;
	end

	%============================================
	%Calculate overlaps as a percentage of cluster sizes if absolute agreement, then
	voxel_overlap_matrix_percentages = zeros(1, clusterSolutionToCalculateFor);

	%If not absolute agreement, then divide the number of overlapping voxels for each cluster by the number of voxels in each cluster for both masks
	if ~absoluteAgreement
		voxel_overlap_matrix_percentages = (voxel_overlap_matrix )*2 ./ (voxelsInEachClusterForToCalculateFor + voxelsInEachClusterForToCalculateWithRespectTo);
	%If absolute agreement, then divide the number of overlapping voxels for each cluster by the total number of voxels in the mask
	else 
		voxel_overlap_matrix_percentages = voxel_overlap_matrix ./ voxelsInMask;
	end

	%============================================
	%Calculate final scores
	finalScore = 0;

	%If not absolute agreement, then average the values
	if ~absoluteAgreement
		finalScore = mean(voxel_overlap_matrix_percentages);

	%If absolute agreement, then just sum the values
	else
		finalScore = sum(voxel_overlap_matrix_percentages);
	end
end