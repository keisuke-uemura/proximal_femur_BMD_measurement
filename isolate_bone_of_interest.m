function [femur_of_interest] = isolate_bone_of_interest(bilateral_femur_label,side)
% This function selects the femur of interest (left or right) from the femur label segmented by the U-net
% Necessary imput
  % segmented labels (bilateral_femur_label)
  % side of interest ('L' or 'R')
% Output: label of the interested side (femur_of_interest)

 
%% Isolate the targeted side femur label from the U-net segmented femur labels 

%create label
femur_of_interest = zeros(size(bilateral_femur_label),'like',bilateral_femur_label);
       
stats = regionprops3(bilateral_femur_label==1, 'Volume', 'VoxelIdxList','Centroid');            
[~, index] = maxk([stats.Volume],2);%remove small islands and select two large islands (i.e. left and right femur)
           
%get the coordinates of the y-axis
largest_island_centroid=stats.Centroid(index(1),2);
                            
%get the coordinates of the y-axis
second_largestisland_centroid=stats.Centroid(index(2),2);
          
%select the side of interest using the y-coordinates of the centroid
  if string(side)=={'L'} && largest_island_centroid>second_largestisland_centroid || string(side)=={'R'} && largest_island_centroid<second_largestisland_centroid 
              
     selected_island = false(size(bilateral_femur_label));
     selected_island(stats.VoxelIdxList{index(1)}) = true;    
     femur_of_interest(selected_island) = 1; 
          
   elseif  string(side)=={'L'} && largest_island_centroid<second_largestisland_centroid || string(side)=={'R'} && largest_island_centroid>second_largestisland_centroid  %this means 'Right' is the secondlargestisland
             
     selected_island = false(size(bilateral_femur_label));
     selected_island(stats.VoxelIdxList{index(2)}) = true;    
     femur_of_interest(selected_island) = 1;                            
   end    