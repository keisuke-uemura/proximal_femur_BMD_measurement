function [Mean_pixel_density] = calculate_pixel_density(cropped_DRR_IMG)
% This function calculates the mean HU (or BMD) of the proximal femur and visualizes the DRR

% Necessary input: cropped_DRR_IMG (cropped labels)
% Output: Mean_pixel_density

%% Calculate mean density of the proximal femur

q = find(cropped_DRR_IMG);% calculate number of pixels without zero 
Mean_pixel_density=sum(cropped_DRR_IMG,'all')/length(q);
  
%% Visualize proximal femur DRR
m = find(cropped_DRR_IMG');% used to crop the y axis

xrange_small=ceil(q(1)/size(cropped_DRR_IMG,1))-20;xrange_large=ceil(q(end)/size(cropped_DRR_IMG,1))+20;% add margin of 20 pixels for visualization 
yrange_small=ceil(m(1)/size(cropped_DRR_IMG,2))-20;yrange_large=ceil(m(end)/size(cropped_DRR_IMG,2))+20;% add margin of 20 pixels for visualization

% visualize
figure()
imshow(cropped_DRR_IMG); colorbar;colormap('gray');
set(gca,'clim',[0 30000]);
set(gca,'xlim',[xrange_small xrange_large]);
set(gca,'ylim',[yrange_small inf]);
daspect([1 1 1])    