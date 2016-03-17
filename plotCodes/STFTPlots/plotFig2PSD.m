
clear all
clc

protocolType = 'ORI';
refChan = 'Bipolar';
movingWin = [0.4 0.01];

if ~exist('BLPeriod','var')||isempty(BLPeriod); BLPeriod = [-0.5 0]; end;
if ~exist('STPeriod','var')||isempty(STPeriod); STPeriod = [0.25 0.75]; end;
    
BLMin = BLPeriod(1);
BLMax = BLPeriod(2);
STMin = STPeriod(1);
STMax = STPeriod(2);
    
[dataLogList.folderEEG,dataLogList.subjectNames,dataLogList.expDates,dataLogList.protocolNames,dataLogList.protocolTypes,...
    dataLogList.gridType,dataLogList.folderSourceString,dataLogList.capMontage] = allDataLogsForAnalysisHumanEEG;

subjectNamesUnique = unique(dataLogList.subjectNames);

totLen = length(subjectNamesUnique);
if isprime(totLen);
    xNum = max(factor(totLen+1));
else
    xNum = max(factor(totLen));
end
% xNum = max(factor(totLen));
yNum = ceil(totLen/xNum);
if yNum < 4; tNum = yNum; yNum = xNum; xNum = tNum; end

figG = figure(15668); set(figG,'numbertitle', 'off','name','PSD across subjects');
figH = figure(15698); set(figG,'numbertitle', 'off','name','topoplots');

tfNum = 1;
for subjectNum = [2 4:12 15 16];%1:length(subjectNamesUnique)
%     subjectNum = 3;
% if ((subjectNum == 1) || (subjectNum == 8) || (subjectNum == 11)); continue; end;
    subjectName = subjectNamesUnique{subjectNum};
    subjectIndices = find(strcmpi(dataLogList.subjectNames,subjectName));    
    protocolIndices = find(strcmpi(dataLogList.protocolTypes,protocolType));
    SFProtocolIndices = find(strcmpi(dataLogList.protocolTypes,'SF'));
    dataLogIndex = intersect(subjectIndices,protocolIndices);
    SFdataLogIndex = intersect(subjectIndices,SFProtocolIndices);

    % Get dataLog file
    if ~isempty(dataLogIndex)
        subjectName = dataLogList.subjectNames{1,dataLogIndex};
        expDate = dataLogList.expDates{1,dataLogIndex};
        protocolName = dataLogList.protocolNames{1,dataLogIndex};
        gridMontage = dataLogList.capMontage{1,dataLogIndex};

        dataL{1,2} = subjectName;
        dataL{2,2} = dataLogList.gridType;
        dataL{3,2} = expDate;
        dataL{4,2} = protocolName;
        dataL{14,2} = dataLogList.folderSourceString;

        [~,folderName]=getFolderDetails(dataL);
        clear dataLog
        load(fullfile(folderName,'dataLog.mat'));
        folderExtract = fullfile(folderName,'extractedData');
        [~,~,~,~,sfVal] = loadParameterCombinations(folderExtract);
    end

    % Get SF dataLog file
    clear subjectName expDate protocolName gridMontage
    subjectName = dataLogList.subjectNames{1,SFdataLogIndex};
    expDate = dataLogList.expDates{1,SFdataLogIndex};
    protocolName = dataLogList.protocolNames{1,SFdataLogIndex};
    gridMontage = dataLogList.capMontage{1,SFdataLogIndex};

    clear dataL folderName folderExtract
    dataL{1,2} = subjectName;
    dataL{2,2} = dataLogList.gridType;
    dataL{3,2} = expDate;
    dataL{4,2} = protocolName;
    dataL{14,2} = dataLogList.folderSourceString;

    [~,folderName]=getFolderDetails(dataL);
    clear dataLog
    load(fullfile(folderName,'dataLog.mat'));

    Fs = dataLog{9, 2};
    if ~exist('tapers','var')||isempty(tapers); tapers = [2 3]; end;

    mtmParams.Fs = Fs;
    mtmParams.tapers = tapers;
    mtmParams.trialave=1;
    mtmParams.err=0;
    mtmParams.pad=-1;
    mtmParams.fpass = [0 500];

    % Load parameter combinations and timeVals
    folderExtract = fullfile(folderName,'extractedData');
    folderSegment = fullfile(folderName,'segmentedData');
    folderLFP = fullfile(folderSegment,'LFP');
    [~,~,~,~,fValsUnique,oValsUnique] = loadParameterCombinations(folderExtract);
    [~,timeVals] = loadlfpInfo(folderLFP);
    load(fullfile(folderName,['gammaDataAllElec_' refChan '.mat']));

    switch refChan
        case 'Bipolar'
            refType = 4;
            noseDir = '-Y';
        case 'Hemisphere'
            refType = 2;
            noseDir = '+X';
    end
    chanlocs = loadChanLocs(gridMontage,refType);

    if ~isempty(dataLogIndex)
        sfValsIndex = find(int8(fValsUnique*10) == int8(sfVal*10));
    else
        sfValsIndex = 1:length(fValsUnique);
    end

    a = 1; e = 1; s = 1; c = 1; t = 1; aa = 1; ae = 1; as = 1; ao = 1; av = 1; at = 1;

    oLoop = 1;
    for f = sfValsIndex
        for o = 1:length(oValsUnique)
    %         o = 2;
            combMat = [gammaDataAllElec.a; gammaDataAllElec.e; gammaDataAllElec.s; gammaDataAllElec.f; gammaDataAllElec.o; gammaDataAllElec.c; gammaDataAllElec.t;...
                gammaDataAllElec.aa; gammaDataAllElec.ae; gammaDataAllElec.as; gammaDataAllElec.ao; gammaDataAllElec.av; gammaDataAllElec.at];
            combMat = combMat';
            index = multiIntersect(find(combMat(:,1) == a), find(combMat(:,2) == e), find(combMat(:,3) == s),...
                    find(combMat(:,4) == f), find(combMat(:,5) == o), find(combMat(:,6) == c), find(combMat(:,7) == t),...
                    find(combMat(:,8) == aa), find(combMat(:,9) == ae), find(combMat(:,10) == as),...
                    find(combMat(:,11) == ao), find(combMat(:,12) == av), find(combMat(:,13) == at));
            peakPower = gammaDataAllElec(index).powerGammaAllElec{1, 1};  

%             [gammaPeaksForSF(oLoop,2),gammaPeaksForSF(oLoop,1)] = max(peakPower(50:96));
            gammaPeaksForSF(oLoop,1) = findIndexNMax(peakPower,1,[50 96],gridMontage,refChan); % Only central, temporal, parietal and occipital electrodes. Excluding Frontal and fronto-central electrodes 
            gammaPeaksForSF(oLoop,2) = peakPower(gammaPeaksForSF(oLoop,1));
            gammaPeaksForSF(oLoop,3) = oValsUnique(o);
            gammaPeaksForSF(oLoop,4) = o;
            gammaPeaksForSF(oLoop,5) = fValsUnique(f);
            gammaPeaksForSF(oLoop,6) = f;
            
            oLoop = oLoop + 1;
        end
    end

    gammaPeaksForSF = sortrows(gammaPeaksForSF,2);

    peakElec = gammaPeaksForSF(end,1);
    peakOIndex = gammaPeaksForSF(end,4);
    peakFIndex = gammaPeaksForSF(end,6);
    
    topoIndex = multiIntersect(find(combMat(:,1) == a), find(combMat(:,2) == e), find(combMat(:,3) == s),...
                    find(combMat(:,4) == peakFIndex), find(combMat(:,5) == peakOIndex), find(combMat(:,6) == c), find(combMat(:,7) == t),...
                    find(combMat(:,8) == aa), find(combMat(:,9) == ae), find(combMat(:,10) == as),...
                    find(combMat(:,11) == ao), find(combMat(:,12) == av), find(combMat(:,13) == at));
    peakPower = gammaDataAllElec(topoIndex).powerGammaAllElec{1, 1}; 
    
    figure(figH); subplot(xNum,yNum,subjectNum);
    topoplot(peakPower,chanlocs,'electrodes','numbers','style','both','drawaxis','off','nosedir',noseDir);

    if strcmp(refChan,'Bipolar')
        [~,~,bipolarLocs] = loadChanLocs(gridMontage,4);        
        EEGChannelsToExtract = bipolarLocs(peakElec,:);
    end

    [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,peakFIndex,peakOIndex,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,EEGChannelsToExtract);                                                        
    [Data,goodPos] = getRefData(plotData,trialNums,allBadTrials(EEGChannelsToExtract));

    % get data for given electrode
    dataMT=squeeze(Data(1,goodPos{1},:)); 

    if size(dataMT,2) ~= length(timeVals) && size(dataMT,1) == length(timeVals)
        dataMT = dataMT';
    end

    % get time and frequency axes
    tStim =  (timeVals>STMin) & (timeVals<=STMax);
    tBL = (timeVals>BLMin) & (timeVals<=BLMax);

    % calculate MTFFT in stim and BL periods
    [rawPSDStim(:,subjectNum),fAxis]=mtspectrumc(dataMT(:,tStim)',mtmParams);
    [rawPSDBL(:,subjectNum)]=mtspectrumc(dataMT(:,tBL)',mtmParams);

    changeInPower(:,subjectNum) = conv2Log(rawPSDStim(:,subjectNum)./rawPSDBL(:,subjectNum));

%     rgbVals = getColorRGB(o);
%     plot(fAxis,changeInPower(:,subjectNum),'color',rgbVals); hold on;

%     % plot average TF
%     try
%         if strcmpi(gridMontage,'brainCap64'); continue; end;
%         [~,~,tfTAxis,tfFAxis,rawPower(:,:,tfNum)] = getSTFT(dataMT,movingWin,mtmParams,timeVals,BLMin,BLMax);
%         tfNum = tfNum + 1;
%     catch
%         disp([subjectName ' could not be evaluated for STFT.']);
%     end

figure(figG); subplot(xNum,yNum,subjectNum);
plot(fAxis,conv2Log(rawPSDStim(:,subjectNum)),'b'); xlim([0 100]); ylim([-3 3]); hold on;
plot(fAxis,conv2Log(rawPSDBL(:,subjectNum)),'k'); xlim([0 100]); ylim([-3 3]); hold on;

end
hold off;

changeInPower = changeInPower';
changeInPower(~any(changeInPower,2),:) = [];

rawPSDStim = rawPSDStim';
rawPSDStim(~any(rawPSDStim,2),:) = [];

rawPSDBL = rawPSDBL';
rawPSDBL(~any(rawPSDBL,2),:) = [];

% rawPowerAllSub = squeeze(mean(rawPower,3));
% tfBL = (tfTAxis>BLMin) & (tfTAxis<=BLMax);
% SRawBL = rawPowerAllSub(tfBL,:);
% mlogSRawBL = conv2Log(mean(SRawBL,1));
% SChange = 10*(conv2Log(rawPowerAllSub) - repmat(mlogSRawBL,size(rawPowerAllSub,1),1));
% figure; pcolor(tfTAxis,tfFAxis,SChange'); axis tight; shading interp;

meanPSDStim = mean(conv2Log(rawPSDStim),1);
stdPSDStim = std(conv2Log(rawPSDStim),1,1);
semPSDStim = stdPSDStim/sqrt(size(rawPSDStim,1));

meanPSDBL = mean(conv2Log(rawPSDBL),1);
stdPSDSBL = std(conv2Log(rawPSDBL),1,1);
semPSDBL = stdPSDSBL/sqrt(size(rawPSDBL,1));

figure; subplot(1,3,1);
plot(fAxis,changeInPower); xlim([0 100]); hold on;
plot(fAxis,mean(changeInPower,1),'k','linewidth',3); xlim([0 100]); hold on;
% plot(fAxis,mean(changeInPower,1)+2*std(changeInPower,1),'k','linewidth',1); xlim([0 100]); hold on;
% plot(fAxis,mean(changeInPower,1)-2*std(changeInPower,1),'k','linewidth',1); xlim([0 100]); hold off;

subplot(1,3,2); plot(fAxis,meanPSDStim,'b','linewidth',2); xlim([0 100]); hold on;
plot(fAxis,meanPSDStim + semPSDStim,'b','linewidth',1); xlim([0 100]); hold on;
plot(fAxis,meanPSDStim - semPSDStim,'b','linewidth',1); xlim([0 100]); hold on;

plot(fAxis,meanPSDBL,'k','linewidth',2); xlim([0 100]); hold on;
plot(fAxis,meanPSDBL + semPSDBL,'k','linewidth',1); xlim([0 100]); hold on;
plot(fAxis,meanPSDBL - semPSDBL,'k','linewidth',1); xlim([0 100]); hold off;

subplot(1,3,3); plot(fAxis,conv2Log(rawPSDStim),'linewidth',1); xlim([0 200]); hold on;
plot(fAxis,meanPSDStim,'b','linewidth',2); xlim([0 200]); hold off;


