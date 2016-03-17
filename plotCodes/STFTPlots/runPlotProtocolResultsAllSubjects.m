
clear all
close all
clc

[folderEEG,subjectNames,expDates,protocolNames,protocolTypes,gridType,folderSourceString,capMontage] = allDataLogsForAnalysisHumanEEG;

subjectNames = unique(subjectNames);
for subjectNum = 1:length(subjectNames)
    subjectName = subjectNames{subjectNum};
    runPlotProtocolResults(subjectName);
end