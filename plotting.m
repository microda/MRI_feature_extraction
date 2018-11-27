% plotting the ROIs. This file can be used with a variable all_ROI, which
% is created by ROI_features_extract_main.m
% Deppending on the desired output the parameters can be adjusted.

load mri;

% selecting the registered sequence for ROIs, which should be plotted. 
ROI_for_plotting=all_ROI(:,:,:,1);
%

D = squeeze(ROI_for_plotting);
cm = brighten(jet(length(map)),-.5);
colormap(cm);
D_size=size(ROI_for_plotting,3)
contourslice(D,[],[],[1:D_size],8);
view(3);
axis tight


figure
colormap(map)
D = smooth3(D);
%hiso = patch(isosurface(D,5),...
%   'FaceColor',[1,.75,.65],...
%   'EdgeColor','none');

p1 = patch(isosurface(D, 5),'FaceColor',[1,.75,.65],...
	'EdgeColor','none');
isonormals(D,p1)

p2 = patch(isocaps(D, 5),'FaceColor','interp',...
	'EdgeColor','none');
view(3)
axis tight
daspect([1,1,.4])
colormap(gray(100))
camlight left
camlight
lighting gouraud
lightangle(45,30);
lighting gouraud
p2.AmbientStrength = 0.6;
p1.SpecularColorReflectance = 0;
p1.SpecularExponent = 50;
isonormals(D,p1)