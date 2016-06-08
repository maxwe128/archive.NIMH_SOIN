% Insert a new node	
function [RGNG] = AddNode(RGNG)

% Determine the unit q with maximum accumulated error and unit p with second maximum error
  atemp = RGNG.E;
  [maxval,q] = max(atemp);
  atemp=-99999999;
  [secondmax,p]=max(atemp);

% Find node f among the neighbors of unit q with maximum local error in the input space
  f=[];
  maxval = -99999999;
  for i=1:size(RGNG.C,1)
	  if RGNG.C(q,i) ~= -1
		  if RGNG.E(i) > maxval
			  maxval=RGNG.E(i);
			  f = i;
		  end
	  end 
  end
  
% Find node f among the neighbors of unit q with largest distance from q
%   if isempty(f)
%       f=[];
% 	  maxval = -1;
% 	  for i=1:size(RGNG.C,1)
% 		  if RGNG.C(q,i) ~= -1
% 			  if norm(RGNG.w(q,:)-RGNG.w(i,:),2) > maxval
% 			      maxval=norm(RGNG.w(q,:)-RGNG.w(i,:),2);
% 			      f = i;
% 			  end
% 		  end 
%       end
%   end

% % Check that a link was found
  if isempty(f)
      f=p;
  end

% % Visualize q and f founded
%   hold off 
%   plot(RGNG.dataset(1:size(RGNG.dataset,1)-4,1),RGNG.dataset(1:size(RGNG.dataset,1)-4,2),'r.')
%   hold on;
%   plot(RGNG.w(:,1),RGNG.w(:,2),'bx')
%   plot(RGNG.w(q,1),RGNG.w(q,2),'go');
%   plot(RGNG.w(f,1),RGNG.w(f,2),'bo');
%   drawnow

% Insert first new node r1
  RGNG.w = [RGNG.w;(2*RGNG.w(q,:)+RGNG.w(f,:))./3];	% Add the new reference vector for new node r1 from nodes q and f
  r1 = size(RGNG.w,1);			                % Find index of r1
  RGNG.C = [RGNG.C,(-1)*ones(size(RGNG.C,1),1)];	% Expand C 
  RGNG.C = [RGNG.C;(-1)*ones(1,size(RGNG.C,2))]; 
  RGNG.C(q,r1) = 0;			% Insert new connections
  RGNG.C(r1,q) = 0;
  RGNG.C(f,r1) = 0;
  RGNG.C(r1,f) = 0;
  RGNG.C(q,f) = -1;		% Remove original conncections between q and f
  RGNG.C(f,q) = -1;
  RGNG.prenode=[RGNG.prenode,0];
