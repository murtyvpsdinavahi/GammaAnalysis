clear all
clc

lowGamma = [21 40];
highGamma = [41 70];
protocolType = 'CON';

for iRef = 1:2
    switch iRef
        case 1
            refChan = 'Bipolar';
        case 2
            refChan = 'SingleWire';
    end
tapers = [2 3];
BLPeriod = [-0.5 0];
STPeriod = [0.25 0.75];
    
[dataLogList.folderEEG,dataLogList.subjectNames,dataLogList.expDates,dataLogList.protocolNames,dataLogList.protocolTypes,...
    dataLogList.gridType,dataLogList.folderSourceString,dataLogList.capMontage] = allDataLogsForAnalysisHumanEEG;

subjectNamesUnique = unique(dataLogList.subjectNames);
for subjectNum = 1:(length(subjectNamesUnique))
% subjectNum = 8;
    subjectName = subjectNamesUnique{subjectNum};
    subjectIndices = find(strcmpi(dataLogList.subjectNames,subjectName));    
    protocolIndices = find(strcmpi(dataLogList.protocolTypes,protocolType));    
    dataLogIndex = intersect(subjectIndices,protocolIndices);
    
    if isempty(dataLogIndex); continue; end;
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
    
    compareGammaBandPowerPerProtocol(dataLog,lowGamma,highGamma,[],refChan,[],tapers,BLPeriod,STPeriod);
end

end