function runPlotProtocolResults(subjectName)
% Created by MD: 11/11/15

% Variables
% subjectName = 'AD';
movingWin = [0.4 0.01];
tapers = [2 3];
BLPeriod = [-0.5 0];
STPeriod = [0.25 0.75];
gammaBand = 'Low Gamma';
refChan = 'Bipolar';
numElec = 5;
gridType = 'EEG';
folderSourceString = 'D:';
desiredBandWidth = 20;

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
subjectIndices = find(strcmp(subjectName,dataLogList.subjectNames));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  figure  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figG = figure;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display main options
% fonts
fontSizeSmall = 10; fontSizeMedium = 12; fontSizeLarge = 16; fontSizeTiny = 8;
backgroundColor = 'w';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Panels
panelHeight = 0.16; panelGap = 0.02;
capPanelWidth = 0.14; capStartPos = panelGap;
plotPanelWidth = 0.14; plotStartPos = 1-panelGap-plotPanelWidth;
gridStartPos = panelGap*3 + capPanelWidth; gridWidth = 1-(gridStartPos+plotPanelWidth+3*panelGap);

% Topoplot panels
electrodeCapPosSF = [capStartPos 1-1*panelGap-1*panelHeight capPanelWidth panelHeight];
capSFHandle = subplot('Position',electrodeCapPosSF); axis off;

electrodeCapPosOri = [capStartPos 1-3*panelGap-2*panelHeight capPanelWidth panelHeight];
capOriHandle = subplot('Position',electrodeCapPosOri); axis off;

electrodeCapPosCon = [capStartPos 1-5*panelGap-3*panelHeight capPanelWidth panelHeight];
capConHandle = subplot('Position',electrodeCapPosCon); axis off;

electrodeCapPosSize = [capStartPos 1-7*panelGap-4*panelHeight capPanelWidth panelHeight];
capSizeHandle = subplot('Position',electrodeCapPosSize); axis off;

electrodeCapPosTF = [capStartPos 1-9*panelGap-5*panelHeight capPanelWidth panelHeight];
capTFHandle = subplot('Position',electrodeCapPosTF); axis off;

% Grid panels
gridPosSF = [gridStartPos 1-1*panelGap-1*panelHeight gridWidth panelHeight];
gridPosOri = [gridStartPos 1-3*panelGap-2*panelHeight gridWidth panelHeight];
gridPosCon = [gridStartPos 1-5*panelGap-3*panelHeight gridWidth panelHeight];
gridPosSize = [gridStartPos 1-7*panelGap-4*panelHeight gridWidth panelHeight];
gridPosTF = [gridStartPos 1-9*panelGap-5*panelHeight gridWidth panelHeight];

% Plot panels
plotPosSF = [plotStartPos 1-1*panelGap-1*panelHeight plotPanelWidth panelHeight];
plotSFHandle = subplot('Position',plotPosSF); axis off;

plotPosOri = [plotStartPos 1-3*panelGap-2*panelHeight plotPanelWidth panelHeight];
plotOriHandle = subplot('Position',plotPosOri); axis off;

plotPosCon = [plotStartPos 1-5*panelGap-3*panelHeight plotPanelWidth panelHeight];
plotConHandle = subplot('Position',plotPosCon); axis off;

plotPosSize = [plotStartPos 1-7*panelGap-4*panelHeight plotPanelWidth panelHeight];
plotSizeHandle = subplot('Position',plotPosSize); axis off;

plotPosTF = [plotStartPos 1-9*panelGap-5*panelHeight plotPanelWidth panelHeight];
plotTFHandle = subplot('Position',plotPosTF); axis off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SF Plot
plotHandles.topo = capSFHandle;
plotHandles.gridPos = gridPosSF;
plotHandles.plot = plotSFHandle;
protocolType = 'SF';
plotProtocolResults(dataLogList,subjectIndices,protocolType,'Ori',plotHandles,refChan,numElec,gammaBand,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORI Plot
plotHandles.topo = capOriHandle;
plotHandles.gridPos = gridPosOri;
plotHandles.plot = plotOriHandle;
protocolType = 'Ori';
plotProtocolResults(dataLogList,subjectIndices,protocolType,'none',plotHandles,refChan,numElec,gammaBand,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth)
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CON Plot
plotHandles.topo = capConHandle;
plotHandles.gridPos = gridPosCon;
plotHandles.plot = plotConHandle;
protocolType = 'Con';
plotProtocolResults(dataLogList,subjectIndices,protocolType,'none',plotHandles,refChan,numElec,gammaBand,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SIZE Plot
plotHandles.topo = capSizeHandle;
plotHandles.gridPos = gridPosSize;
plotHandles.plot = plotSizeHandle;
protocolType = 'Size';
plotProtocolResults(dataLogList,subjectIndices,protocolType,'none',plotHandles,refChan,numElec,gammaBand,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TF Plot
plotHandles.topo = capTFHandle;
plotHandles.gridPos = gridPosTF;
plotHandles.plot = plotTFHandle;
protocolType = 'TFDF'; % For Drifting gratings
plotProtocolResults(dataLogList,subjectIndices,protocolType,'none',plotHandles,refChan,numElec,gammaBand,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

savefig(figG,fullfile(pwd,'Plots','VisualGammaProject','SubjectWise',subjectName,[subjectName '.fig']));
close(figG);
clear figG;

end
