function [DXA_region_label] = select_DXA_region_volume_label(hdr, femur_of_interest, two_cm_distal_center, Neck_landmarks_voxel)
% This function selects the DXA region label from the whole-femur label
% Necessary input: hdr, whole-femur label (femur_of_interest), two_cm_distal_center, Neck_landmarks_voxel
% Out put: label of the selected region (DXA_region_label)

%% Crop label (distal cut)
% crop distal end using the landmark 2mm distal from the lesser trochanter.  
two_cm_distal_voxel=round(abs(two_cm_distal_center  ./ hdr.ElementSpacing));  %convert to voxel information

label_size=size(femur_of_interest);
     
% select slices to remain (remove distal slices)
cropped_label=femur_of_interest(:,:,two_cm_distal_voxel(3):label_size(:,3));
% need to add zeros to the distal slices
zero_label = zeros([512,512,two_cm_distal_voxel(3)-1],'like',femur_of_interest);
% unite
distal_cropped_label=cat(3,zero_label,cropped_label);

%% Crop label (neck cut)    
% Plane fitting by PCA algorithm
center = mean(Neck_landmarks_voxel, 1);
r = Neck_landmarks_voxel - center;
coeff = pca(r);
nvec = coeff(:, 3); % 3rd principal component
    
% Calculate cutting area
distal_cropped_label_size = size(distal_cropped_label);
y = linspace(0, distal_cropped_label_size(1)-1, distal_cropped_label_size(1));
x = linspace(0, distal_cropped_label_size(2)-1, distal_cropped_label_size(2));
z = linspace(0, distal_cropped_label_size(3)-1, distal_cropped_label_size(3));
[Y, X, Z] = meshgrid(y, x, z);
  if nvec(3) > 0
     nvec = nvec * -1; % filp vector
  end
cutting_func = nvec(1)*(X-center(1))+ nvec(2)*(Y-center(2))+ nvec(3)*(Z-center(3));
cutting_label = cutting_func > 0;
    
% Neck cutting
cutting_label = int16(cutting_label); % Cast
cut_label = distal_cropped_label .* cutting_label;% proximal femur without femoral head  

%% Remove small islands
stats = regionprops3(cut_label==1, 'Volume', 'VoxelIdxList','Centroid');
[~, index] = maxk([stats.Volume],1);

DXA_region_label = zeros(size(cut_label),'like',cut_label);
selected_voxels = false(size(cut_label));
selected_voxels(stats.VoxelIdxList{index(1)}) = true;    
DXA_region_label(selected_voxels) = 1; 
