function [DRR_IMG, two_cm_distal_DRR_IMG, Neck_superior_DRR_IMG, Neck_inferior_DRR_IMG, Neck_anterior_DRR_IMG, Neck_posterior_DRR_IMG] = generate_proximal_femur_DRR(img, hdr, Neck_landmarks_voxel, two_cm_distal_center, rotation_Angles, femur_of_interest,slope, intercept,conversion)
% This function converts HU to BMD using a regression model (if necessary), and generates DRR using Regtools

%% Required functions (Regtools)

% Add path to the Regtools (available from https://github.com/YoshitoOtake/RegTools))

%% Converting HU to BMD using a calibration phantom (when necessary)

 if string(conversion)=={'Y'}
    myu_img =  single(img) .* (slope)+intercept;% if using the phantom
 else 
    myu_img =  img;% if not using the phantom
 end
myu_img(~(femur_of_interest==2)) = 0;

%% Crop CTimage (roughly) to set up the camera position at the middle of the image

z_prox_Edge=max(find(max(max(femur_of_interest))));%get label edge information on the z-axis
label_permuted=permute(femur_of_interest,[3 2 1]);%get label information on the x-axis
x_prox_Edge=find(max(max(label_permuted)));
 
%crop the distal end using the landmark 2mm distal from the lesser trochanter
two_cm_distal_voxel=round(abs(two_cm_distal_center ./ hdr.ElementSpacing));  %convert to voxel information

%crop img to where labels exist. z-axis: add 20 voxels on each end for margin, x-axis: add 10 voxels on each end for margin 
myu_img_cropped = myu_img (min(x_prox_Edge)-10:max(x_prox_Edge)+10,:,two_cm_distal_voxel(3)-20:z_prox_Edge+20);
    
%crete volume image for the 2cm distal landmark. Set landmark location as 1
two_cm_distal=zeros(size(myu_img_cropped));
two_cm_distal(two_cm_distal_voxel(1)-min(x_prox_Edge)+10+1,two_cm_distal_voxel(2),20+1) = 1 ;

two_cm_distal=single(two_cm_distal);
    
% neck cut level information (similar to the 2cm distal landmark performed in lines 132-136)      
Neck_superior=zeros(size(myu_img_cropped)); % for superior head-neck junction
Neck_inferior=zeros(size(myu_img_cropped)); % for inferior head-neck junction
Neck_anterior=zeros(size(myu_img_cropped)); % for anterior head-neck junction
Neck_posterior=zeros(size(myu_img_cropped)); % for posterior head-neck junction
       
Neck_superior(Neck_landmarks_voxel(1,1)-min(x_prox_Edge)+10+1,Neck_landmarks_voxel(1,2),Neck_landmarks_voxel(1,3)-two_cm_distal_voxel(3)+20+1) = 1 ;
Neck_inferior(Neck_landmarks_voxel(2,1)-min(x_prox_Edge)+10+1,Neck_landmarks_voxel(2,2),Neck_landmarks_voxel(2,3)-two_cm_distal_voxel(3)+20+1) = 1 ;
Neck_anterior(Neck_landmarks_voxel(3,1)-min(x_prox_Edge)+10+1,Neck_landmarks_voxel(3,2),Neck_landmarks_voxel(3,3)-two_cm_distal_voxel(3)+20+1) = 1 ;
Neck_posterior(Neck_landmarks_voxel(4,1)-min(x_prox_Edge)+10+1,Neck_landmarks_voxel(4,2),Neck_landmarks_voxel(4,3)-two_cm_distal_voxel(3)+20+1) = 1 ;

Neck_superior=single(Neck_superior);
Neck_inferior=single(Neck_inferior);
Neck_anterior=single(Neck_anterior);
Neck_posterior=single(Neck_posterior);
    
%% DRR generation
SDD = 10000;% set source-to-detector distance as 10000 to simulate parallel projection
SAD = 10000;% set source-axis distance as 10000 to simulate parallel projection
DRR_size = [800 1000]; DRR_Pixel_size = [0.25 0.25];
num_views = 1;

% setup camera projection matrix for each view: 3 x 4 x number of views
extrinsic = RegTools.matTranslation([0 0 -SAD]) *RegTools.matRotationX(90);
intrinsic = [-SDD/DRR_Pixel_size(1) 0 DRR_size(1)/2; 0 -SDD/DRR_Pixel_size(2) DRR_size(2)/2; 0 0 1];
ProjectionMatrices_pix = repmat([intrinsic [0;0;0]] * extrinsic, [1 1  num_views]);

% setup object coordinate system for each view: 4 x 4 x number of views
transforms_4x4xN = zeros(4,4,num_views);

rotation_angle = -rotation_Angles(1);%flip
abd_angle = rotation_Angles(2);

  for i=1:num_views
        transforms_4x4xN(:,:,i) = RegTools.matRotationY(abd_angle)*RegTools.matRotationZ(rotation_angle);
  end

regTools = RegTools(0, [], 'log_file1.txt');
% prepare geometry
geomID = regTools.GenerateGeometry_3x4ProjectionMatrix( ProjectionMatrices_pix, [1 1], DRR_size, [1 1] );
% copy volume data to GPU
planID = regTools.CreateForwardProjectionPlan(myu_img_cropped, hdr.ElementSpacing);
planID2 = regTools.CreateForwardProjectionPlan(two_cm_distal, hdr.ElementSpacing);
planID3 = regTools.CreateForwardProjectionPlan(Neck_superior, hdr.ElementSpacing);
planID4 = regTools.CreateForwardProjectionPlan(Neck_inferior, hdr.ElementSpacing);
planID5 = regTools.CreateForwardProjectionPlan(Neck_anterior, hdr.ElementSpacing);
planID6 = regTools.CreateForwardProjectionPlan(Neck_posterior, hdr.ElementSpacing);

% generate DRR
DRR = regTools.ForwardProject(planID, transforms_4x4xN, [], 1); %DRR of femur
two_cm_distal_DRR = regTools.ForwardProject(planID2, transforms_4x4xN, [], 1); %projected landmark (two_cm_distal)
Neck_superior_DRR = regTools.ForwardProject(planID3, transforms_4x4xN, [], 1); %projected landmark (Neck_superior)
Neck_inferior_DRR = regTools.ForwardProject(planID4, transforms_4x4xN, [], 1); %projected landmark (Neck_inferior)
Neck_anterior_DRR = regTools.ForwardProject(planID5, transforms_4x4xN, [], 1); %projected landmark (Neck_anterior)
Neck_posterior_DRR = regTools.ForwardProject(planID6, transforms_4x4xN, [], 1); %projected landmark (Neck_posterior)

%permute DRR
DRR_IMG= permute(DRR(:,:,1),[2 1 3]);
two_cm_distal_DRR_IMG= permute(two_cm_distal_DRR(:,:,1),[2 1 3]);
Neck_superior_DRR_IMG= permute(Neck_superior_DRR(:,:,1),[2 1 3]);
Neck_inferior_DRR_IMG= permute(Neck_inferior_DRR(:,:,1),[2 1 3]);
Neck_anterior_DRR_IMG= permute(Neck_anterior_DRR(:,:,1),[2 1 3]);
Neck_posterior_DRR_IMG= permute(Neck_posterior_DRR(:,:,1),[2 1 3]);

% cleanup
regTools.DeleteForwardProjectionPlan(planID);
regTools.DeleteProjectionParametersArray(geomID);
regTools.DeleteForwardProjectionPlan(planID2);
regTools.DeleteForwardProjectionPlan(planID3);
regTools.DeleteForwardProjectionPlan(planID4);
regTools.DeleteForwardProjectionPlan(planID5);
regTools.DeleteForwardProjectionPlan(planID6);

clear regTools;