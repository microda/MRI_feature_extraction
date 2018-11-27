% measuring features of a ROI for a 3D object. In other words we calculate
% the features on the whole tumor, instead of for each MRI slice


function [ROI_features] = calc_ROI_features(all_ROI_one)

    imbw=imbinarize(all_ROI_one); % binirazing the image
    im_label=bwconncomp(imbw); % labeling the image. bwconncomp can do it for 3D images
    %imshowpair(croppedImage,imbw,'montage')
    ROI_features=regionprops3(im_label,all_ROI_one,'Solidity', 'ConvexVolume', 'SurfaceArea', 'Volume', 'EquivDiameter', 'Extent', 'MaxIntensity', 'MeanIntensity', 'MinIntensity');
    
end

