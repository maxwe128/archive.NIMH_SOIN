%Perform Majority voting classifier
function [CR] = MajorVot(center,trainset,testset)
% [trainset,testset]=Normalization(trainset,testset);

%The max class label in the GNG network
 realclass=unique(trainset(:,size(trainset,2)));
 NoClasses=max(realclass); %All the class label must over 1


for i=1:size(center,1)
    eval(['Clut' int2str(i) '= [];']);
end
for i=1:size(trainset,1)
    CurVec=trainset(i,1:size(trainset,2)-1);
    
    d=[];
    for h=1:size(center,1)
        d(h) = norm((CurVec-center(h,:)),2)^2;
    end
    
    [minval,s] = min(d);
    eval(['Clut' int2str(s) '= [Clut' int2str(s) ';trainset(i,:)];']);
end

tempremove=[];
for i=1:size(center,1)
    eval(['tempdata=Clut' int2str(i) ';']);
    if isempty(tempdata)
        tempremove=[tempremove,i];
    end
end

nodelabel=[];
for i=1:size(center,1)
  if ~ismember(i,tempremove)
    eval(['templabel=Clut' int2str(i) '(:,size(trainset,2));']);
    noclass=[];
    for j=1:NoClasses
        noclass=[noclass,size(find(templabel==j),1)];
    end
    [maxval,label]=max(noclass);
    if size(find(noclass==maxval),2) >= 2
        temp = find(noclass==maxval);
        temp1=[];
        minv=9999;
        for j=1:size(temp,2)
            temp1=find(templabel==temp(j));
            value=0;
            for k=1:size(temp1,1)
                eval(['value = value + norm(Clut' int2str(i) '(temp1(k),1:(size(trainset,2)-1))-center(i,:),2)^2;']);
            end
            if value < minv
                minv=value;
                label=temp(j);
            end
        end
    end
    nodelabel=[nodelabel,label];
  end
end
center(tempremove,:)=[];
% nodelabel(tempremove)=[];

%Calculate the classification accuracy
NoTrue=0;    %The number of correct classification
NoFalse=0;   %The number of false classification
for i=1:size(testset,1)
    d=[];
	CurVec = testset(i,1:size(testset,2)-1);	
	PClasslabel = testset(i,size(testset,2));
	for j=1:size(center,1)
		d(j) = norm(CurVec-center(j,:),2)^2;
	end
    [minval,s]=min(d);
    if PClasslabel==nodelabel(s)
        NoTrue=NoTrue+1;
    else
        NoFalse=NoFalse+1;   %Here we merge rejection instances into the false classified instances
    end
end
CR = NoTrue/(NoTrue+NoFalse);