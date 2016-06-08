function [allSolutionsAcrossSampleSizesAbs0 standardDeviationAcrossSampleSizesAbs0 allSolutionsAcrossSampleSizesAbs1 standardDeviationAcrossSampleSizesAbs1] = calculateAveragePercentAgreementAcrossSamples(minNumberToStartWith, intervalsBetweenSamples, maxNumberOfFiles, numberOfRandomTrialsToAverage, absoluteAgreement,  headerOfFiles, fileDirectories, roiMask, grayMask, numberOfClusters, solutionToCompareTo)

	%David (Ellis) Hershkowitz, 2013

	%===========================================================================
	%Default variables
	if(~exist('numberOfRandomTrialsToAverage', 'var'))
		numberOfRandomTrialsToAverage = 1;
	end

	if(~exist('intervalsBetweenSamples', 'var'))
		error('You need to put in a desired intervalsBetweenSamples(second argument)')
	end

	if(~exist('minNumberToStartWith', 'var'))
		error('You need to put in a desired minNumberToStartWith(first argument)')
	end

	if(~exist('maxNumberOfFiles', 'var'))
		maxNumberOfFiles = minNumberToStartWith;
	end

	if(~exist('headerOfFiles', 'var'))
		headerOfFiles = 'swmwrc1';
	end

	if(~exist('fileDirectories', 'var'))
		fileDirectories = '/x/wmc3/skippenhan/limk1_sibstudy/dartel_n286_righties_under55/SMOOTH6';
	end

	if(~exist('absoluteAgreement', 'var'))
		absoluteAgreement = 2;
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
	if minNumberToStartWith > maxNumberOfFiles
		error('Cannot start higher than max number of files')
	end

	if minNumberToStartWith < 0
		error('minNumberToStartWith must be greater than 0')
	end

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
	%Initialize the current sample size that calculations are being done for to the starting sample size
	currentSampleSize = minNumberToStartWith;

	% Initialize each return variable to a blank matrix where each column is a cluster solution (the first column is just filled in to indicate what sample size you are at) and each row is a sample size
	rows = (floor((maxNumberOfFiles-minNumberToStartWith)/intervalsBetweenSamples) + 1);

	allSolutionsAcrossSampleSizesAbs0= zeros(rows, numberOfClusters);
	standardDeviationAcrossSampleSizesAbs0= zeros(rows, numberOfClusters);
	allSolutionsAcrossSampleSizesAbs1= zeros(rows, numberOfClusters);
	standardDeviationAcrossSampleSizesAbs1= zeros(rows, numberOfClusters);

	%Loop across all the desired sample sizes
	for placeInAllSolutions = 1: rows
		% Fill in the sample size in each of the return variables in the first column
		allSolutionsAcrossSampleSizesAbs0(placeInAllSolutions, 1) = currentSampleSize;
		allSolutionsAcrossSampleSizesAbs1(placeInAllSolutions, 1) = currentSampleSize;
		standardDeviationAcrossSampleSizesAbs0(placeInAllSolutions, 1)= currentSampleSize;
		standardDeviationAcrossSampleSizesAbs1(placeInAllSolutions, 1)= currentSampleSize;

		%Perform the calculation of overlap and standard deviation at the current sampleSize
		try
			[overlapSolutionAbs0 stdDevSolutionAbs0 overlapSolutionAbs1 stdDevSolutionAbs1] = calculateAveragePercentAgreement(currentSampleSize, numberOfRandomTrialsToAverage, absoluteAgreement);
					%Update rows of the return variables to what calculateAveragePercentAgreement returns
			allSolutionsAcrossSampleSizesAbs0(placeInAllSolutions, 2:end) = overlapSolutionAbs0
			standardDeviationAcrossSampleSizesAbs0(placeInAllSolutions, 2:end) = stdDevSolutionAbs0
			allSolutionsAcrossSampleSizesAbs1(placeInAllSolutions, 2:end) = overlapSolutionAbs1
			standardDeviationAcrossSampleSizesAbs1(placeInAllSolutions, 2:end) = stdDevSolutionAbs1
		catch
			disp('Something went wrong with caclculating the average percent agreement at this sample size')
		end



		%Increment currentSampleSize by the desired interval
		currentSampleSize = currentSampleSize + intervalsBetweenSamples;
	end
end