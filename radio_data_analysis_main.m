%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%            --------Wrapper for the Radio Data analysis-------
% 
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all;
%% tf is one for Windows, 0 for else
tf = ispc;
%%

format compact

% Please be sure to define the folders. Watch out for Windows/Linux paths
% differences. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
main_dir='/Volumes/ELEMENTS/Documents/NCT Data/Radiologie BM_Pat/';
results_dir='/Users/ivankel/Dropbox/Zweitstudium_Medizin/Hiwi/NCT/Neural network/Results/';
suppl_scripts='/Users/ivankel/Dropbox/Zweitstudium_Medizin/Hiwi/NCT/Neural network/Bin/';

% be sure to define the name of the file with the table of annotated
% RadioIDs
Rad_ID_list='Rad_IDs_for_analysis_for_testing2.txt';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% in case you have a windows system, the paths are modified.
if ispc
     extra='E:\';
     main_dir =  strrep(strrep(main_dir,'/','\'),'\Volumes\ELEMENTS\',extra);
     results_dir = 'C:\Users\Unodue\Dropbox\Zweitstudium_Medizin\Hiwi\NCT\Neural network\Results\';
     suppl_scripts='C:\Users\Unodue\Dropbox\Zweitstudium_Medizin\Hiwi\NCT\Neural network\Bin\';
end
%

%% reading the list of Patients Radio-IDs, which have been annotated
%good_Radio_IDs = sort(textread(fullfile(main_dir, '..','Rad_IDs_for_analysis.txt')))
fileID = fopen(fullfile(main_dir, '..',Rad_ID_list));
if fileID == -1
    fileID = fopen(fullfile(main_dir, '../..',Rad_ID_list));
end

% adding xml2struct and cprintf to the path
addpath(fullfile(suppl_scripts,'xml2struct'))
addpath(fullfile(suppl_scripts,'cprintf'))
%

PatientsToAnalyze = textscan(fileID,'%d %s %d %d %d %s %s %s %s %s %s','Delimiter','\t','EmptyValue',NaN);
if length(PatientsToAnalyze{1}) == 0
    PatientsToAnalyze = textscan(fileID,'%s %s %d %d %d %s %s %s %s %s %s','Delimiter','\t','EmptyValue',NaN);
end
fclose(fileID);

%
good_Radio_IDs=PatientsToAnalyze{1};

% Hello world.
cprintf('text',    '#################################### \n');
cprintf('*blue',     '     Analyzing %d RadiIDs: \n', length(good_Radio_IDs));
cprintf('text',    '#################################### \n');
% Set directory
% Set filename convention
folders = dir(main_dir);
folders= folders(~ismember({folders.name},{'.','..'}));
%select only folders, leave out the files
k=find(~cat(2,folders.isdir));
folders= folders(~ismember({folders.name},{folders(k).name}));
%

count=0;
for i = 1:size(folders,1)
        
    
        %% the folder we look at is adjusted according to i
        %
        folders=dir(fullfile(folders(i).folder,folders(i).name));
        folders=folders(~ismember({folders.name},{'.','..'}));
        %
        
        %% Go as deep as possible in the currect folder, until you find a dcm file
        %
        while any(cat(2,folders.isdir))
            index_all=find(cat(2,folders.isdir));
            folders=dir(fullfile(folders(index_all(1)).folder,folders(index_all(1)).name));
            folders=folders(~ismember({folders.name},{'.','..'}));
        end
        f_check=dir(folders(1).folder);
        f_check=f_check(~ismember({f_check.name},{'.','..'}));
        %
        
        %% update the path
        %
        folders = dir(main_dir);
        folders= folders(~ismember({folders.name},{'.','..'}));
        %select only folders, leave out the files
        k=find(~cat(2,folders.isdir));
        folders= folders(~ismember({folders.name},{folders(k).name}));
        %
        
        %% check if the PatienID is in the preselected list
        %
        info = dicominfo(string(fullfile(f_check(1).folder, f_check(1).name)));
        Pat_ID = info.PatientID;
        try 
            c=ismember(str2num(Pat_ID),good_Radio_IDs);
        catch
            c=ismember(Pat_ID,good_Radio_IDs);
        end
        if c == 1
           count=count+1;
           cprintf('key',     '\n\n\nProccesing %d / %d  \n',count, length(good_Radio_IDs));
           fprintf('Analysing MRI data from patient (Radio_ID) : %s \n\n',Pat_ID);
           % usefull in case of debugging
           %disp(f_check(1))
           %if str2num(Pat_ID) ~= 93
           %     disp(habad)
           %end
           folder=fullfile(f_check(1).folder, '..');
           %% Running the analysis of the dicoms in the given folder
           % 
           DICOM_ALL__(info, fullfile(f_check(1).folder, '..'),PatientsToAnalyze,results_dir);
           
        end
end