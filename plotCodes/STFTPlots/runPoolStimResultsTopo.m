% runPoolStimResultsTopo
% Created by MD: 01/02/16

clear; clc;

% Variables
subjectName = {'AB','AD','AV','GR','NC','PJ','PM','RS','SB','SM','SO','VV'};
% subjectToPlotTopo = 'VV';
% freqBands = {'Alpha';'Low Gamma';'High Gamma'};
freqBands = {'LGamma','TGamma'};
refChan = 'Bipolar';


[dataLogList.folderEEG,dataLogList.subjectNames,dataLogList.expDates,dataLogList.protocolNames,dataLogList.protocolTypes,...
    dataLogList.gridType,dataLogList.folderSourceString,dataLogList.capMontage] = allDataLogsForAnalysisHumanEEG;
subjectNames = dataLogList.subjectNames;
subjectNum = length(subjectName);
subjectIndices = [];
for sub = 1:subjectNum
    subjectIndex = find(strcmp(subjectName(sub),subjectNames));
    subjectIndices = union(subjectIndex,subjectIndices);
end

protocolType = 'CON';
% poolStimResultsTopo(dataLogList,protocolType,subjectIndices,freqBands,refChan);

AllSubAnalysis(dataLogList,protocolType,subjectIndices,freqBands,refChan);