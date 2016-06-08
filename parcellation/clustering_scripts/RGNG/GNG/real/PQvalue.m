%Calculate partitional quality
function [totalpq] = PQvalue(center,dataset)

%The max class label in the RGNG network
 realclass=unique(dataset(:,size(dataset,2)));
 NoClasses=max(realclass); %All the class label must over 1


for i=1:size(center,1)
    eval(['Clut' int2str(i) '= [];']);
end
for i=1:size(dataset,1)
    CurVec=dataset(i,1:size(dataset,2)-1);
    d=[];
    for h=1:size(center,1)
        d(h) = norm((CurVec-center(h,:)),2)^2;
    end
    [minval,s] = min(d);
    eval(['Clut' int2str(s) '= [Clut' int2str(s) ';dataset(i,:)];']);
end

tempremove=[];
for i=1:size(center,1)
    eval(['tempdata=Clut' int2str(i) ';']);
    if isempty(tempdata)
        tempremove=[tempremove,i];
    end
end

center(tempremove,:)=[];


totalpq=0;
for i=1:size(center,1)
    eval(['tempdata=Clut' int2str(i) ';']);
    if ~isempty(tempdata)
        a=[];
        for k=1:size(realclass,1)
            a(k) = size(find(tempdata(:,size(tempdata,2))==realclass(k)),1);
        end
        totalpq=totalpq+sum((a/size(dataset,1)).^2);
    end
end
    
normvalue=[];
for k=1:size(realclass,1)
    normvalue(k) = size(find(dataset(:,size(dataset,2))==realclass(k)),1);
end
totalpq=totalpq/sum((normvalue/size(dataset,1)).^2);      