% Initialize a Growing Neural Gas Network Structure
function [RGNG] = InitRGNG(RGNG,center,prenumnode)

% Predefined Number of nodes
  RGNG.Pre_numnode=prenumnode;

% Dimensionality of feature space
  RGNG.NoFeats=size(RGNG.dataset,2)-1;

% The max class label in the RGNG network
  RGNG.NoClasses=max(unique(RGNG.dataset(:,RGNG.NoFeats+1))); %All the class label must be equal or over 1

% Update learning rate coefficients
  RGNG.ebi = 0.1;    %Initial learning rate of the winning node S
  RGNG.eni = 0.005;   %Initial learning rate of the direct topological neighbors of S
  RGNG.ebf = 0.01;    %Final learning rate of the winning node S
  RGNG.enf = 0.0005;   %Final learning rate of the direct topological neighbors of S

% Allocate field for nodes' weights
  RGNG.w=center;

% Norm metric to be used, 2=>Euclidean
  RGNG.metric = 2;

% Initialise connection set C - links
  temp = zeros(size(center,1),1);
  RGNG.C=-1+diag(temp,0);  % '-1' represents having no connection

% Local accumulated error array of all nodes in the network
  RGNG.E=zeros(1,size(center,1));

% Training epoch for every new inserted node
  RGNG.epochspernode=10; 
  RGNG.stopcriteria=0.00001;

% Edge removal threshold
  RGNG.edgethred=100;