function struct_spectral_clustering(eta_filename, ROI_filename, k, filename, num_attempts, normalize)
%STRUCT_SPECTRAL_CLUSTERING 		Spectral Clustering on Covariance Maps
%
% struct_spectral_clustering(data_filename, ROI_filename, k, filename, num_attempts, normalize)
% 
% Computation of a spectral clustering solution for given eta matrix - eta_filename
%
% =======================================================================
%
% REQUIRED ARGUMENTS:
%
% eta_filename - text file of an eta^2 matrix to be used for calculation
%
% ROI_filename - ROI for which this eta matrix was calculated
%              NOTE: the number of voxels within the ROI must match
%              the dimension of the eta^2 matrix
%
% =======================================================================
%
% OPTIONAL ARGUMENTS:
%
% k - the function finds solutions for all values of k up to this max values
%   - defaults to 15
%
% filename - output filename prefix
%          - defaults to 'CLUSTERING_SOLUTION'
%
% num_attempts - the number of clustering attempts to consolidate into each
%                output volume (NOT FULLY IMPLEMENTED YET)
%
% normalize    - If the input matrix consists of pearson correlations,
%                enable this option to normalize the pearson values to the same
%                range as eta^2 [-1,1]	
%
%Nicholas Turner, David (Ellis) Hershkowitz, 2013

%=======================================================================
%Argument Handling

if(~exist('eta_filename','var'))
	print_documentation()
	disp('No eta map filename passed! exiting...')
	exit;
end

if(~exist('ROI_filename', 'var'))
	print_documentation()
	disp('No ROI filename passed! exiting...')
	exit;
end

if(~exist('k','var'))
	k = 15;
end

% make_matlab_string.py (a utility script I use)
%  feeds in string arguments by default
if(strcmp(class(k),class(char))) 
	k = str2num(k);
end

if(~exist('normalize','var'))
	normalize = false;
end

if(~exist('num_attempts','var'))
	num_attempts = 100;
end

if(strcmp(class(num_attempts),class(char)))
	num_attempts = str2num(num_attempts);
end

if(strcmp(class(normalize),class(char)))
	normalize = str2num(normalize);
end

if(~exist('filename', 'var'))
	filename = 'CLUSTERING_SOLUTION';
end

%=======================================================================
% Setting up environment
% COMMENT OUT THIS CODE IF YOU WISH TO COMPILE THE SCRIPT
% The scripts used within MUST be within the path when you do
%  see compile_matlab_command.py
scripts_dir = '/data/NIMH_SOIN/elliottml/COBRE_SZ/scripts/clustering_scripts/'

% Utility locations
afni_tools = strcat(scripts_dir,'afni_matlab/matlab');
spectral_tools = strcat(scripts_dir,'SpectraLib');
eta2_scripts = strcat(scripts_dir,'eta_scripts_Mar2012');

% Linking tools
addpath(genpath(afni_tools))
addpath(genpath(spectral_tools))
addpath(genpath(eta2_scripts))

% %Intiating Spectral Toolbox scripts
global_options;
%=======================================================================
% Loading Data

%ASCII file
ETA2 = dlmread(eta_filename);

% Sometimes dlmread gives an extra column
s = size(ETA2);
if(s(2) == 1+s(1))
	ETA2 = ETA2(:,1:s(1));
end

if(normalize)
	ETA2 = (ETA2 + 1) / 2;
	disp('Normalizing similarities')
end

roiSurf_all=dlmread(ROI_filename);
numNodes=size(find(roiSurf_all>0),1); % Number of voxels in the ROI
assignment=zeros(numNodes, k-1);

%=======================================================================
%Running spectral Clustering
%(Surprisingly simple!)
% output dimensions = ( number of voxels, number of solutions )

clust = do_single_subject_spectral(ETA2,k);

%=======================================================================
% Saving clustering results (if desired)
%save_datamat(clust, strcat(filename,'_spectral_solutions'));
save(strcat(filename,'_spectral_solutions'),'clust','-ASCII')
%=======================================================================
% Forming 3d volume of cluster solutions

%Calculating size for reshape
reshape_ROI = zeros([size(roiSurf_all,1) k-1]);
for i = 1:k-1

	% Substituting the cluster solution values at the locations
	% where the ROI = 1
	reshape_ROI(find(roiSurf_all>0),i) = clust(:,i);
end
%=======================================================================
%Saving Data as dset
outname = strcat(filename,'_K',int2str(k),'.1D.dset');
%outdata = [roiSurf_all(:,1) reshape_ROI];
outdata = [reshape_ROI];
disp(strcat('WRITING Output: ',outname));
dlmwrite(outname,outdata,'delimiter',' ');

%=======================================================================
clear;
end %END MAIN FUNCTION

% Helper function to save a datamat - used here for the solutions of the clustering
function save_datamat(values, output_name)

	disp(strcat('Saving file: ',output_name, '...'))
	save(output_name, 'values','-ascii','-tabs');

end % save_datamat

function print_documentation()

	%the ONLY reason I'm doing this is that it's decently easy with sublime text...
	disp('STRUCT_SPECTRAL_CLUSTERING 		Spectral Clustering on Covariance Maps')
	disp(' ')
	disp(' struct_spectral_clustering(data_filename, ROI_filename, k, filename, num_attempts, normalize)')
	disp(' ')
	disp(' Computation of a spectral clustering solution for given eta matrix - eta_filename')
	disp(' ')
	disp(' =======================================================================')
	disp(' ')
	disp(' REQUIRED ARGUMENTS:')
	disp(' ')
	disp(' eta_filename - text file of an eta^2 matrix to be used for calculation')
	disp(' ')
	disp(' ROI_filename - ROI for which this eta matrix was calculated')
	disp('              NOTE: the number of voxels within the ROI must match')
	disp('              the dimension of the eta^2 matrix')
	disp(' ')
	disp(' =======================================================================')
	disp(' ')
	disp(' OPTIONAL ARGUMENTS:')
	disp(' ')
	disp(' k - the function finds solutions for all values of k up to this max values')
	disp('   - defaults to 15')
	disp(' ')
	disp(' filename - output filename prefix')
	disp('          - defaults to "CLUSTERING_SOLUTION"')
	disp(' ')
	disp(' num_attempts - the number of clustering attempts to consolidate into each')
	disp('                output volume (NOT FULLY IMPLEMENTED YET)')
	disp(' ')
	disp(' normalize    - If the input matrix consists of pearson correlations,')
	disp('                enable this option to normalize the pearson values to the same')
	disp('                range as eta^2 [-1,1]	')
	disp(' ')
	disp('Nicholas Turner, David (Ellis) Hershkowitz, 2013')

end
