function [Info] = volumize_clusters(roiMask, assignment, numClust, prefix, space)

%Written by: Clare Kelly, Senior Underpants Gnome, 1st June 2011
%---------------------------------------------------------------
%Usage: volumize_clusters(roiMask, assignment, numClust, prefix)
%
%roiMask is the name (including full path) of the ROI image used to
%generate correlations and etaSq (e.g.,
%'/pathtoROI/right_ofc_4mm_10sit_453su_masked_NUMBERED+tlrc')
%
%assignment is a vector (n voxels x 1) of cluster assignments
%
%numClust is the number of clusters in the assignment
%
%prefix is the output name, including path (e.g.,
%'/path/sub1_right_ofc_k_2')
%

[volume, Info] = BrikLoad(roiMask);

nums=volume(find(volume>0));
out=zeros(size(volume));

for i = 1:size(volume,1),
    for j = 1:size(volume,2),
        for k = 1:size(volume,3),
            
            if volume(i, j, k) > 0
                
                currVoxel = volume(i,j,k),
                                
                index=find(nums==currVoxel);
                
                out(i, j, k) = assignment(index, 1);
                
            else
            end
        end
    end
end

Opt.View= space;
eval(['Info.BRICK_STATS=[0 ' num2str(numClust) ']']);

Opt.Prefix = prefix;
WriteBrik (out, Info, Opt);
end