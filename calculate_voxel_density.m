function [Mean_voxel_density] = calculate_voxel_density(img, DXA_region_label, slope, intercept, conversion)
% This function calculates the mean voxel density of the proximal femur
% Necessary Input: CT image, DXA_region_label, slope&intercept of the regression model, conversion information ('Y' or 'N')
% Output: Mean_voxel_density 

% If BMD conversion is necessary, use lines 13-15 will be used

%% Density analysis
all_voxel = double(img(DXA_region_label==1));
Mean_voxel_density= mean(all_voxel);
        
% convert HU into BMD using a regression model
 if string(conversion)=={'Y'}
    Mean_voxel_density =  Mean_voxel_density .* (slope)+intercept;
 end