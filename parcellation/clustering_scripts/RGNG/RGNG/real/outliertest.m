function [mdlvalue,outdata] = outliertest(dataset,center)
yeta=0.000005; % Data accuracy
ki=1.2;% Error balance coefficient
rangevalue=max(max(dataset(:,1:size(dataset,2)-1)))-min(min(dataset(:,1:size(dataset,2)-1)));

harmdist=zeros(1,size(center,1));
counter=zeros(1,size(center,1));
inderrorvector=zeros(size(center,1),size(center,2));
totalerrorvec=[];
for i=1:size(center,1)
    eval(['winset' int2str(i) '=[];']);
end

for i=1:size(dataset,1)
    d=[];
	for j=1:size(center,1)
        d(j) = norm(dataset(i,1:size(dataset,2)-1)-center(j,:),2);	 % Find rooted square error
    end
	[minval,s] = min(d);
    harmdist(s)=harmdist(s)+1/minval;
    counter(s)=counter(s)+1;
    eval(['winset' int2str(s) '=[winset' int2str(s) ';dataset(i,:)];']);
    inderrorvector(s,:)=inderrorvector(s,:) + (dataset(i,1:size(dataset,2)-1)-center(s,:)).^2;
    totalerrorvec=[totalerrorvec;(dataset(i,1:size(dataset,2)-1)-center(s,:)).^2];
end
for i=1:size(counter,2)
    if counter(i)~=0
        harmdist(i) = harmdist(i)/counter(i);
    else
        harmdist(i)=99999999;
    end
end
disvector=zeros(1,size(dataset,1));
for i=1:size(dataset,1)
    d=[];
	for j=1:size(center,1)
        d(j) = norm(dataset(i,1:size(dataset,2)-1)-center(j,:),2);	 % Find squared error
    end
    disvector(i)=sum(1./(d.*harmdist));
end

[A,outliercandidate] = sort(disvector);

% errorvector = std(totalerrorvec,1).^2;

outdata=[];
errorvalue=0;
protosize=size(center,1);
flagprototype=0;

for i=1:size(outliercandidate,2)
    d=[];    
    for j=1:size(center,1)
        d(j) = norm(dataset(outliercandidate(i),1:size(dataset,2)-1)-center(j,:),2);	 % Find rooted square error
	end
	[minval,s] = min(d);
    erroradd=0;
    for h=1:(size(dataset,2)-1)
        if abs(dataset(outliercandidate(i),h)-center(s,h)) ~= 0
            erroradd=erroradd+max(log2(abs(dataset(outliercandidate(i),h)-center(s,h))/yeta),1);
        else
            erroradd=erroradd+1;
        end
    end
    errorvalue=errorvalue+erroradd;
    if counter(s) >= 2
        flagprototype=0;
        indexchange=log2(protosize);
    else
        indexchange = log2(protosize)+(size(dataset,1)-size(outdata,1)-1)*(log2(protosize)-log2(protosize-1));
        protosize = protosize-1;
        flagprototype=1;
    end
       
    if (ki*erroradd + indexchange)+flagprototype*size(center,2)*(ceil(log2(rangevalue/yeta))+1) > (size(dataset,2)-1)*(ceil(log2(rangevalue/yeta))+1) 
        outdata=[outdata;dataset(outliercandidate(i),1:size(dataset,2)-1)];
        counter(s)=counter(s)-1;
        errorvalue=errorvalue-erroradd;
    end
end

indexvalue=(size(dataset,1)-size(outdata,1))*log2(protosize+1);
mdlvalue = protosize*size(center,2)*(ceil(log2(rangevalue/yeta))+1) + indexvalue + ki*errorvalue + size(outdata,1)*(size(dataset,2)-1)*(ceil(log2(rangevalue/yeta))+1) 
    



