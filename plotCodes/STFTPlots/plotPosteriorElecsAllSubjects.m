
clear 
clc
% EEGChannelsLeft = [81,90,82,91,83,92,84];
% EEGChannelsRight = [89 96 88  95 87 94 86];
% EEGChannelsCentre = [85 93];

% EEGChannelsLeft = [70:74 81:84 90:92];
% EEGChannelsRight = [76:80 86:89 94:96];
% EEGChannelsCentre = [75 85 93];

EEGChannelsLeft = [17 18 19 23 24 28 29 51 52 56 57 60 61];
EEGChannelsRight = [20 21 22 26 27 31 32 54 55 58 59 63 64];
EEGChannelsCentre = [53 25 62 30];

% EEGChannelsLeft = [82 83 84 91 92];
% EEGChannelsRight = [86 87 88 94 95];
% EEGChannelsCentre = [85 93];

% EEGChannelsLeft = [24 29 56 57 61 60];
% EEGChannelsRight = [26 31 58 59 63 64];
% EEGChannelsCentre = [25 30 62];

saveFlag = 1;

freqBandTopo = 'AllGamma';
freqBandToPlot = [21 70];
protocolType = 'CON';
refChan = 'Bipolar';
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
    
    plotMTFFTPerProtocol(dataLog,{{EEGChannelsLeft};{EEGChannelsRight};{EEGChannelsCentre}},freqBandToPlot,[],refChan,saveFlag,averageAllElecFlag,[],BLPeriod,STPeriod,tapers);
end
    
%     plotTopoplotsPerProtocol(dataLog,'AllGamma',refChan);
%     plotTopoplotsPerProtocol(dataLog,'LGamma',refChan);
%     plotTopoplotsPerProtocol(dataLog,'HGamma',refChan);
    
%     plotMTFFTPerProtocol(dataLog,EEGChannelsCentre,freqBandToPlot,refChan,BLPeriod,STPeriod,tapers);    
%     plotMTFFTPerProtocol(dataLog,EEGChannelsRight,freqBandToPlot,refChan,BLPeriod,STPeriod,tapers);
%     plotMTFFTPerProtocol(dataLog,EEGChennelsCentre,freqBandToPlot,refChan,BLPeriod,STPeriod,tapers);

% plotMTFFTPerProtocol(dataLog,{{EEGChannelsLeft};{EEGChannelsRight};{EEGChannelsCentre}},[],[],'SingleWire',0,0);
% plotMTFFTPerProtocol(dataLog,{{63}},[],{'HGamma'},'SingleWire',0,0);
% plotMTFFTPerProtocol(dataLog,{{83}},[],[],'Bipolar',0,0);
% plotPos = plotMTFFTPerProtocol(dataLog,{{EEGChannelsRight}},[],[],'Bipolar',0,0); plotPos = plotMTFFTPerProtocol(dataLog,{{EEGChannelsRight}},[],[],'Bipolar',0,1,plotPos);

% plotTopoplotsPerProtocol(dataLog,'HGamma','SingleWire');
