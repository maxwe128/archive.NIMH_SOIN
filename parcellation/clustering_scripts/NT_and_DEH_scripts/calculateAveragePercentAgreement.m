function [averagePercentAgreementForEachClusterSolutionAbs0 standardDeviationForEachClusterSolutionAbs0 averagePercentAgreementForEachClusterSolutionAbs1 standardDeviationForEachClusterSolutionAbs1] = calculatePercentAgreement (numberOfIndividuals, numberOfRandomTrialsToAverage, absoluteAgreement, headerOfFiles, fileDirectories, roiMask, grayMask, numberOfClusters, solutionToCompareTo)

%David (Ellis) Hershkowitz, 2013

%===========================================================================
%Default variables
if(~exist('numberOfIndividuals','var'))
	error()
end

if(~exist('numberOfRandomTrialsToAverage', 'var'))
	numberOfRandomTrialsToAverage = 1;
end

if(~exist('headerOfFiles', 'var'))
	headerOfFiles = 'swmwrc1';
end

if(~exist('fileDirectories', 'var'))
	fileDirectories = '/x/wmc3/skippenhan/limk1_sibstudy/dartel_n286_righties_under55/SMOOTH6';
end

if(~exist('absoluteAgreement', 'var'))
	absoluteAgreement = 0;
end

if(~exist('grayMask', 'var'))
	grayMask = '/x/wmn14/turnernl/CLUSTERING/masks/bilateral_IPS_mask_4mm_gray90_MNI.nii';
end

if(~exist('roiMask', 'var'))
	roiMask = '/x/wmn14/turnernl/CLUSTERING/masks/bilateral_IPS_mask_4mm_gray90_MNI.nii';
end

if(~exist('numberOfClusters', 'var'))
	numberOfClusters = 15;
end

if(~exist('solutionToCompareTo', 'var'))
		solutionToCompareTo = '/x/wmn14/turnernl/CLUSTERING/IPS/WithEta2/IncludingROICorrelation/4mm/Results/results_solutions.nii.gz';
end
%===========================================================================
	%Errors for improper variable inputs
	if absoluteAgreement > 2 | absoluteAgreement < 0
		error('absoluteAgreement must be 0 or 1')
	end

	[status, string] = system('ls');
	[row col] = size(string);
	if row ~= 0
		error('Start in an empty directory. I do not want my script messing something up when it runs...')
	end

	%===========================================================================
%Set up environment
addpath('/x/wmn14/turnernl/CLUSTERING/scripts/NT_and_DEH_scripts/');
%===========================================================================
% For testing
	% numberOfIndividuals = 5;
	% numberOfRandomTrialsToAverage = 2;
	% headerOfFiles = 'swmwrc1';
	% fileDirectories = '/x/wmc3/skippenhan/limk1_sibstudy/dartel_n286_righties_under55/SMOOTH6';
	% absoluteAgreement = 0;
	% roiMask = '/x/wmn14/turnernl/CLUSTERING/masks/bilateral_IPS_mask_4mm_gray90_MNI.nii';
	% grayMask = '/x/wmn14/turnernl/CLUSTERING/masks/bilateral_IPS_mask_4mm_gray90_MNI.nii';
	% numberOfClusters = 15;
	% solutionToCompareTo = '/x/wmn14/turnernl/CLUSTERING/BILATERAL_NOT_SIMULTANEOUS_IPS_MASK/4mm_IPS_SPLIT_HEMISPHERES_solutions.nii.gz';
%===========================================================================
%Generate numberOfRandomTrialsToAverage number of structurals using numberOfIndividuals individuals
for whichTrial = 1 : numberOfRandomTrialsToAverage
	systemCall = ['create_random_n_structurals', ' ', int2str(numberOfIndividuals), ' ', 'trialNumber', int2str(whichTrial)]
	[status, string] = system(strcat(systemCall));
end

%===========================================================================
%Resample random structurals to the mask
for whichTrial = 1 : numberOfRandomTrialsToAverage
	systemCall = ['3dresample -master', ' ', roiMask, ' ', '-inset', ' ', 'trialNumber', int2str(whichTrial), '.nii.gz', ' ', '-prefix', ' ', 'resampledTrialNumber', int2str(whichTrial)]
	[status, string] = system(strcat(systemCall));
end

%===========================================================================
%Clean up intermediate files --random structurals
system('rm trialNumber*');

%===========================================================================
%Perform clustering on the random structurals
for whichTrial = 1 : numberOfRandomTrialsToAverage
	systemCall = ['run_bilateral_struct_spectral_clustering', ' ', roiMask, ' ','resampledTrialNumber', int2str(whichTrial), '+tlrc' , ' ', 'clusteredTrialNumber', int2str(whichTrial), ' ', int2str(numberOfClusters), ' ', '0']
	[status, string] = system(strcat(systemCall));
end

%===========================================================================
%Clean up intermediate files --random structurals resampled
system('rm resampledTrialNumber*');

%===========================================================================
%Change absolute agreement as necessary -- if it is 2 the method will loop over both absolute agreements of 0 and 1, standardizing and calculating percent agreement for the clustering solution separately for each
if absoluteAgreement == 2
	startAbsoluteAgreement = 0;
	absoluteAgreement = 1;
else
	startAbsoluteAgreement = absoluteAgreement;
end

%===========================================================================
%Initialize return variables so that if you are only doing calculations for one absolute agreement you can just return an empty matrix for the other solution
averagePercentAgreementForEachClusterSolutionAbs0 = zeros(1, numberOfClusters);
standardDeviationForEachClusterSolutionAbs0 = zeros(1, numberOfClusters);
averagePercentAgreementForEachClusterSolutionAbs1 = zeros(1, numberOfClusters);
standardDeviationForEachClusterSolutionAbs1 = zeros(1, numberOfClusters);

%===========================================================================
%Loop over absolute agreement solutions -- if absolute agreement is 0 or 1, will only loop once. If absolute agreement is 2, will loop over both solutions.
for currentAbsoluteAgreement = startAbsoluteAgreement: absoluteAgreement

	%Standardize the clustering solutions to solution of maximal size
	for whichTrial = 1 :numberOfRandomTrialsToAverage
		systemCall = ['bilateral_cluster_standardize', ' ', 'clusteredTrialNumber', int2str(whichTrial), '_solutions.nii.gz', ' ', solutionToCompareTo, ' ', 'standardizedClusteredTrialNumber', int2str(whichTrial), ' ', int2str(currentAbsoluteAgreement)]
		[status, string] = system(strcat(systemCall));
	end
	
	%Calculate percent agreement of each standardized clustering solution
	percentAgreementMatrix = zeros(numberOfRandomTrialsToAverage, numberOfClusters-1);

	%Split the grand average into left and right hemispheres
	systemCall = ['3dcalc -a', ' ', solutionToCompareTo, ' ', '-prefix grandAverage_left -expr  "a*ispositive(x)"'];
	system(systemCall);
	systemCall = ['3dcalc -a', ' ', solutionToCompareTo, ' ', '-prefix grandAverage_right -expr  "a*ispositive(x)"'];
	system(systemCall);

	%Loop over trials at the input sample size
	for whichTrial = 1:numberOfRandomTrialsToAverage
		%Split the trial so that calculation is done bilaterally
		nameOfCurrentTrial = ['standardizedClusteredTrialNumber', int2str(whichTrial), '+tlrc.HEAD'];
		systemCall = ['3dcalc -a', ' ', nameOfCurrentTrial, ' ', '-prefix currentTrial_left -expr  "a*ispositive(x)"'];
		system(systemCall);
		systemCall = ['3dcalc -a', ' ', nameOfCurrentTrial, ' ', '-prefix currentTrial_right -expr  "a*ispositive(x)"'];
		system(systemCall);

		%Loop over clustering solutions to calculate average percent agreement for both left and right solutions
		for whichCluster = 2:numberOfClusters 

			%Average the two agreements of left and right to get the agreement
			percentAgreementForLeft =calculatePercentAgreement(['currentTrial_left+tlrc'], 'grandAverage_left+tlrc', whichCluster, currentAbsoluteAgreement);
			percentAgreementForRight = calculatePercentAgreement(['currentTrial_right+tlrc'], 'grandAverage_right+tlrc', whichCluster, currentAbsoluteAgreement);
			agreementForTrialAndCluster = (percentAgreementForRight + percentAgreementForLeft)/2;

			%Update percentAgreement matrix
			percentAgreementMatrix(whichTrial, whichCluster-1) = agreementForTrialAndCluster;
		end

		%Remove left and right files for currentTrial
		system('rm currentTrial*');
	end

	%===========================================================================
	%Clean up intermediate files --standardized clustering solutions and split grand average
	system('rm standardizedClusteredTrialNumber*');
	system('rm grandAverage*');
	%===========================================================================
	%Average each of the percent agreements:
	[rows columns] = size(percentAgreementMatrix);

	%Update the necessary output variables based on the currentAbsoluteAgreement that calculations are being done for-- i.e. update Abs0 solutions if currentAbsoluteAgreement is 0 etc.

	%Necessary updates for currentAbsoluteAgreement of 0
	if currentAbsoluteAgreement == 0
		if rows > 1
			averagePercentAgreementForEachClusterSolutionAbs0 = mean(percentAgreementMatrix);
			standardDeviationForEachClusterSolutionAbs0 = std(percentAgreementMatrix);
		%If solutions are only being calculated for 1 trial, standard deviation is all 0s and the mean is just the percentAgreementMatrix itself
		else
			averagePercentAgreementForEachClusterSolutionAbs0 = percentAgreementMatrix;
		end

	%Necessary updates for currentAbsoluteAgreement of 1
	else
		if rows > 1
			averagePercentAgreementForEachClusterSolutionAbs1 = mean(percentAgreementMatrix);
			standardDeviationForEachClusterSolutionAbs1 = std(percentAgreementMatrix);
		 %If solutions are only being calculated for 1 trial, standard deviation is all 0s and the mean is just the percentAgreementMatrix itself
		else
			averagePercentAgreementForEachClusterSolutionAbs1 = percentAgreementMatrix;
		end
	end
end

%===========================================================================
%Clean up intermediate files --non-standardized clustering solutions
system ('rm clusteredTrialNumber*');