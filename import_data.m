function [img, hdr, bilateral_femur_label, Neck_landmarks_voxel, head_center, neck_center, two_cm_distal_center, five_cm_distal_center,side, slope, intercept] = import_data(input_json_filename)
% This function imports parameters, images, and labels that are necessary for analysis
% Required information for each case that needs to be imported
  % CT image(in .mhd)
  % label from U-net(in .mhd)
  % eight landmarks (4 around the neck, 2cm distal from the lesser trochanter, 5cm distal from the lesser trochanter, head center, neck center)(in .fcsv)
  % side of interest ('L' or 'R')
  % slope and intercept of the regression model to convert HU into BMD (if conversion is not necessary, define slope and intercept as 0)
   
%% Required function (mhdread)
addpath('.\function');

%% Import sample data
S = jsondecode(fileread(input_json_filename));
[pathstr, name, ext] = fileparts(input_json_filename);

[side, slope, intercept, fcsvfile, img_filename, label_filename] = deal(S.side, S.slope, S.intercept, fullfile(pathstr, S.fcsvfile), fullfile(pathstr, S.img_filename), fullfile(pathstr, S.label_filename));

%% start analysis
%Import landmark coordinates from 3D slicer (load from fcsvfile)
[positions, IDs] =LoadSlicerFiducialFile(fcsvfile);
% change order if necessary
head_center=positions(1,:); % head center
neck_center=positions(2,:); % neck center
neck_superior=positions(3,:); % superior head-neck junction
neck_inferior=positions(4,:); % inferior head-neck junction
neck_anterior=positions(5,:); % anterior head-neck junction
neck_posterior=positions(6,:); % posterior head-neck junction
two_cm_distal_center=positions(7,:); % 2cm distal from the lesser trochanter
five_cm_distal_center=positions(8,:); % 5cm distal from the lesser trochanter
Neck_four_landmarks=[neck_superior;neck_inferior;neck_anterior;neck_posterior]; % four landmarks around the neck. Used for neck cut

% load image file
[img, hdr] = mhdread(img_filename );  
% load bilateral femur label file (segmented using U-net)
[bilateral_femur_label, label_hdr] = mhdread(label_filename);    

% calculate voxel information for the neck landmarks
Neck_landmarks_voxel=round(abs(Neck_four_landmarks ./ hdr.ElementSpacing));  