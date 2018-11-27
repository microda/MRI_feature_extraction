% this function gets a grayscale Image (e.g. MRI) and the ROI coordinates for
% the given image (e.g. Tumor ROI) and returns the table with the grayscale
% values in the ROI (it crops the Image to the ROI, creating a mask around it)


    
function [maskedImage] = ROI_extract(im, ROItoPlot)
    
    a = ROItoPlot.Position;
    % define small function handle with a Variable-length input argument list
    sq = @(varargin) varargin;
    
    %show the image
    imp = imshow(im, 'DisplayRange', []);
    % Puts up an ROI as a mask and crops the image to the ROI.
    aa=transpose(cell2mat([sq(a.X);sq(a.Y)]));
    hold on
    h = impoly(gca, aa);
    hold off
    drawnow
    maskImage = h.createMask();
    % Mask the image with the ellipse.
    maskedImage = im .* cast(maskImage, class(im));
    % Find the bounding box
    column1 = find(sum(maskImage, 1), 1, 'first');
    column2 = find(sum(maskImage, 1), 1, 'last');
    row1 = find(sum(maskImage, 2), 1, 'first');
    row2 = find(sum(maskImage, 2), 1, 'last');
    croppedImage = maskedImage(row1:row2, column1:column2);
    %ci=imshow(croppedImage, []);
    %imp = imshow(im, 'DisplayRange', []);      
end



