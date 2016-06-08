% 17th Feb 2011

function [consensusMat]=make_consensus_mat(assignments)
%   Create consensus matrix quantifying stability of voxel-wise
%   cluster assignments across multiple subjects or
%   multiple iterations at the single-subject or group level
%
%   [consensusMat]=make_consensus_mat(assignments)
%
%   assignments is a 3-dimensional matrix containing the 
%   cluster assignments, where the dimensions are:
%   1st dimension (rows) = voxels (i.e., the cluster assignment for voxel n)
%   2nd dimension = different k/solutions (e.g., for k =2, 3, 4 etc)
%   (i.e., voxel-wise assignments to 2, 3 and 4 clusters for 10 subjects)
%   3rd dimension (columns) = subjects (or iterations) 
%   (i.e., voxel-wise cluster assignments for subject/iteration i)
%
%   The resultant consensusMat is then an nxn matrix (where n is the number
%   of voxels) quantifying the proportion of times (across subjects or
%   iterations) that each pair of voxels were placed in the same or
%   different clusters. The third dimension corresponds to k or solution
%   number. This matrix can then be clustered again, using the same k
%   (i.e., if the first k was 2, you should cluster consensusMat(:,:,1) for
%   k = 2)

for solution = 2:(size(assignments,2)+1)
    
    adjacencyMat = zeros(size(assignments,1), size(assignments,1));
    currSolutionMat = squeeze(assignments(:,solution-1,:));
    
    for n = 1:solution
        for sub = 1:size(currSolutionMat, 2),
            adjacencyMat(currSolutionMat(:,sub)==n, currSolutionMat(:,sub)==n) = adjacencyMat(currSolutionMat(:,sub)==n, currSolutionMat(:,sub)==n)+1;
        end
    end
    
    consensusMat(:,:,solution-1) = adjacencyMat/size(currSolutionMat,2);
end

    