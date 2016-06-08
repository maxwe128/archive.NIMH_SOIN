%% Script to:
% -compute correlations (functional connectivity)
% -compute eta-squared (between all pairs of correlation maps)
% -perform spectral clustering
% -generate consensus matrix
% -perform consensus clustering
%
% Please open the script and enter the required variables
%
% ---------------------------------------------------------------
% Written by: Clare Kelly, 22nd March 2012
% ---------------------------------------------------------------
% 
% NOTE THAT THE AFNI AND FSL MATLAB DIRECTORIES MUST BE INSTALLED,
% ALONG WITH THE SPECTRAL CLUSTERING LIBRARY: http://www.cs.washington.edu/homes/deepak/spectral/library.tgz
%
% ---------------------------------------------------------------


%% SET UP -  please enter variables below

afnipath='/path/afni'
fslapth='/path/fsl'
spectralpath='/path/SPECTRALlibrary'

addpath(genpath(afnipath));
addpath(genpath(fslpath));
addpath(genpath(spectralpath));

ROIname={'ROIname'}; % Provide the NAME of the ROI you want to cluster

ROI={'/path/white/ROIname_NUMBERED+tlrc.HEAD'};
% Use make_eta_mask.m to create the ROI image file.
% Provide the path to the ROI image file. The ROI MUST be an AFNI volume (+tlrc, not .nii.gz)
% and should be in MNI 4mm standard space. Every voxel in the ROI image files MUST BE NUMBERED 1 to N

k=30; % HOW MANY CLUSTERS DO YOU WANT?

sites = {'Berlin','China','Cleveland', 'Finland','Harvard','Leiden','Mostofsky','NKI','NYU_new','NYU_w0_controls','Oxford','Pittsburgh','Queensland','Stanford','UMDNJ','WashU_Marcus','Wisconsin','Yale'};
% What sites do you want to include? If you have only one site/directory,
% the script should still work, but you should comment out the multisite consensus
% clustering section at the bottom of the script
listpath={'/path/sublists'}; % Path to lists of subjects included for each site

datapath={'/path'}; % Path to site directories containing subjects
rest_dirname={'func'}; % Name of subject directory containing resting state scan

pp_imname={'rest_res'}; % Name of NATIVE SPACE preprocessed/nuisance signal regressed resting state scan (must be .nii.gz file - do not include suffix here)
mask_imname={'mask_4mm'}; % Name of NATIVE SPACEmask image (must be .nii.gz file - do not include suffix here)
pp_imname_Standard={'rest_res2standard_4mm'}; % Name of 4mm STANDARD SPACE preprocessed/nuisance signal regressed resting state scan.
% Note that each subject's reprocessed/nuisance signal regressed resting state scan should be in MNI 4mm standard space and 
% should be a .nii.gz file (do not include suffix here)


%% At SITE/GROUP level: Generate correlation images, compute eta-squared, do spectral clustering, create consensus matrix, do consensus clustering

display(['Current ROI is ' ROIname])

[roiVol, Info]=BrikLoad(ROI);
dimsROI=Info.DATASET_DIMENSIONS;

numVox=size(find(roiVol>0),1); % Number of voxels in the ROI

% Site loop
for site=1:length(sites)
    
    display(['Current site is ' sites{site}])
    
    sublist=textread([listpath '/' sites{site} '_subs.txt'],'%s');
    
    etaSq=zeros(numVox, numVox, length(sublist));
    assignment=zeros(numVox, k-1, length(sublist));
    
    % Subject loop
    for sub=1:length(sublist)
        
        display(['Current subject is ' sublist{sub}])
        
        MNIdata=([datapath '/' sites{site} '/' sublist{sub} '/' rest_dirname '/' pp_imname_Standard '.nii.gz']);
        
        NATIVEdata=([datapath '/' sites{site} '/' sublist{sub} '/' rest_dirname '/' pp_imname '.nii.gz']);
        
        mask=([datapath '/' sites{site} '/' sublist{sub} '/' rest_dirname '/' mask_imname '.nii.gz']);
        
        % Compute whole-brain correlation for each voxel in the ROI mask
        display('Computing whole-brain correlations')
        
        tic
        corrs = do_maskcorr_masked(ROIs, MNIdata, NATIVEdata, mask);
        toc
        
        % Remove any Nans in the correlation matrix
        if ~isempty(find(isnan(corrs(:,1))==1)==1)
            indices=find(isnan(corrs(:,1))==1);
            otherindices=find(isnan(corrs(:,1))==0);
            for i=1:length(indices),
                corrs(indices(i),:) = mean(corrs(otherindices,:),1);
            end
        end
        if ~isempty(find(isnan(corrs(1,:))==1)==1)
            indices=find(isnan(corrs(1,:))==1);
            otherindices=find(isnan(corrs(1,:))==0);
            for i=1:length(indices),
                corrs(:,indices(i)) = mean(corrs(:,otherindices),2);
            end
        end
        
        % Compute eta-squared
        display('Generating eta^2 matirx')
        
        tic
        etaSq = do_eta_matal(corrs);
        toc
        
        clear corrs
        
        % Do spectral clustering
        display(['Clustering eta^2 matrix for k=1:' num2str(k)])
        
        tic
        assignment(:,:,sub) = do_single_subject_spectral(etaSq, k);
        toc
    end % end of subject loop
    
    clear etaSq
    
    saveName=[ROIname '_' sites{site} '_assignments']; %saving subject cluster assignments for current site
    save(saveName, 'assignment')
    
    % Site/Group-based Consensus Matrix and Clustering
    
    consensus_mat = make_consensus_mat(assignment);
    
    consensus_assignments(:,:,site) = do_consensus_spectral(consensus_mat);
    
    % Create images of site/group-based cluster solutions
    for solution=2:size(consensus_assignments,2)+1
        
        currAssignment=consensus_assignments(:,solution-1,site);
        
        prefix=['volumized/' ROIname '_' sites{site} '_consensus_assignment_k' num2str(solution) ];
        space='tlrc'
        
        volumize_clusters(ROIs, currAssignment, solution, prefix, space)
        %space should be 'orig' (NATIVE) or 'tlrc' (MNI)     
    end
    
    clear consensus_mat
    
end


%% Multisite Consensus - Comment this part out if you only have one site!

multisite_consensus_mat = make_consensus_mat(consensus_assignments);

multisite_consensus_assignments = do_consensus_spectral(multisite_consensus_mat);

% Create images of site/group-based cluster solutions
for solution=2:size(consensus_assignments,2)+1
    
    currAssignment=consensus_assignments(:,solution-1,site);
    
    prefix=['volumized/' ROIname '_multisite_consensus_assignment_k' num2str(solution) ];
    space='tlrc'
    
    volumize_clusters(ROIs, currAssignment, solution, prefix, space)
    %space should be 'orig' (NATIVE) or 'tlrc' (MNI)
end

saveName='multistite_consensus';
outVar1='multisite_consensusMat';
outVar2='multisite_consensusAssign';
save(saveName, outVar1, outVar2)



