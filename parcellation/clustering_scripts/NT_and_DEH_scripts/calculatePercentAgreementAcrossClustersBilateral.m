function [leftScores rightScores] = calculatePercentAgreementAcrossClustersBilateral (toCalculateForFilename, toCalculateWithRespectToFilename, absoluteAgreement)

	%David (Ellis) Hershkowitz, 2013
	%=======================================================================

	%Default variables	 
	if(~exist('toCalculateForFilename','var'))
		error()
	end

	if(~exist('toCalculateWithRespectToFilename', 'var'))
		error()
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
	%Split hemispheres
	systemCall = ['splitHemispheres' ' ' toCalculateForFilename ' ' toCalculateWithRespectToFilename]
	[status, string] = system(systemCall)



	leftScores = calculatePercentAgreementAcrossClusters('LEFT1+tlrc', 'LEFT2+tlrc', absoluteAgreement);
	rightScores = calculatePercentAgreementAcrossClusters('RIGHT1+tlrc', 'RIGHT2+tlrc', absoluteAgreement);

	% %Clean up split hemispheres
	systemCall = strcat('rm LEFT1+tlrc*');
	[status, string] = system(strcat(systemCall));
	systemCall = strcat('rm LEFT2+tlrc*');
	[status, string] = system(strcat(systemCall));
	systemCall = strcat('rm RIGHT1+tlrc*');
	[status, string] = system(strcat(systemCall));
	systemCall = strcat('rm RIGHT2+tlrc*');
	[status, string] = system(strcat(systemCall));

end