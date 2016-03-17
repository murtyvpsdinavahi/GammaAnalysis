

clear plotData Data
[~,folderName]=getFolderDetails(dataLog);
folderSegment = fullfile(folderName,'segmentedData');
folderLFP = fullfile(folderSegment,'LFP');
[~,timeVals] = loadlfpInfo(folderLFP);

a = 1; e = 1; s = 7; f = 1; o = 1; c = 1; t = 1; aa = 1; ae = 1; as = 1; ao = 1; av = 1; at = 1; 

[plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,[1:64]);                                                        
[Data,goodPos] = bipolarRef(plotData,'Bipolar','actiCap64',trialNums,allBadTrials);

% if ~exist('AlphaBand','var')||isempty(AlphaBand); AlphaBand = [7 15]; end;
% if ~exist('LGBand','var')||isempty(LGBand); LGBand = [21 50]; end;
% if ~exist('HGBand','var')||isempty(HGBand); HGBand = [51 80]; end;
% if ~exist('desiredBandWidth','var')||isempty(desiredBandWidth); desiredBandWidth = 20; else desiredBandWidth = (ceil(desiredBandWidth/2))*2; end;
% if ~exist('EEGChannels','var')||isempty(EEGChannels); EEGChannels = dataLog{7, 2}; end;
% if ~exist('refChan','var')||isempty(refChan); refChan = 'Bipolar'; end;

if ~exist('movingWin','var')||isempty(movingWin); movingWin = [0.4 0.01]; end;
if ~exist('Fs','var')||isempty(Fs); Fs = dataLog{9, 2}; end;
if ~exist('tapers','var')||isempty(tapers); tapers = [2 3]; end;
if ~exist('BLPeriod','var')||isempty(BLPeriod); BLPeriod = [-0.5 0]; end;
if ~exist('STPeriod','var')||isempty(STPeriod); STPeriod = [0.25 0.75]; end;

mtmParams.Fs = Fs;
mtmParams.tapers = tapers;
mtmParams.trialave=0;
mtmParams.err=0;
mtmParams.pad=-1;

BLMin = BLPeriod(1);
BLMax = BLPeriod(2);
STMin = STPeriod(1);
STMax = STPeriod(2);

% fBandMinAlpha = AlphaBand(1);
% fBandMaxAlpha = AlphaBand(2);
% fBandMinLG = LGBand(1);
% fBandMaxLG = LGBand(2);
% fBandMinHG = HGBand(1);    
% fBandMaxHG = HGBand(2);
    
clear dSPower
hPD = waitbar(0,['Analysing electrode 1 of ' num2str(size(Data,1)) ' electrodes...']);
for i=1:size(Data,1)
    waitbar((i/size(Data,1)),hPD,['Analysing electrode ' num2str(i) ' of ' num2str(size(Data,1)) ' electrodes...']);
    dataTF=Data(i,goodPos{i},:);
    dataTF=squeeze(dataTF);                    

    [~,dS1,t2,f2] = getSTFT(dataTF,movingWin,mtmParams,timeVals,BLMin,BLMax);
    dSPower(i,:,:) = dS1';
end        
close(hPD);
clear hPD;

eegData.dimord = 'chan_freq_time';
eegData.powspctrm = dSPower;
eegData.time = t2;
eegData.freq = f2;

load('C:\Users\LabComputer6\Documents\MATLAB\Montages\bipolarChanlocsActiCap64.mat')
for iChannel = 1:109; %size(Data,1)
%     eegData.label{iChannel} = num2str(iChannel);
    eegSensor.label{iChannel,1} = num2str(iChannel);
    eegSensor.chanpos(iChannel,:) = squeeze([eloc(iChannel).X eloc(iChannel).Y eloc(iChannel).Z]);
    eegSensor.chantype{iChannel,1} = 'EEG';
end

% spm_eeg_ft2spm(eegData,'Hello');

D = spm_eeg_load('Hello');
D = D.sensors('EEG',eegSensor);


