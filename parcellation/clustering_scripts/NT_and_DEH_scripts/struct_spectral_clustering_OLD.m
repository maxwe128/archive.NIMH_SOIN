function struct_spectral_clustering(eta_filename, ROI_filename, k, filename, normalize)
%STRUCT_SPECTRAL_CLUSTERING 		Spectral Clustering on Structural Covariance Maps
%
%
%	struct_spectral_clustering(data_filename, ROI_filename, k)
%
%	
%
%Nicholas Turner, David (Ellis) Hershkowitz, 2013

if(~exist('eta_filename','var'))
	error('No eta map filename passed! exiting...')
end

if(~exist('ROI_filename', 'var'))
	error('No ROI filename passed! exiting...')
end

if(~exist('k','var'))
	k = 15;
end

% make_matlab_string.py feeds in string arguments by default
if(class(k) == class(char))
	k = str2num(k);
end

if(~exist('normalize','var'))
	normalize = false;
end

if(class(normalize) == class(char))
	normalize = str2num(normalize);
end

if(~exist('filename', 'var'))
	filename = 'CLUSTERING_SOLUTION';
end



%=======================================================================
% Setting up environment
scripts_dir = '/x/wmn14/turnernl/CLUSTERING/scripts/';

% Utility locations
afni_tools = strcat(scripts_dir,'afni_matlab/matlab');
spectral_tools = strcat(scripts_dir,'SpectraLib');
eta2_scripts = strcat(scripts_dir,'eta_scripts_Mar2012');

% Linking tools
addpath(genpath(afni_tools))
addpath(genpath(spectral_tools))
addpath(genpath(eta2_scripts))

%Intiating Spectral Toolbox scripts
init_spectral;
%=======================================================================
% Loading Data

%ASCII file
ETA2 = dlmread(eta_filename);

if(normalize)
	ETA2 = (ETA2 + 1) / 2;
	disp('Normalizing similarities')
end

%3d volume
[ROI, ROI_info] = BrikLoad(ROI_filename);

%=======================================================================
%Masking Eta^2 Maps as correlation maps
%OLD
% dimsETA2 = size(ETA2);

% reshape_eta2 = reshape(ETA2, dimsETA2(1)*dimsETA2(2)*dimsETA2(3),dimsETA2(4));

% masked_eta2 = reshape_eta2(find(ROI),:);

%=======================================================================
%Running spectral Clustering
%(Surprisingly simple!)
clust = do_single_subject_spectral(ETA2,k);

%=======================================================================
% Forming 3d volume of cluster solutions

%Calculating size for reshape
sROI = size(ROI);

reshape_ROI = reshape(ROI,sROI(1)*sROI(2)*sROI(3),1);

clust_brik = zeros([size(ROI) k-1]);
for i = 1:k-1

	% Substituting the cluster solution values at the locations
	% where the ROI = 1
	reshape_ROI(find(ROI)) = clust(:,i);

	% Re-formatting the solution as a brik-writeable size
	clust_brik(:,:,:,i) = reshape(reshape_ROI, size(ROI));
end
%=======================================================================
%Saving Data as BRIK

OPT.View = '+tlrc';

for i = 1:k-1

	OPT.Prefix = strcat(filename,'_',int2str(i+1));

	disp(strcat('WRITING BRIK: ',OPT.Prefix,'+tlrc'))
	WriteBrik(clust_brik(:,:,:,i),ROI_info,OPT);	
end
