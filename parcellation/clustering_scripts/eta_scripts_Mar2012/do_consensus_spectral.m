
function consensus_assignments = do_consensus_spectral(consensusMat)

%Written by: Clare Kelly, Senior Underpants Gnome, 17th Feb 2011
%---------------------------------------------------------------

global_options
params1  = 'mcut_all';
params2 = 'kmeans';


for solution=2:(size(consensusMat,3)+1)
   
    consensus_assignments(:, solution-1)= transpose(cluster_spectral_general(consensusMat(:,:,solution-1), solution, params1, params2));
   
end
