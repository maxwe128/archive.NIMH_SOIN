%Training Growing Neural Gas Network
function [optcenter,actcenter,allmdlvalue]=TrainGNG(GNG,realcenternum)

% Training the network
nofirsttimeflag=0;
stopflag=1;
allmdlvalue=[];
previousmdlvalue=99999;
% t=0;

while (size(GNG.w,1) <=  GNG.Pre_numnode) & (stopflag==1)
    disp(['Training when the number of the nodes in GNG is: ',int2str(size(GNG.w,1)),' ...']);
    GNG.previousw=GNG.w;
    flag=1;
  
    for iter2=1:GNG.epochspernode
        workdata = GNG.dataset;	 % Copy to working dataset from which used samples are removed
        rand('state',sum(100*clock));
        if flag==1
             while ~isempty(workdata)
             % 1: Select input sample
	           index = ceil(size(workdata,1)*rand(1,1));  % Choose a training sample randomly from the training dataset
	           CurVec = workdata(index,1:GNG.NoFeats);

             % 2: Determine the winner S1 and the second nearest node S2
               d=[];
	           for i=1:size(GNG.w,1)
		           d(i) = norm(CurVec-GNG.w(i,:),GNG.metric)^2;	 % Find squared error
	           end
              dtemp=d;
	          [minval,S1] = min(dtemp);
              dtemp(S1)=9999;
              [secminval,S2] =min(dtemp); 
     
            % 3:Set up or refresh connection relationship between S1 and S2
              GNG.C(S1,S2)=0;
              GNG.C(S2,S1)=0;
        
            % 4: Update Local Error Variable of Winner Node S1
	          GNG.E(S1) = GNG.E(S1) + minval; % Sum squared error
	
	        % 5: Adapt the reference vectors of S1 and its direct topological neighbours
	          GNG.w(S1,:) = GNG.w(S1,:) + GNG.eb*(CurVec-GNG.w(S1,:));	% Update winner node S1
	          for i=1:size(GNG.C,1)			% find neighbours of the winning node s and update them
                  if GNG.C(S1,i) ~= -1
                      GNG.w(i,:) = GNG.w(i,:) + GNG.en*(CurVec-GNG.w(i,:));
		          end
	          end
    
            % 6: Increase the age of all edges emanating from S1
              for i=1:size(GNG.C,1)			% Find neighbours of the winning node s and update them
                  if GNG.C(S1,i) ~= -1
                      GNG.C(S1,i)=GNG.C(S1,i)+1;
                      GNG.C(i,S1)=GNG.C(i,S1)+1;
		          end
	          end
    
            % 7: Removal of nodes
              if nofirsttimeflag==1
                  for i=1:size(GNG.C,1)
                      if max(GNG.C(i,:))>GNG.edgethred
                          [maxval,Sr]=max(GNG.C(i,:));
                          GNG.C(i,Sr)=-1;
                          GNG.C(Sr,i)=-1;
                      end
                  end
                  temp=[];
                  for i=1:size(GNG.C,1)
                      if GNG.C(i,:) == -1
                          temp=[temp,i];
                      end
                  end
                  if ~isempty(temp)
                      GNG.C(temp,:)=[];
                      GNG.C(:,temp)=[];
                      GNG.w(temp,:)=[];
                      GNG.E(temp)=[];
                  end
              end
          
%               t=t+1;
%               if mod(t,50) == 0, 
%                  hold off 
%                  plot(GNG.dataset(1:size(GNG.dataset,1)-4,1),GNG.dataset(1:size(GNG.dataset,1)-4,2),'r.')
%                  hold on 
%                  plot(GNG.w(:,1),GNG.w(:,2),'bx')
%                  drawnow
%               end

            % 8: Decrease error of all units
	          GNG.E = GNG.E*(1-GNG.beta);
       
              workdata(index,:) = [];                    % Remove the used samples
          
          
              crit=0;
              for i=1:size(GNG.w,1)
                  crit=crit+norm(GNG.previousw(i,:)-GNG.w(i,:),GNG.metric);
              end
              crit=crit/size(GNG.w,1);
              if crit <= GNG.stopcriteria
                  disp('stop');
                  flag=0;
              else
                  GNG.previousw=GNG.w;
              end
            end
        end
    end
    [CR] = MajorVot(GNG.w,GNG.dataset,GNG.dataset)
    
    [mdlvalue] = outliertest(GNG.dataset,GNG.w);
    if mdlvalue < previousmdlvalue
        optcenter=GNG.w;
        previousmdlvalue=mdlvalue;
    end
    if size(GNG.w,1)==realcenternum
        actcenter=GNG.w;
    end
  
    allmdlvalue=[allmdlvalue,mdlvalue];
    % 10: Insert new node
      if size(GNG.w,1) <  GNG.Pre_numnode
          GNG = AddNode(GNG);
      else
          stopflag=0;
      end

      nofirsttimeflag==1;
end