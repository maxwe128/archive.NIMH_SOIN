
function assignments=do_single_subject_spectral(etaSq, k)

%Written by: Clare Kelly, Senior Underpants Gnome, 1st June 2011
%---------------------------------------------------------------

global_options
params1  = 'mcut_all';
params2 = 'kmeans';

assignments=zeros(size(etaSq,1), k-1);
mdl_values= zeros([1 size(k-1)]);

for solution=2:k
    display(['k=' num2str(solution)])
    
    [assignment, mdlvalue] = cluster_spectral_general(etaSq, solution, params1, params2);

    mdl_values(solution-1) = mdlvalue;
    assignments(:, solution-1) = assignment';
    
end

% Formatting the MDL data matrix for saving
mdl_values_size = size(mdl_values);

final_mdl_data_matrix = zeros(mdl_values_size(1)+1, mdl_values_size(2));

final_mdl_data_matrix(1,:) = [1:size(final_mdl_data_matrix,2)] + 1;
final_mdl_data_matrix(2:end,:) = mdl_values;

% Saving the MDL file
f_name = strcat('spectral','.MDL');

disp(strcat('Saving .MDL file...'))
save(f_name, 'final_mdl_data_matrix','-ascii','-double','-tabs');
