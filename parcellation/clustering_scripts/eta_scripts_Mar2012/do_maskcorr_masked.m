% Use Xinian's colcorr to compute all pairwise correlations within a mask

%function [corrs] = doMaskCorr(roi, MNIdata, NATIVEdata, mask)
function [corrs] = doMaskCorr(roi, MNIdata, NATIVEdata, mask)
[roiVol]=BrikLoad(roi);
dimsROI=size(roiVol);

[MNIdataVol, dimsMNI]=read_avw(MNIdata);
[NATIVEdataVol, dimsNATIVE]=read_avw(NATIVEdata);
[maskVol, dimsMASK]=read_avw(mask);


if sum(dimsROI(1:3))==sum(dimsMNI(1:3)) && sum(dimsMASK(1:3))==sum(dimsNATIVE(1:3)),
%if sum(dimsROI(1:3))==sum(dimsMNI(1:3)),    
    %MNI space data
    MNIdataReshape=reshape(MNIdataVol,dimsMNI(1)*dimsMNI(2)*dimsMNI(3),dimsMNI(4))';
    roiReshape=reshape(roiVol, dimsMNI(1)*dimsMNI(2)*dimsMNI(3),1)';
    ROInums=roiReshape(find(roiReshape>0));
    ROIindices=find(roiReshape>0);
    
    %NATIVE space data
    maskReshape=reshape(maskVol, dimsNATIVE(1)*dimsNATIVE(2)*dimsNATIVE(3), 1)';
    NATIVEdataReshape=reshape(NATIVEdataVol, dimsNATIVE(1)*dimsNATIVE(2)*dimsNATIVE(3), dimsNATIVE(4))';
        
    NATIVEdatamasked=NATIVEdataReshape(:,find(maskReshape==1));
    NATIVEindices=find(maskReshape==1);
    
    corrs = IPN_ColCorr3(MNIdataReshape(:,ROIindices), NATIVEdatamasked);
    
    %     for checking...
    %     corrs = IPN_ColCorr3(MNIdataReshape(:,ROIindices(1)), NATIVEdatamasked);
    %     corrVol=zeros(1, size(NATIVEdataReshape,2));
    %     corrVol(NATIVEindices)=corrs;
    %     corrVolRESHAPE=reshape(corrVol, dimsNATIVE(1), dimsNATIVE(2), dimsNATIVE(3));
    
    
else
    display('Data dimensions do not match. Check inputs')
    
end




