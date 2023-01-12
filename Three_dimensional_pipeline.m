% This skript shows the pipeline to calculate the mean voxel density of the 3D proximal femur.

% if converting the HU into BMD using a calibration phantom, change lines 17-18

% Necessary imput
  % refer to an example (setup.json)
% Necessary functions
  % mhdread.m
  % LoadSlicerFiducialFile.m
  % import_data.m
  % isolate_bone_of_interest.m
  % select_DXA_region_volume_label.m
  % calculate_voxel_density.m
% Output: Mean_voxel_density 

%% BMD conversion
conversion='Y';%if converting HU to BMD
% conversion='N';%if not converting HU

%% Analysis
input_json_filename = '.\sample\setup.json';

% import parameters
[img, hdr, bilateral_femur_label, Neck_landmarks_voxel, head_center, neck_center, two_cm_distal_center, five_cm_distal_center,side, slope, intercept] = import_data(input_json_filename);

% select target femur
[femur_of_interest] = isolate_bone_of_interest(bilateral_femur_label,side);

% selcet DXA region 3D model (crop 3D label and remove islands)
[DXA_region_label] = select_DXA_region_volume_label(hdr, femur_of_interest, two_cm_distal_center, Neck_landmarks_voxel);

%calculate density
Mean_voxel_density = calculate_voxel_density(img, DXA_region_label, slope, intercept, conversion)
