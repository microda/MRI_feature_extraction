% extracting ROI features of the ROI in a series of MRI images, for all of
% the registered sequences


function [ROI_features_all,all_ROI] = ROI_features_extract_main(ROIdata, all_mir, ProtocolNames)

    cprintf('text',     'Number of registered Sequences: %d\n', size(all_mir,4));
    for q=1:size(all_mir,4)
            mri=all_mir(:,:,:,q);
            cprintf('text',     '  Sequence: %d / %d. (ProtocolName: %s) \n', q, size(all_mir,4), ProtocolNames(q));
            cprintf('text',     'Extracting ROIs\n');
            %disp(['q=',num2str(q)])
            imNums=[ROIdata{q}.ImageNumber];
            for i=1:length(imNums)
                sliceNr=imNums(i);
                cprintf('text',     '  slice Number: %d / (from %d to %d)\n', sliceNr, min(imNums), max(imNums));
                im=mri (:, :, sliceNr);
                for ii=1:length(imNums)
                    if ROIdata{q}(ii).ImageNumber == sliceNr
                        ROItoPlot=ROIdata{q}(ii);
                    end
                end

                % extracting a cropped image of the ROI
                maskedImage = ROI_extract(im, ROItoPlot);

                if i==1
                    all_ROI_one=maskedImage;
                else
                    all_ROI_one=cat(3,all_ROI_one,maskedImage);
                end
            end

            % calculating the features of thr ROI
            cprintf('text',     '\nCalculating the features of the ROI \n\n');
            ROI_features=calc_ROI_features(all_ROI_one);

            if q==1
                all_ROI=all_ROI_one;
                ROI_features_all={ROI_features};
            else
                all_ROI=cat(4,all_ROI,all_ROI_one);
                ROI_features_all{q}=ROI_features;
            end
    end

end