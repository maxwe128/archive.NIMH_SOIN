function consensus_clustering(eta_list_filename, ROI_filename, k, filename)
%STRUCT_SPECTRAL_CLUSTERING 		Spectral Clustering on Structural Covariance Maps
%
%
%	struct_spectral_clustering(data_filename, ROI_filename, k)
%
%	
%
%Nicholas Turner, David (Ellis) Hershkowitz, 2013

if(~exist('eta_filename','var'))
	error()
end

if(~exist('ROI_filename', 'var'))
	error()
end

if(~exist('k','var'))
	k = 4;
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

% Counting the number of lines in the list file
[status, result] = system('wc -l ',eta_list_filename);
num_lines = 

[ETA2, ETA_2_info] = BrikLoad(eta_filename);
[ROI, ROI_info] = BrikLoad(ROI_filename);

%=======================================================================
%Masking Eta^2 Maps

dimsETA2 = size(ETA2);

reshape_eta2 = reshape(ETA2, dimsETA2(1)*dimsETA2(2)*dimsETA2(3),dimsETA2(4));

masked_eta2 = reshape_eta2(find(ROI),:);

%=======================================================================
%Running spectral Clustering
%(Surprisingly simple!)

clust = do_single_subject_spectral(masked_eta2,k);

%=======================================================================
% Forming 3d volume of cluster solutions

reshape_ROI = reshape(ROI,dimsETA2(1)*dimsETA2(2)*dimsETA2(3),1);

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

quit;

%OTHER COMMANDS
make_consensus_mat(clustering_assignment);
do_consensus_spectral(consensus_mat);