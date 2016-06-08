% Initialise a Growing Neural Gas Network Structure
function [GNG] = InitRGNG(GNG,center,prenumnode)

% Predefined Number of nodes
  GNG.Pre_numnode=prenumnode;

% Dimensionality of feature space
  GNG.NoFeats=size(GNG.dataset,2)-1;

% The max class label in the RGNG network
  GNG.NoClasses=max(unique(GNG.dataset(:,GNG.NoFeats+1))); %All the class label must be equal or over 1

% Update learning rate coefficients
  GNG.eb = 0.05;    %Learning rate of the winning node S
  GNG.en = 0.006;   %Learning rate of the direct topological neighbors of S
	
% Decreasing rate of all local error variable values
  GNG.beta = 0.001;
% 
% Error decreasing rate of q and f- when a new node r is inserted between q and f
  GNG.alpha = 0.5;

% Norm metric to be used, 2=>euclidean
  GNG.metric = 2;

% Initialise connection set C - links
  temp = zeros(size(center,1),1);
  GNG.C=-1+diag(temp,0);  % '-1' represents having no connection

% Local accumulated error array of all nodes in the network
  GNG.E=zeros(1,size(center,1));

% Training epoch for every new inserted node
  GNG.epochspernode=10;
  GNG.stopcriteria=0.0001;

% Edge removal threshold
  GNG.edgethred=100;

% Initializing reference vector weights
  GNG.w=center;