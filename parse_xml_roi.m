% Run xml2struct and extract the positions in pixels together with the
% corresponding picture ImageIndex. 
% the produced structure is ROIdata(NumberOfROI).ImagaNumber   (Number of the pictures of these ROIs)
% ...NumOfPoints (Number of POints in this ROI), ...Postion(For Each POINT
% in the ROI).X and .Y positions.


function [ROIdata] = parse_xml_roi(xmlFile)
%hWaiBar = waitbar(0,'Reading and parsing the XML file');

% the main waiting accures during xml2struct. TODO: check where to put a
% waitbar
s=xml2struct(xmlFile);

%numOfROIs=(length(s(2).Children(2).Children(4).Children)-1)./2;
numOfROIs=length(s.plist{2}.dict.array.dict);

for i=1:numOfROIs
    %ROIdata(i).ImageNumber=double(string(s(2).Children(2).Children(4).Children(i*2).Children(8).Children.Data));
    ROIdata(i).ImageNumber=double(string(s.plist{2}.dict.array.dict{i}.integer{2}.Text))+1;
    %ROIdata(i).NumOfPoints=(length(s(2).Children(2).Children(4).Children(i*2).Children(24).Children(2).Children(56).Children)-1)./2;
    ROIdata(i).NumOfPoints=double(string(s.plist{2}.dict.array.dict{i}.array.dict.integer{2}.Text));
    for ii=1:ROIdata(i).NumOfPoints
        %hab = string(s(2).Children(2).Children(4).Children(i*2).Children(24).Children(2).Children(56).Children(ii*2).Children.Data);
        hab = string(s.plist{2}.dict.array.dict{i}.array.dict.array{2}.string{ii}.Text);
        hab = strrep(strrep(hab,'(',''),')',''); % removing the bracketts
        hab = textscan( hab, '%f', 'Delimiter',',' ); % casting the string values to nummerical
        hab = permute( hab{1}, [2,1] );
        ROIdata(i).Position(ii).X = hab(1);
        ROIdata(i).Position(ii).Y = hab(2);
    end
    %waitbar((length(numOfROIs)-i+1)/length(numOfROIs))
end

%delete(hWaiBar)
cprintf('text',    'ROI data parsed successfully. \n  Number of processed pictures: %d \n',length(ROIdata));
end

