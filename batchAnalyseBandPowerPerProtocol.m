function batchAnalyseBandPowerPerProtocol(extractTheseIndices,AlphaBand,LGBand,HGBand,desiredBandWidth,EEGChannels,movingWin,Fs,tapers,BLPeriod,STPeriod)

if ~exist('AlphaBand','var')||isempty(AlphaBand); AlphaBand = [7 15]; end;
if ~exist('LGBand','var')||isempty(LGBand); LGBand = [21 50]; end;
if ~exist('HGBand','var')||isempty(HGBand); HGBand = [51 80]; end;
if ~exist('desiredBandWidth','var')||isempty(desiredBandWidth); desiredBandWidth = 20; else desiredBandWidth = (floor(desiredBandWidth/2))*2; end;
if ~exist('movingWin','var')||isempty(movingWin); movingWin = [0.4 0.01]; end;
if ~exist('tapers','var')||isempty(tapers); tapers = [2 3]; end;
if ~exist('BLPeriod','var')||isempty(BLPeriod); BLPeriod = [-0.5 0]; end;
if ~exist('STPeriod','var')||isempty(STPeriod); STPeriod = [0.25 0.75]; end;
    
[subjectNames,expDates,protocolNames] = allProtocolsHumanEEG;
gridType = 'EEG'; folderSourceString = 'D:';

totIndex = length(extractTheseIndices);
disp(['Starting batch extraction of band power per protocol. Total indices: ' num2str(totIndex)]);
for iV = 1:totIndex
    
    clear iIndex
    iIndex = extractTheseIndices(iV);

    clear subjectName expDate protocolName dataLog folderName folderExtract folderLFP
    subjectName = subjectNames{iIndex};
    expDate = expDates{iIndex};
    protocolName = protocolNames{iIndex};

    dataL{1,2} = subjectName;
    dataL{2,2} = gridType;
    dataL{3,2} = expDate;
    dataL{4,2} = protocolName;
    dataL{14,2} = folderSourceString;

    [~,folderName]=getFolderDetails(dataL);
    clear dataLog
    load(fullfile(folderName,'dataLog.mat'));
    
    if ~exist('EEGChannels','var')||isempty(EEGChannels); EEGChannels = dataLog{7, 2}; end;
    if ~exist('Fs','var')||isempty(Fs); Fs = dataLog{9, 2}; end;
    
    disp([char(10) 'Analysing index ' num2str(iV) ' of ' num2str(totIndex)]);
    disp(['Index no.: ' num2str(iIndex)]);
    disp([subjectName expDate protocolName]);
    
    disp('Bipolar Referencing...');
    compareBandPowerPerProtocol(dataLog,AlphaBand,LGBand,HGBand,desiredBandWidth,EEGChannels,'Bipolar',movingWin,Fs,tapers,BLPeriod,STPeriod);

    disp('Hemisphere Referencing...');
    compareBandPowerPerProtocol(dataLog,AlphaBand,LGBand,HGBand,desiredBandWidth,EEGChannels,'Hemisphere',movingWin,Fs,tapers,BLPeriod,STPeriod);
    
end

end