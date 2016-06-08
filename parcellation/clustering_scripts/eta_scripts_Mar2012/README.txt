Written by: Clare Kelly, March 2011

Set of scripts for performing eta-squared-based spectral clustering of brain regions, with consensus clustering, as described in:
A convergent functional architecture of the insula emerges across imaging modalities
NeuroImage, In Press, Available online 13 March 2012
Clare Kelly, Roberto Toro, Adriana Di Martino, Christine L. Cox, Pierre Bellec, F. Xavier Castellanos, Michael P. Milham
http://dx.doi.org/10.1016/j.neuroimage.2012.03.021

If you use these scripts for a publication, please provide the source (http://fcon_1000.projects.nitrc.org) and reference our paper.


The scripts should be run in the following order:

********************************************
1. make_eta_mask.m (matlab script)

This function divides your ROI into X number of 4x4x4mm voxels. It gives a unique number to each voxel, so that each voxel can be used as a seed ROI in subject-level functional connectivity analyses.

It is run as follows: make_eta_mask(ROI, outname)
EXAMPLE: make_eta_mask(/home/clare/left_striatum_4mm+tlrc, left_striatum_numbered)

Type help make_eta_mask for more info.

Prior to running this script, you must define the region of interest that you want to cluster.
Instructions on how to do this are provided in make_eta_mask.m
In the past, I have taken the relevant regions from the Harvard-Oxford atlas that comes with FSL and combined them as necessary to make my ROI. One issue that you need to think about is whether to do the two hemispheres separately. I have always clustered them hemispheres separately in the past because, besides connectivity with its nearest neighbours, a voxel's strongest connectivity is typically with the opposite hemisphere. This means that when you try to cluster regions, the drive will always to be to cluster left and right regions together. It would be interesting to explore this issue though as it may actually be informative (e.g., defining functional regions by their interhemispheric RSFC).

********************************************
2. cluster_roi_iFC.m (matlab script)

This script performs all the other steps of the clustering analysis:
 -computes subject-level correlations (functional connectivity)
 -computes subject-level eta-squared (between all pairs of correlation maps)
 -performs subject-level spectral clustering
 -generates site/group-level consensus matrix
 -performs site/group-level consensus clustering
 -generates site/group-level images of cluster solutions
 -generates multisite consensus matrix
 -performs multitie consensus clustering 
 -generates multisite images of cluster solutions
 
Please open the script and enter all the required variables

If you only have one site/group, comment out the multisite section at the bottom of the script

This script calls on all the other scripts included in this directory, so make sure you're in the right directory, or add them to the path:
do_maskcorr_masked.m
do_eta_matal.m
do_single_subject_spectral.m
make_consensus_mat.m
do_consensus_spectral.m
make_consensus_mat.m
volumize_clusters.m


********************************************

Happy clustering :)
