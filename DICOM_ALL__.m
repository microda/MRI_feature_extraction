%% running through the 3 registrations

% this function runs trough a folder containing all of the sequences from
% one patient, selects the ones used for the registration and does the
% further proccesing this these files/folders

function [habada] = DICOM_ALL__(info, folder, PatientsToAnalyze,results_dir)

%%
% check each folder inside the main folder (which contains all of the
% seuqences for a given patient). Only select the seqeunces used for the
% registation

%% First option: in case the patID is a number. else: in case patID is a string
if isinteger(PatientsToAnalyze{1})==1
    index=find(PatientsToAnalyze{1}==str2num(info.PatientID));
else
    index=find(contains(PatientsToAnalyze{1},info.PatientID));
end

for i=1:1:6
    sequences(i)=PatientsToAnalyze{i+5}(index);
end

% The sequence names used for the registation are read here.
sequences_selected=cellstr(strsplit(string(sequences(6)), ", "));
cprintf('text',    'Sequence(s): %s \n',string(sequences_selected));

% search the folders for the right sequences. 
folders = dir(folder);
folders = folders(~ismember({folders.name},{'.','..'}));
folders = folders(ismember([folders.isdir],1));
for i = 1:size(folders,1)
    folders=dir(fullfile(folders(i).folder,folders(i).name));
    folders=folders(~ismember({folders.name},{'.','..'}));
    info = dicominfo(string(fullfile(folders(1).folder, folders(1).name)));
    descr=info.SeriesDescription;
    for ii = 1:length(sequences_selected)
        if strcmpi(descr,string(sequences_selected{ii}))
            loc{ii}=char(fullfile(folders(1).folder));
            cprintf('text',    'Corresponding folder: %s \n',loc{ii});
        end
    end
    folders = dir(folder);
    folders = folders(~ismember({folders.name},{'.','..'}));
    folders = folders(ismember([folders.isdir],1));
end

% the description of the used mode in the DICOM file and the
% description of the file might differe slightly. In case there is no
% match, the user has to decide manually 

% TODO: a better semi-automatic solution. Cant use hamming distance:
% varible number of spaces in the name. Maybe: first remove all spaces,
% than compare the disance? 

if (exist ('loc')) == 0
    fprintf('The sequence name incoded in the DICOM seems to be different. Please varrify manually which one it is\n');
    overall=size(folders,1);
    
    for i = 1:size(folders,1)
        folders=dir(fullfile(folders(i).folder,folders(i).name));
        folders=folders(~ismember({folders.name},{'.','..'}));
        info = dicominfo(string(fullfile(folders(1).folder, folders(1).name)));
        descr=info.SeriesDescription;
        
       for ii = 1:size(sequences_selected,1)
           m= char(sequences_selected{ii});
           question=[num2str(i) '/' num2str(overall) '. DICOM info.SeriesDescription: ' descr '. Manual description: ', char(sequences_selected{ii}), '.'];
           answer = questdlg(question,'The sequence name incoded in the DICOM seems to be different. Please varrify manually which one it is', '                                           It is the same                                           ', 'It is not the same','def');
           if strcmp(answer,'                                           It is the same                                           ')
                loc{ii}=char(fullfile(folders(1).folder));
                cprintf('text',    'Corresponding folder: %s \n',loc{ii});
                break
           end
       end
        folders = dir(folder);
        folders = folders(~ismember({folders.name},{'.','..'}));
        folders = folders(ismember([folders.isdir],1));
    end
end


% ROI location
allXML=dir( fullfile(folder,'*.xml') );
realXML=allXML(~startsWith({allXML.name},"."));
xmlFile={};
for m=1:length(realXML)
    xmlFile{m}=fullfile(realXML(m).folder,realXML(m).name);
end

%% The following read the dicom files into matlab
% The produced result is: all_mir, which contains a 4 dim matrix. hight x length x depth x number of registraions done
for i=1:1:length(loc)
    cprintf('text',    'Reading DICOM files for all registrations: %d / %d ...',i, length(loc));
    [temp,ProtocolName,PatientID]=dicom_process(loc{i});
    cprintf('text',    '(%s) ... done\n',ProtocolName);
    if i==1
        all_mir=temp;
        ProtocolNames=string(ProtocolName);
    else
        % In case the registraion algorithm produces different sized results, they need to be adjusted. (here the righthand side of the picture is deleted) 
        if size(temp,2)~=size(all_mir,2)
           to_much=(size(temp,2)-size(all_mir,2));
           if to_much>0
               to_much=to_much-1;
               temp(:,end:-1:end-to_much,:)=[]; %deletion. Counting from the end. 
           else
               to_much=abs(to_much)-1;
               all_mir(:,end:-1:end-to_much,:,:)=[]; %deletion. Counting from the end.
           end
        end
        if size(temp,1)~=size(all_mir,1)
           to_much=(size(temp,1)-size(all_mir,1));
           if to_much>0
               to_much=to_much-1;
               temp(end:-1:end-to_much,:,:,:)=[]; %deletion. Counting from the end. 
           else
               to_much=abs(to_much)-1;
               all_mir(end:-1:end-to_much,:,:,:)=[]; %deletion. Counting from the end.
           end
        end
        all_mir=cat(4,all_mir,temp);
        ProtocolNames=[ProtocolNames ProtocolName];
    end
    %all_mir(:,:,:,i)=dicom_process(loc{i});
end
%fprintf('ProtocolNames : %s \n ',ProtocolNames);

% Now the ROIs are loaded. 
%%%%%%
for mm=1:length(xmlFile)
    fprintf('Parsing the XML file: %s \n',xmlFile{mm});
    ROIdata{mm}=parse_xml_roi(xmlFile{mm});
end
%%%%%
% Now you can view it using the dicom_view.m script


% For each slide in one given sequence is the image itself, together with the
% corresponding ROI is procceced using ROI_extract(). The results are
% concatinated into one 3D object. 
% all_ROI contains the ROIs. The fourth dimention are the different MRI modes (e.g. T1, T1KM, T2)


% Extracting ROI features. For plotting check plotting.m with all_ROI
% varible
%%%%%
[ROI_features_all,all_ROI]=ROI_features_extract_main(ROIdata, all_mir, ProtocolNames);
%% Using all_ROI you can create some nicelooing plots with plotting.m

%%
% concatinating the vectors
cv=compressFeatureVector(ROI_features_all,ProtocolNames,PatientID);
%%%%%

%% Writing the output

T=cv
cprintf('text',    'Writing the features into file\n');
writetable(T,fullfile(results_dir,['ROI_features_PatID_',info.PatientID]),'Delimiter','\t','WriteRowNames',true)
cprintf('text',    '################################\n\n');

end

   

