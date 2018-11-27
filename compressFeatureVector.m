% Compresses a cell array of feature vectors from one patient (with e.g. 3 different MRI sequences) into one vector. 
% Renames the columns according to the used sequence.

function featureVecOut = compressFeatureVector(featureVecIn,ProtocolNames,PatientID)

        ProtocolNames = regexprep(ProtocolNames,' |/','_' );
        for i = 1:numel(featureVecIn)
            
            currVec = featureVecIn{i};
            
            %adding the PatientIDs and ProtocolName
            s=table(string(ProtocolNames{i}));
            s.Properties.VariableNames{1}='ProtocolName';
            currVec=[s currVec];
            s=table(str2num(PatientID));
            if size(s,1)==0 % for TCGA data
                s=table(string(PatientID));
            end
            s.Properties.VariableNames{1}='PatientID';
            currVec=[s currVec];            
            
            
            
            
            if i==1
                allVec =  currVec;
            else
                allVec = vertcat(allVec,currVec);
            end
            
        end
        
        
        
        featureVecOut =allVec;
end