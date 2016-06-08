function finalScores = calculatePercentAgreementAcrossClusters (toCalculateForFilename, toCalculateWithRespectToFilename, absoluteAgreement)

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

	[toCalculateWithRespectTo, toCalculateWithRespectTo_info] = BrikLoad(toCalculateWithRespectToFilename);
	[toCalculateFor, toCalculateFor_info] = BrikLoad(toCalculateForFilename);

	%=======================================================================
	[rowsA, columnsA, backsA, clustersA] = size(toCalculateWithRespectTo);
	[rowsB, columnsB, backsB, clustersB] = size(toCalculateFor);

	if clustersB ~= clustersA
		disp('Unequal number of cluster solutions')
		clustersA = min([clustersA clustersB]);
		clustersB = min([clustersA clustersB]);
	end

	finalScores = zeros(1, clustersA);

	for currentClusterSolution = 2:clustersA+1	
		scoreForThisCluster = calculatePercentAgreement(toCalculateForFilename, toCalculateWithRespectToFilename, currentClusterSolution, absoluteAgreement, toCalculateFor, toCalculateWithRespectTo);
		finalScores(currentClusterSolution-1) = scoreForThisCluster;
	end
	%=======================================================================


end