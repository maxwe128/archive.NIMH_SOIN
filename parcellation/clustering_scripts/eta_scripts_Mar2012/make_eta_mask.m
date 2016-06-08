function make_eta_mask(ROI, outname)

%THIS SCRIPT CREATES AN ROI (OF SET OF ROIS) IN WHICH EVERY 
%   VOXEL HAS A UNIQUE NUMBER
%   
%   Just provide the FULL PATH for both ROI and outname
%
%   EXAMPLE: make_eta_mask(/home/clare/left_striatum_4mm+tlrc, left_striatum_numbered)
%
%   Before running this script, you must have first created your ROI 
%   e.g., by combining Harvard-Oxford atlas ROIs
%
%   The combined ROI file should be at 4mm resolution and in AFNI format 
%   (i.e., with +tlrc.HEAD/BRIK.gz as the suffix)
%
%   For example the following command will create a 2mm resolution mask comprising the LEFT
%   caudate and LEFT putamen (using the 25% tissue probablilty masks):
%   3dcalc -a %${FSLDIR}/data/atlases/HarvardOxford-sub-maxprob-thr25-2mm.nii.gz \
%   -expr 'step(equals(a,11)+equals(a,12)+equals(a,26))' -prefix left_striatum
%
%   You will then need to change the view to +tlrc (standard space)
%   3drefit -view tlrc left_striatum+orig
%
%   You should then use the following command to resample to 4mm (note that
%   there must be a 4mm resampled standard brain in ${FSLDIR}/data/standard
%   3dresample -master ${FSLDIR}/data/standard/MNI152_T1_4mm.nii.gz \
%   -inset left_striatum+tlrc -prefix left_striatum_4mm

%   Written by: Clare Kelly, 17th Feb 2011
%   ---------------------------------------------------------------

[err, ROI, Info, ErrMessage] = BrikLoad(ROI);

m=0;
newROI=zeros(size(ROI));
for i = 1:size(ROI,1),
    for j = 1:size(ROI,2),
        for k = 1:size(ROI,3),
            if ROI(i,j,k) > 0,
                m=m+1;
                newROI(i,j,k)=m;
            else newROI(i,j,k)=0;
            end
        end
    end
end

Opt.Prefix=[outname];
Opt.view='+tlrc';
eval(['Info.BRICK_STATS=[0 ' num2str(max(newROI(:))) ']']);
Info.RootName=outname;
Info.TypeName='float'
Info.BRICK_TYPES=3;
[err, ErrMessage, Info] = WriteBrik(newROI, Info, Opt)
