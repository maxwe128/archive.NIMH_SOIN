% Insert a new node	
function [GNG] = AddNode(GNG)

% Determine the unit q with maximum counter and unit p with second counter
  temp = GNG.E;
  [maxval,q] = max(temp);
  temp(q) = -99999999;
  [secmaxval,p] = max(temp);
  
% Find unit f among the neighbors of unit q with maximum counter
  f=[];
  maxval = -99999999;
  for i=1:size(GNG.C,1)
      if GNG.C(q,i) ~= -1
		  if GNG.E(i) > maxval
			  maxval=GNG.E(i);
			  f = i;
		  end
	  end 
  end

  % Check that a link was found
	if isempty(f)
        error('Unable to find a link to split for node insertion');
	end

  % Insert first new node r1
	GNG.w = [GNG.w;(2*GNG.w(q,:)+GNG.w(f,:))./3];	% Add the new reference vector for new node r1 from nodes q and f
	r1 = size(GNG.w,1);			                % Find index of r1
	GNG.C = [GNG.C,(-1)*ones(size(GNG.C,1),1)];	% Expand C 
	GNG.C = [GNG.C;(-1)*ones(1,size(GNG.C,2))];
	GNG.C(q,r1) = 0;			% Insert new connections
	GNG.C(r1,q) = 0;
	GNG.C(f,r1) = 0;
	GNG.C(r1,f) = 0;
	GNG.C(q,f) = -1;		% Remove original conncections between q and f
	GNG.C(f,q) = -1;
  
  % Decrease local error variables of q and f by a fraction GNG.alpha
    GNG.E(q)=(1-GNG.alpha)*GNG.E(q);
    GNG.E(f)=(1-GNG.alpha)*GNG.E(f);
    
  % Interpolate the error variable of r from q and f
    GNG.E=[GNG.E,(GNG.E(q)+GNG.E(f))/2];