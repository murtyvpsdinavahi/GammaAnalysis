clear all
clc

GammaBand = [21 80];
protocolType = 'SF';
refChan = 'Bipolar';
tapers = [2 3];
BLPeriod = [-0.5 0];
STPeriod = [0.25 0.75];
    
[dataLogList.folderEEG,dataLogList.subjectNames,dataLogList.expDates,dataLogList.protocolNames,dataLogList.protocolTypes,...
    dataLogList.gridType,dataLogList.folderSourceString,dataLogList.capMontage] = allDataLogsForAnalysisHumanEEG;

subjectNamesUnique = unique(dataLogList.subjectNames);
for subjectNum = 15;%8:(length(subjectNamesUnique)-1)
% subjectNum = 8;
    subjectName = subjectNamesUnique{subjectNum};
    subjectIndices = find(strcmpi(dataLogList.subjectNames,subjectName));    
    protocolIndices = find(strcmpi(dataLogList.protocolTypes,protocolType));
    dataLogIndex = intersect(subjectIndices,protocolIndices);
    
    % Get dataLog file
    clear subjectName expDate protocolName gridMontage
    subjectName = dataLogList.subjectNames{1,dataLogIndex};
    expDate = dataLogList.expDates{1,dataLogIndex};
    protocolName = dataLogList.protocolNames{1,dataLogIndex};
    gridMontage = dataLogList.capMontage{1,dataLogIndex};
    
    clear dataL folderName folderExtract
    dataL{1,2} = subjectName;
    dataL{2,2} = dataLogList.gridType;
    dataL{3,2} = expDate;
    dataL{4,2} = protocolName;
    dataL{14,2} = dataLogList.folderSourceString;

    [~,folderName]=getFolderDetails(dataL);
    clear dataLog
    load(fullfile(folderName,'dataLog.mat'));
    
    compareBandPowerPerProtocol4(dataLog,GammaBand,[],refChan,[],tapers,BLPeriod,STPeriod)
end