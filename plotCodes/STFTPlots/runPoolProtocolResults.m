% runPoolProtocolResults
% Created by MD: 12/11/15

clear; clc;

% Variables
subjectName = {'GR';'VV';'RS';'AD'};
subjectToPlotTopo = 'VV';
freqBands = {'Alpha';'Low Gamma';'High Gamma'};
refChan = 'Bipolar';
desiredBandWidth = 20;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
movingWin = [0.4 0.01];
tapers = [2 3];
BLPeriod = [-0.5 0];
STPeriod = [0.25 0.75];
numElec = 5;
gridMontage = 'actiCap64';
lineSpecifiers = {'+';'*';'.';'x';'s';'d';'^';'v';'>';'<';'p';'h'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mtmParams.tapers = tapers;
mtmParams.trialave=0;
mtmParams.err=0;
mtmParams.pad=-1;

BLMin = BLPeriod(1);
BLMax = BLPeriod(2);

STMin = STPeriod(1);
STMax = STPeriod(2);   

[dataLogList.folderEEG,dataLogList.subjectNames,dataLogList.expDates,dataLogList.protocolNames,dataLogList.protocolTypes,...
    dataLogList.gridType,dataLogList.folderSourceString,dataLogList.capMontage] = allDataLogsForAnalysisHumanEEG;
subjectNames = dataLogList.subjectNames;
subjectNum = length(subjectName);
subjectIndices = [];
for sub = 1:subjectNum
    subjectIndex = find(strcmp(subjectName(sub),subjectNames));
    subjectIndices = union(subjectIndex,subjectIndices);
end

% SF Plot
protocolType = 'SF';
poolProtocolResults(dataLogList,subjectIndices,protocolType,'ori',subjectToPlotTopo,refChan,numElec,freqBands,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth,lineSpecifiers)

% ORI Plot
protocolType = 'ori';
poolProtocolResults(dataLogList,subjectIndices,protocolType,'none',subjectToPlotTopo,refChan,numElec,freqBands,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth,lineSpecifiers)

% Con Plot
protocolType = 'con';
poolProtocolResults(dataLogList,subjectIndices,protocolType,'none',subjectToPlotTopo,refChan,numElec,freqBands,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth,lineSpecifiers)

% Size Plot
protocolType = 'size';
poolProtocolResults(dataLogList,subjectIndices,protocolType,'none',subjectToPlotTopo,refChan,numElec,freqBands,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth,lineSpecifiers)

% TFDF Plot
protocolType = 'tfdf';
poolProtocolResults(dataLogList,subjectIndices,protocolType,'none',subjectToPlotTopo,refChan,numElec,freqBands,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth,lineSpecifiers)

% TFCP Plot
protocolType = 'tfcp';
poolProtocolResults(dataLogList,subjectIndices,protocolType,'none',subjectToPlotTopo,refChan,numElec,freqBands,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth,lineSpecifiers)

