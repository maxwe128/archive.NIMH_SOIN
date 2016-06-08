function [tcounter,E,value,deadnodes] = runmultimod(actcenter,dataset,realcenter);

% actcenter --------- obtained cluster center positions when the number of prototypes equals the actual number of clusters 
% realcenter --------- actual cluster center positions
% dataset ---------- dataset used
% tcounter -------- The number of actual clusters found by implementing the RGNG
% E ------- The average local quantization error over all clusters
% vlauearray -------- The distance from obtained cluster centers to actual cluster centers
% deadnodes -------- The number of deadnodes generated when the number of prototypes equals the actual number of clusters

standneurons=realcenter;
value=0;
tcounter=0;
neurons=actcenter;

for j=1:size(standneurons,1)
    d=[];
    for k=1:size(neurons,1)
        d(k)=norm(neurons(k,:)-standneurons(j,:),2);
    end
    [minvalue,s]=min(d);
    if minvalue<= 0.24       %0.48 for D1 and 0.24 for D2
        tcounter=tcounter+1;
    end
end
tcounter
    
while ~isempty(neurons)
    tempd=[];
    tempneurons=[];
    for j=1:size(standneurons,1)
        d=[];
        for k=1:size(neurons,1)
            d(k)=norm(neurons(k,:)-standneurons(j,:),2)^2;
        end
        [minvalue,s]=min(d);
        tempd(j)=s;
        tempneurons(j)=minvalue;
    end
    deleted=[];
    for j=1:size(neurons,1)
        temp=find(tempd==j);
        if ~isempty(temp)
            if size(temp,2)==1
                value=value+tempneurons(temp);
                deleted=[deleted,temp];
            else
                [a,b]=min(tempneurons(temp));
                deleted=[deleted,temp(b)];
                value=value+a;
            end
        end
    end
    standneurons(deleted,:)=[];
    neurons(tempd(deleted),:)=[];
end

E=zeros(1,size(actcenter,1));
counter=zeros(1,size(actcenter,1));
for g=1:size(dataset,1)
    d=[];
	for z=1:size(actcenter,1)
		d(z) = norm(dataset(g,1:size(dataset,2)-1)-actcenter(z,:),2)^2;
	end
   [minval,s]=min(d);
   E(s)=E(s)+minval;
   counter(s)=counter(s)+1;
end
deadnodes=size(find(counter==0),2);

mm=0;
for f=1:size(counter,2)
    if counter(f)~=0
        E(f)=E(f)./counter(f);
        mm=mm+1;
    end
end
E=sum(E)/mm
 
value=value/size(actcenter,1);