% This skript shows the pipeline to calculate the mean pixel density of the 2D neck region.

% if converting the HU into BMD using a calibration phantom, change lines 21-22

% Necessary imput
  % refer to an example (sample_setup.json)
% Necessary functions
  % mhdread.m
  % LoadSlicerFiducialFile.m
  % RegTools
  % import_data.m
  % isolate_bone_of_interest.m
  % calculate_rotation_angles.m
  % generate_proximal_femur_DRR.m
  % select_neck_region_DRR_label.m
  % calculate_pixel_density.m
% Output: Mean_pixel_density 


%% BMD conversion
% conversion='Y';%if converting HU to BMD
conversion='N';%if not converting HU

%% Analysis

input_json_filename = '.\sample\sample_setup.json'; %importing sample data

% import parameters
[img, hdr, bilateral_femur_label, Neck_landmarks_voxel, head_center, neck_center, two_cm_distal_center, five_cm_distal_center,side, slope, intercept] = import_data(input_json_filename);

% select target femur
[femur_of_interest] = isolate_bone_of_interest(bilateral_femur_label,side);
  
% calculate rotation angles to rotate the femur model to the neutral position
rotation_Angles = calculate_rotation_angles(head_center, neck_center,two_cm_distal_center, five_cm_distal_center);

% generate DRR of the proximal femur
[DRR_IMG, two_cm_distal_DRR_IMG, Neck_superior_DRR_IMG, Neck_inferior_DRR_IMG, Neck_anterior_DRR_IMG, Neck_posterior_DRR_IMG] = ...
     generate_proximal_femur_DRR(img, hdr, Neck_landmarks_voxel, two_cm_distal_center, rotation_Angles, femur_of_interest,slope, intercept,conversion);

% select DRR image of the neck region
[cropped_DRR_IMG] = select_neck_region_DRR_label(DRR_IMG, two_cm_distal_DRR_IMG, Neck_superior_DRR_IMG, Neck_inferior_DRR_IMG, Neck_anterior_DRR_IMG, Neck_posterior_DRR_IMG);

% calculate density and visualize the region
[Mean_pixel_density] = calculate_pixel_density(cropped_DRR_IMG)