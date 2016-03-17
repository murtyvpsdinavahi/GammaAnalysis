
clear all
clc

[dataLogList.folderEEG,dataLogList.subjectNames,dataLogList.expDates,dataLogList.protocolNames,dataLogList.protocolTypes,...
    dataLogList.gridType,dataLogList.folderSourceString,dataLogList.capMontage] = allDataLogsForAnalysisVisualGammaEEG;

subjectNamesUnique = unique(dataLogList.subjectNames);

for subjectNum = 1:length(subjectNamesUnique)
    
    subjectName = subjectNamesUnique{subjectNum};
    subjectIndices = find(strcmpi(dataLogList.subjectNames,subjectName));    
    protocolIndices = find(strcmpi(dataLogList.protocolTypes,'SIZE'));    
    dataLogIndex = intersect(subjectIndices,protocolIndices);    

    % Get dataLog file
    if ~isempty(dataLogIndex)
        subjectName = dataLogList.subjectNames{1,dataLogIndex};
        expDate = dataLogList.expDates{1,dataLogIndex};
        protocolName = dataLogList.protocolNames{1,dataLogIndex};
        gridMontage = dataLogList.capMontage{1,dataLogIndex};

        dataL{1,2} = subjectName;
        dataL{2,2} = dataLogList.gridType;
        dataL{3,2} = expDate;
        dataL{4,2} = protocolName;
        dataL{14,2} = dataLogList.folderSourceString;

        [~,folderName]=getFolderDetails(dataL);
        clear dataLog
        load(fullfile(folderName,'dataLog.mat'));
        folderExtract = fullfile(folderName,'extractedData');
        [~,aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,cValsUnique,tValsUnique,aaValsUnique,...
            aeValsUnique,asValsUnique,aoValsUnique,avValsUnique,atValsUnique] = loadParameterCombinations(folderExtract);
        
        bestStimulus(subjectNum).subjectName = subjectName;
        
        bestStimulus(subjectNum).Azimuth = aValsUnique;
        bestStimulus(subjectNum).Elevation = eValsUnique;
        bestStimulus(subjectNum).Size = sValsUnique(end);
        bestStimulus(subjectNum).SF = fValsUnique;
        bestStimulus(subjectNum).Orientation = oValsUnique;
        bestStimulus(subjectNum).Contrast = cValsUnique;
        bestStimulus(subjectNum).TF = tValsUnique;
        bestStimulus(subjectNum).AudAzi = aaValsUnique;
        bestStimulus(subjectNum).AudElev = aeValsUnique;
        bestStimulus(subjectNum).RippleFreq = asValsUnique;
        bestStimulus(subjectNum).RipplePhase = aoValsUnique;
        bestStimulus(subjectNum).Volume = avValsUnique;
        bestStimulus(subjectNum).RippleVel = atValsUnique;
        
    end   

    save(fullfile('D:','Plots','bestStimulus.mat'),'bestStimulus');
end

