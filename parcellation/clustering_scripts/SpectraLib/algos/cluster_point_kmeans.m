function [assignment mdlvalue]=cluster_point_kmeans(xx,k,num_ortho,num_random) 
  global KMEANS_THRESHOLD KMEANS_MAX_ITER
  threshold=KMEANS_THRESHOLD;
  max_iter=KMEANS_MAX_ITER;
  
  [center, assignment, distortion]=kmeans_ortho_multiple(xx,k,num_ortho,num_random,threshold,max_iter);

  % Saving projected data points and cluster centers
  output_name = strcat('spectral_k',int2str(k));
  save_data_matrix(xx, output_name, '.DATA');
  save_data_matrix(center, output_name, '.CENTER');

  % determining the MDL value
  size_datamat = size(xx');
  xx_padded = zeros([size_datamat(1) size_datamat(2)+1]);
  xx_padded(1:size_datamat(1),1:size_datamat(2)) = xx';

  mdlvalue = outliertest(xx_padded,center');
end

function save_data_matrix(data_matrix, output_name, suffix)

	f_name = strcat(output_name, suffix);

	disp(strcat('Saving ',suffix,' file...'))
	save(f_name, 'data_matrix','-ascii','-double','-tabs');
end
