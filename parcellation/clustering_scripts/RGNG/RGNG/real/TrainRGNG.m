%Training Rboust Growing Neural Gas Network
function [optcenter,allmdlvalue]=TrainRGNG(RGNG)

% optcenter ------- the obtained cluster center positions corrresponding to the minimal description length
% actcenter --------- the cluster center positions when the number of cluster center is equal to the actual one
% allmdlvalue ----- the MDL value caculated at each growth stage

%Training the network
rand('state',0);
nofirsttimeflag=0;
stopflag=1;
allmdlvalue=[];
previousmdlvalue=99999999;
% t=0;
epsilon=10^(-5);

RGNG.prenode=ones(1,2);
while (size(RGNG.w,1) <=  RGNG.Pre_numnode) & (stopflag==1)
    disp(['Training when the number of the nodes in RGNG is: ',int2str(size(RGNG.w,1)),' ...']);
    RGNG.previousw=RGNG.w;
    flag=1;
  
    harmdist=[];
    for i=1:size(RGNG.w,1)
        temp=0;
        for k=1:size(RGNG.dataset,1)
            temp=temp+1/(norm(RGNG.dataset(k,1:RGNG.NoFeats)-RGNG.w(i,:),RGNG.metric)+epsilon);
        end
        harmdist(i)=temp/size(RGNG.dataset,1);
    end
  
    ebt=RGNG.ebi.*((RGNG.ebi /RGNG.ebi).^((RGNG.prenode-1)/(RGNG.Pre_numnode-1)));
    ent=RGNG.eni.*((RGNG.enf/RGNG.eni).^((RGNG.prenode-1)/(RGNG.Pre_numnode-1)));
  
    for iter2=0:RGNG.epochspernode-1
      
        tempvalue=1./harmdist;
   
        if flag==1   
            workdata= RGNG.dataset;	 % Copy to working dataset from which used samples are removed
            iter1=0;
    
            rand('state',sum(100*clock));
            while ~isempty(workdata)        
                iter1 = iter1+1;
                t=iter1+iter2*size(RGNG.dataset,1);

                    
                % 1: Select input sample
	              index = ceil(size(workdata,1)*rand(1,1));  % Choose a training sample randomly from the training dataset
	              CurVec = workdata(index,1:RGNG.NoFeats);
                  workdata(index,:) = [];                    % Remove the used samples

                % 2: Determine the winner S1 and the second nearest node S2
                  d=[];
	              for i=1:size(RGNG.w,1)
		              d(i) = norm(CurVec-RGNG.w(i,:),RGNG.metric)^2+epsilon;	 % Find square error
	              end
                  dtemp=d;
	              [minval,S1] = min(dtemp);
                  dtemp(S1)=99999999;
                  [secminval,S2] =min(dtemp); 

                % 3:Set up or refresh connection relationship between S1 and S2
                  RGNG.C(S1,S2)=0;
                  RGNG.C(S2,S1)=0;
          
	
                % 4: Adapt the reference vectors of S1 and its direct topological neighbours
                  if d(S1) > tempvalue(S1)
                      tempvalue(S1)=2/(1/d(S1)+1/tempvalue(S1));
                      tempv=tempvalue(S1);
                  else
                      tempv=d(S1);
                      tempvalue(S1)=(d(S1)+tempvalue(S1))/2; 
                  end
        
        
	              RGNG.w(S1,:) = RGNG.w(S1,:) + ebt(S1)*tempv*((CurVec-RGNG.w(S1,:))/minval);	% Update winner node S1
	              for i=1:size(RGNG.C,1)			% find neighbours of the winning node S1 and update them
                      tempcounter=0;
                      tempdist=0;
                      if RGNG.C(S1,i) ~= -1
                          tempcounter=tempcounter+1;
                          tempdist = tempdist + norm(RGNG.w(i,:)-RGNG.w(S1,:),RGNG.metric)+epsilon;
                      end
              
                      if tempcounter==0
                          tempdist=0;
                      else
                          tempdist=tempdist/tempcounter;
                      end
                  
                  
                      if RGNG.C(S1,i) ~= -1
                          if d(i) > tempvalue(i)
                              tempvalue(i)=2/(1/d(i)+1/tempvalue(i));
                              tempv=tempvalue(i);
                          else
                              tempv=d(i);
                              tempvalue(i)=(d(i)+tempvalue(i))/2; 
                          end
                          RGNG.w(i,:) = RGNG.w(i,:) + ent(i)*tempv*((CurVec-RGNG.w(i,:))/d(i)) + exp(-(norm(RGNG.w(i,:)-RGNG.w(S1,:),RGNG.metric)+epsilon)/0.1)*2*tempdist*((RGNG.w(i,:)-RGNG.w(S1,:))./(norm(RGNG.w(i,:)-RGNG.w(S1,:),RGNG.metric)+epsilon));
		              end
                  end
    
                % 5: Increase the age of all edges emanating from S1
                  for i=1:size(RGNG.C,1)
                      if RGNG.C(S1,i) ~= -1
                          RGNG.C(S1,i)=RGNG.C(S1,i)+1;
                          RGNG.C(i,S1)=RGNG.C(i,S1)+1;
		              end
	              end
    
                % 6: Removal of nodes
                  if nofirsttimeflag==1
                      for i=1:size(RGNG.C,1)
                          if max(RGNG.C(i,:)) > RGNG.edgethred
                              [maxval,Sr]=max(RGNG.C(i,:));
                              RGNG.C(i,Sr)=-1;
                              RGNG.C(Sr,i)=-1;
                          end
                      end
                      temp=[];
                      for i=1:size(RGNG.C,1)
                          if RGNG.C(i,:) == -1
                              temp=[temp,i];
                          end
                      end
                      if ~isempty(temp)
                          RGNG.C(temp,:)=[];
                          RGNG.C(:,temp)=[];
                          RGNG.w(temp,:)=[];
                      end
                  end
         
%                   t=t+1;
%                   if mod(t,100) == 0, 
%                       hold off 
%                       plot(RGNG.dataset(1:size(RGNG.dataset,1)-4,1),RGNG.dataset(1:size(RGNG.dataset,1)-4,2),'r.')
%                       hold on 
%                       plot(RGNG.w(:,1),RGNG.w(:,2),'bx')
%                       drawnow
%                   end
            end
            crit=0;
            for i=1:size(RGNG.w,1)
                crit=crit+norm(RGNG.previousw(i,:)-RGNG.w(i,:),RGNG.metric)+epsilon;
            end
            crit=crit/size(RGNG.w,1);
            if crit <= RGNG.stopcriteria
                disp('stop');
                flag=0;
            else
                RGNG.previousw=RGNG.w;
            end  
        end 
     
        harmdist=[];
        for i=1:size(RGNG.w,1)
            temp=0;
            for k=1:size(RGNG.dataset,1)
                temp=temp+1/(norm(RGNG.dataset(k,1:RGNG.NoFeats)-RGNG.w(i,:),RGNG.metric)+epsilon);
            end
            harmdist(i)=temp/size(RGNG.dataset,1);
        end
    end

    % Rebuiding the topology relationship among all current nodes
    tempC = zeros(size(RGNG.w,1),1);
    RGNG.C=-1+diag(tempC,0);  % '-1' represents having no connection
    harave=zeros(1,size(RGNG.w,1)); % Harmonic average distance for each node
    tcounter=zeros(1,size(RGNG.w,1)); % The total number of samples belonging to each node
    for i=1:size(RGNG.dataset,1)
        d=[];
        for j=1:size(RGNG.w,1)
           d(j) = norm(RGNG.dataset(i,1:RGNG.NoFeats)-RGNG.w(j,:),RGNG.metric)+epsilon;	 % Find square error
	    end
        [minval,s] = min(d);
        d(s)=99999999;
        [secminval,s2] =min(d); 
        RGNG.C(s,s2)=0;
        RGNG.C(s2,s)=0;
        tcounter(s)=tcounter(s)+1;
        harave(s)=harave(s)+1/minval;
    end
    if isempty(find(tcounter==0))
        harave=tcounter./harave;
    else
        harave(find(tcounter~=0))=tcounter(find(tcounter~=0))./harave(find(tcounter~=0));
    end
       
    RGNG.E=zeros(1,size(RGNG.w,1));
    for i=1:size(RGNG.dataset,1)
        d=[];
        for j=1:size(RGNG.w,1)
           d(j) = norm(RGNG.dataset(i,1:RGNG.NoFeats)-RGNG.w(j,:),RGNG.metric)+epsilon;	 % Find square error
	    end
        [minval,s] = min(d);
        d(s)=9999;
        RGNG.E(s)=RGNG.E(s)+exp(-(minval/harave(s)))*minval;
    end
  
    [CR] = MajorVot(RGNG.w,RGNG.dataset,RGNG.dataset)
   
    [mdlvalue] = outliertest(RGNG.dataset,RGNG.w);
    if mdlvalue < previousmdlvalue
        optcenter=RGNG.w;
        previousmdlvalue=mdlvalue;
    end
  
    allmdlvalue=[allmdlvalue,mdlvalue];
  
    % 10: Insert new node
      if size(RGNG.w,1) <  RGNG.Pre_numnode
          RGNG = AddNode(RGNG);
          RGNG.prenode=RGNG.prenode+1;
      else
          stopflag=0;
      end
    
      nofirsttimeflag==1;
end
