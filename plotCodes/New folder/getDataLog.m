function dataLog = getDataLog(dataLogList,subjectName,protocolType)
    
    subjectIndices = find(strcmpi(dataLogList.subjectNames,subjectName));    
    protocolIndices = find(strcmpi(dataLogList.protocolTypes,protocolType));
    dataLogIndex = intersect(subjectIndices,protocolIndices);
    
    % Get dataLog file
    clear subjectName expDate protocolName gridMontage
    subjectName = dataLogList.subjectNames{1,dataLogIndex};
    expDate = dataLogList.expDates{1,dataLogIndex};
    protocolName = dataLogList.protocolNames{1,dataLogIndex};

    dataLog{1,2} = subjectName;
    dataLog{2,2} = dataLogList.gridType;
    dataLog{3,2} = expDate;
    dataLog{4,2} = protocolName;
    dataLog{14,2} = dataLogList.folderSourceString;

    [~,folderName]=getFolderDetails(dataLog);
    clear dataLog
    load(fullfile(folderName,'dataLog.mat'));
end