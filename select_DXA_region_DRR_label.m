function [cropped_DRR_IMG] = select_DXA_region_DRR_label(DRR_IMG, two_cm_distal_DRR_IMG, Neck_superior_DRR_IMG, Neck_inferior_DRR_IMG, Neck_anterior_DRR_IMG, Neck_posterior_DRR_IMG)
% This function crops the DRR using the projected landmarks and quantifies the mean HU (or BMD) of the proximal femur 
% output: Mean_pixel_density
% visualizes proximal femur DRR

%% Crop DRR using the projected neck landmarks

%get pixel information of the 2cm distal lesser trochanter landmark on DRR
[Y_two_cm_distal,X_two_cm_distal]=ind2sub(size(two_cm_distal_DRR_IMG), find(two_cm_distal_DRR_IMG==max(two_cm_distal_DRR_IMG,[],'all')));
  
%get projected landmark coordinates around the neck
[Y_Neck_superior,X_Neck_superior]=ind2sub(size(Neck_superior_DRR_IMG), find(Neck_superior_DRR_IMG==max(Neck_superior_DRR_IMG,[],'all')));
[Y_Neck_inferior,X_Neck_inferior]=ind2sub(size(Neck_inferior_DRR_IMG), find(Neck_inferior_DRR_IMG==max(Neck_inferior_DRR_IMG,[],'all')));
[Y_Neck_anterior,X_Neck_anterior]=ind2sub(size(Neck_anterior_DRR_IMG), find(Neck_anterior_DRR_IMG==max(Neck_anterior_DRR_IMG,[],'all')));
[Y_Neck_posterior,X_Neck_posterior]=ind2sub(size(Neck_posterior_DRR_IMG), find(Neck_posterior_DRR_IMG==max(Neck_posterior_DRR_IMG,[],'all')));
  
four_projected_landmarks_Y=[Y_Neck_superior(1);Y_Neck_inferior(1);Y_Neck_anterior(1);Y_Neck_posterior(1)];
four_projected_landmarks_X=[X_Neck_superior(1);X_Neck_inferior(1);X_Neck_anterior(1);X_Neck_posterior(1)];
  
X = [ones(length(four_projected_landmarks_X),1) four_projected_landmarks_X];
b = X\(four_projected_landmarks_Y); % correlation equation

% crop DRR using the projected 2cm distal landmark
cropped_DRR_IMG=DRR_IMG(1:Y_two_cm_distal,:);
   
% crop DRR using the projected neck landmarks
for m=1:Y_two_cm_distal
      
  for i=1:length(DRR_IMG)  
    % create vectors 
     A=[ b(1) 0 1]; 
     B=[100*b(2)+b(1) 100 1];     
     P=[m,i,1];
     AB=B-A; AP=P-A;
   
     Cross_product=cross(AB,AP);
     Cross_product=Cross_product(:,3);
  
      % crop image using cross product
      if Cross_product>0
         cropped_DRR_IMG(m,i)=0;
      end
   end
end
  
%% Delete small islands and only select the largest island 
 stats=regionprops(cropped_DRR_IMG~=0, 'Area', 'PixelIdxList','Centroid');
 selected_DRR_label = zeros(size(cropped_DRR_IMG),'like',cropped_DRR_IMG);
 needed_pixels = false(size(cropped_DRR_IMG));
  [~, indx] = max([stats.Area]);
 needed_pixels(stats(indx).PixelIdxList) = true;    
 selected_DRR_label(needed_pixels) = 1; 
 cropped_DRR_IMG=selected_DRR_label.*cropped_DRR_IMG;