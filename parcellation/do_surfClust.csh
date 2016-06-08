#!/bin/tcsh
cd /data/elliottml/Clustering/3T/Surf
matlab -nojvm -nodisplay -nosplash <<EOF
        scripts_dir = '/data/elliottml/Clustering/scripts/';
        addpath(scripts_dir);
        struct_spectral_clustering_surf('std.60.IPSRH_eta2.txt','std.60.rh_IPSROI1.1D.dset',15,'firstGoRH',1);
EOF
