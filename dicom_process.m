% reading the dicom data into matlab structure

function [mri, ProtocolName, PatientID] = dicom_process(p)

% Set filename convention
fileFolder = fullfile(p);
files  = dir(char(fullfile(fileFolder,'*.dcm')));
if length(files)==0
    files  = dir(char(fullfile(fileFolder)));
    %get rid of the stuff that is not a part of the folder structure
    files=files(~ismember({files.name},{'.','..'})); 
end
fileNames  = {files.name};

% Getting the info
info = dicominfo(string(fullfile(fileFolder, fileNames{1})));
ProtocolName= info.SeriesDescription;
PatientID = info.PatientID;
lastNumber = info.InstanceNumber;

% Extract size info from metadata
voxel_size = [info.PixelSpacing; info.SliceThickness]';

% Read one file to get size
I         = dicomread(char(fullfile(fileFolder, fileNames{lastNumber})));
classI    = class(I);
sizeI     = size(I);
numImages = length(fileNames);

% create a visualization bar
hWaiBar = waitbar(0,'Reading DICOM files');

%Create array
%%Read space images; populate 3D matrix
mri = zeros(sizeI(1), sizeI(2), numImages, classI);
mri(:,:,lastNumber)  = double(I);
% remove the first file from the list. (TODO: check why?!)
fullLength=length(fileNames);
%%% fileNames(1)=[]; why!?

% putting the files in the folder in the right order. (aka sorting them)
% start with the first element in the folder
for i=1:1:length(fileNames)
     % read the next info and the Slice Number.
     info = dicominfo(string(fullfile(fileFolder, fileNames{i})));
     currentNumber = info.InstanceNumber;
     fname       = char(fullfile (fileFolder, fileNames{i}));
     mri(:,:,currentNumber)  = double(dicomread(fname));
     % updating the waitbar
     waitbar((length(fileNames)-i+1)/length(fileNames))
end

delete(hWaiBar)

end