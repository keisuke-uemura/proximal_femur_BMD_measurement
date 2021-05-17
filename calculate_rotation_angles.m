function [rotation_Angles] = calculate_rotation_angles(head_center, neck_center, two_cm_distal_center, five_cm_distal_center)
% This function quantifies the rotation angles necessary to rotate the femur model to the neutral position 

% Necessary input: coordinates of the head_center, neck_center, two_cm_distal_center, five_cm_distal_center
% Output: rotation_Angles

%% Calculate rotation angles to transfer the models into the neutral position (rotation around the z-axis and y-axis)
   
four_coordinates=[head_center;neck_center;two_cm_distal_center;five_cm_distal_center];  
   
neck_axis=neck_center-head_center;
shaft_axis=five_cm_distal_center-two_cm_distal_center;
   
%calculate rotation angle around the z-axis
z_rot_angle=atand(neck_axis(2)/neck_axis(1));

%rotation around z-axis 
Rz = [cosd(z_rot_angle) -sind(z_rot_angle) 0; sind(z_rot_angle) cosd(z_rot_angle) 0; 0 0 1];
    
rotated= four_coordinates*Rz;  
zrot_shaft_axis=rotated(4,:)-rotated(3,:); % shaft axis after rotated around the z-axis
     
%calculate rotation angle around the y-axis
y_rot_angle=atand(zrot_shaft_axis(1)/zrot_shaft_axis(3));
   
rotation_Angles=[z_rot_angle;y_rot_angle];