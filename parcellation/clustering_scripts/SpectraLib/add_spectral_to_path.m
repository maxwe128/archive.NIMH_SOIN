% adds the Spectral directories to the path. (Ack: modelled on Kevin
% Murphy's BNT add_BNT_to_path

global SPECTRAL_HOME
SPECTRAL_HOME = getenv('SPECTRAL_HOME') ;
if isempty(SPECTRAL_HOME) 
  SPECTRAL_HOME='/x/wmn14/turnernl/CLUSTERING/scripts/SpectraLib';
end

addpath(genpath(SPECTRAL_HOME));

