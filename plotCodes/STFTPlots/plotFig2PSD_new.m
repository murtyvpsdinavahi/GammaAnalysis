
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
figH = figure(15698); set(figH,'numbertitle', 'off','name','topoplots');
figI = figure(15498); set(figI,'numbertitle', 'off','name','spectrograms');
figJ = figure(55668); set(figJ,'numbertitle', 'off','name','PSD across subjects on loglog scale');
figK = figure(55468); set(figK,'numbertitle', 'off','name','pooled results selected subjects');
figL = figure(583738); set(figL,'numbertitle', 'off','name','pooled results All Subjects');


tfNum = 1;
for subjectNum = 1:length(subjectNamesUnique) % [1:2 4:12 15 16];%
%     subjectNum = 3;
% if ((subjectNum == 1) || (subjectNum == 8) || (subjectNum == 11)); continue; end;

clear subjectName subjectIndices protocolIndices SFProtocolIndices dataLogIndex SFdataLogIndex
clear expDate protocolName gridMontage dataL folderName folderExtract sfVal Fs
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

    clear dataL folderName folderExtract folderSegment folderLFP
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

    clear mtmParams
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
    
    clear fValsUnique oValsUnique timeVals gammaBandDataAllElec
    [~,~,~,~,fValsUnique,oValsUnique] = loadParameterCombinations(folderExtract);
    [~,timeVals] = loadlfpInfo(folderLFP);
    load(fullfile(folderName,['gammaBandDataAllElec_' refChan '.mat']));

    switch refChan
        case 'Bipolar'
            refType = 4;
            noseDir = '-Y';
        case 'Hemisphere'
            refType = 2;
            noseDir = '+X';
    end
    chanlocs = loadChanLocs(gridMontage,refType);

    clear sfValsIndex
    if ~isempty(dataLogIndex)
        sfValsIndex = find(int8(fValsUnique*10) == int8(sfVal*10));
    else
        sfValsIndex = 1:length(fValsUnique);
    end

    a = 1; e = 1; s = 1; c = 1; t = 1; aa = 1; ae = 1; as = 1; ao = 1; av = 1; at = 1;

    clear oLoop f o gammaPeaksForSF
    oLoop = 1;
    for f = sfValsIndex
        for o = 1:length(oValsUnique)
    %         o = 2;
            clear combMat index peakPower
            combMat = [gammaBandDataAllElec.a; gammaBandDataAllElec.e; gammaBandDataAllElec.s; gammaBandDataAllElec.f; gammaBandDataAllElec.o; gammaBandDataAllElec.c; gammaBandDataAllElec.t;...
                gammaBandDataAllElec.aa; gammaBandDataAllElec.ae; gammaBandDataAllElec.as; gammaBandDataAllElec.ao; gammaBandDataAllElec.av; gammaBandDataAllElec.at];
            combMat = combMat';
            index = multiIntersect(find(combMat(:,1) == a), find(combMat(:,2) == e), find(combMat(:,3) == s),...
                    find(combMat(:,4) == f), find(combMat(:,5) == o), find(combMat(:,6) == c), find(combMat(:,7) == t),...
                    find(combMat(:,8) == aa), find(combMat(:,9) == ae), find(combMat(:,10) == as),...
                    find(combMat(:,11) == ao), find(combMat(:,12) == av), find(combMat(:,13) == at));
            peakPower = gammaBandDataAllElec(index).changePowerAllGamma{1,1};

%             [gammaPeaksForSF(oLoop,2),gammaPeaksForSF(oLoop,1)] = max(peakPower(50:96));
            gammaPeaksForSF(oLoop,1) = findIndexNMax(peakPower,1,[81 96],gridMontage,refChan); % Only central, temporal, parietal and occipital electrodes. Excluding Frontal and fronto-central electrodes 
            gammaPeaksForSF(oLoop,2) = peakPower(gammaPeaksForSF(oLoop,1));
            gammaPeaksForSF(oLoop,3) = oValsUnique(o);
            gammaPeaksForSF(oLoop,4) = o;
            gammaPeaksForSF(oLoop,5) = fValsUnique(f);
            gammaPeaksForSF(oLoop,6) = f;
            
            oLoop = oLoop + 1;
        end
    end

    gammaPeaksForSF = sortrows(gammaPeaksForSF,2);

    clear peakElec peakOIndex peakFIndex topoIndex
    peakElec = gammaPeaksForSF(end,1);
    peakOIndex = gammaPeaksForSF(end,4);
    peakFIndex = gammaPeaksForSF(end,6);
    
    topoIndex = multiIntersect(find(combMat(:,1) == a), find(combMat(:,2) == e), find(combMat(:,3) == s),...
                    find(combMat(:,4) == peakFIndex), find(combMat(:,5) == peakOIndex), find(combMat(:,6) == c), find(combMat(:,7) == t),...
                    find(combMat(:,8) == aa), find(combMat(:,9) == ae), find(combMat(:,10) == as),...
                    find(combMat(:,11) == ao), find(combMat(:,12) == av), find(combMat(:,13) == at));
    clear peakPower
    peakPower = gammaBandDataAllElec(topoIndex).changePowerAllGamma{1,1};
    
    figure(figH); subplot(xNum,yNum,subjectNum);
    topoplot(peakPower,chanlocs,'electrodes','numbers','style','both','drawaxis','off','nosedir',noseDir); caxis([-3 3]);
    title(subjectName); hold off;

    clear bipolarLocs EEGChannelsToExtract
    if strcmp(refChan,'Bipolar')
        [~,~,bipolarLocs] = loadChanLocs(gridMontage,4);        
        EEGChannelsToExtract = bipolarLocs(peakElec,:);
    end

    clear plotData trialNums allBadTrials Data goodPos 
    [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,peakFIndex,peakOIndex,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,EEGChannelsToExtract);                                                        
    [Data,goodPos] = getRefData(plotData,trialNums,allBadTrials(EEGChannelsToExtract));

    % get data for given electrode
    clear dataMT
    dataMT=squeeze(Data(1,goodPos{1},:)); 

    if size(dataMT,2) ~= length(timeVals) && size(dataMT,1) == length(timeVals)
        dataMT = dataMT';
    end

    % get time and frequency axes
    clear tStim tBL
    tStim =  (timeVals>STMin) & (timeVals<=STMax);
    tBL = (timeVals>BLMin) & (timeVals<=BLMax);

    % calculate MTFFT in stim and BL periods
    [rawPSDStim(:,subjectNum),fAxis]=mtspectrumc(dataMT(:,tStim)',mtmParams);
    [rawPSDBL(:,subjectNum)]=mtspectrumc(dataMT(:,tBL)',mtmParams);

    changeInPower(:,subjectNum) = conv2Log(rawPSDStim(:,subjectNum)./rawPSDBL(:,subjectNum));

%     rgbVals = getColorRGB(o);
%     plot(fAxis,changeInPower(:,subjectNum),'color',rgbVals); hold on;

    % plot average TF
%     try
%         if strcmpi(gridMontage,'brainCap64'); continue; end;
%         [~,~,tfTAxis,tfFAxis,rawPower(:,:,tfNum)] = getSTFT(dataMT,movingWin,mtmParams,timeVals,BLMin,BLMax);
%         tfNum = tfNum + 1;
%     catch
%         disp([subjectName ' could not be evaluated for STFT.']);
%     end

    clear dSTFT tfTAxis tfFAxis
    [~,dSTFT,tfTAxis,tfFAxis] = getSTFT(dataMT,movingWin,mtmParams,timeVals,BLMin,BLMax);
    figure(figI); subplot(xNum,yNum,subjectNum);
    pcolor(tfTAxis,tfFAxis,dSTFT'); hold on; axis tight; ylim([0 100]); caxis([-3 3]); shading interp;
    title(['Subject: ' subjectName ' elec:' num2str(peakElec)]); hold off;

    figure(figG); subplot(xNum,yNum,subjectNum);
    plot(fAxis,conv2Log(rawPSDStim(:,subjectNum)),'b'); xlim([0 100]); ylim([-3 3]); hold on;
    plot(fAxis,conv2Log(rawPSDBL(:,subjectNum)),'k'); xlim([0 100]); ylim([-3 3]); hold off;
    title(['Subject: ' subjectName ' elec:' num2str(peakElec)]); hold off;
    
    figure(figJ); subplot(xNum,yNum,subjectNum);
    loglog(fAxis,(rawPSDBL(:,subjectNum)),'k'); xlim([0 100]); ylim([-3 3]); hold off;
    title(['Subject: ' subjectName ' elec:' num2str(peakElec)]); hold off;
    
    [slopes(:,subjectNum),noiseFloor(:,subjectNum)] = getSlopesPSDBaseline((rawPSDBL(:,subjectNum)),fAxis);

end

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

for subNum = 1:size(rawPSDStim,1)
    colorVals = getColorRGB(subNum);
    figure(figL); subplot(1,3,1);
    plot(fAxis,changeInPower(subNum,:),'color',colorVals); xlim([0 100]); hold on;
    subplot(1,3,3); plot(fAxis,conv2Log(rawPSDStim(subNum,:)),'linewidth',1,'color',colorVals); xlim([0 200]); hold on;
end

figure(figL); subplot(1,3,1);
legend(subjectNamesUnique); title(['No. of subjects: ' num2str(size(subjectNamesUnique,2))]);
plot(fAxis,mean(changeInPower,1),'k','linewidth',3); xlim([0 100]); hold on;


subplot(1,3,2); plot(fAxis,meanPSDStim,'b','linewidth',2); xlim([0 100]); hold on;
plot(fAxis,meanPSDStim + semPSDStim,'b','linewidth',1); xlim([0 100]); hold on;
plot(fAxis,meanPSDStim - semPSDStim,'b','linewidth',1); xlim([0 100]); hold on;

plot(fAxis,meanPSDBL,'k','linewidth',2); xlim([0 100]); hold on;
plot(fAxis,meanPSDBL + semPSDBL,'k','linewidth',1); xlim([0 100]); hold on;
plot(fAxis,meanPSDBL - semPSDBL,'k','linewidth',1); xlim([0 100]); hold off;

subplot(1,3,3);
legend(subjectNamesUnique); title(['No. of subjects: ' num2str(size(subjectNamesUnique,2))]);
plot(fAxis,meanPSDStim,'b','linewidth',2); xlim([0 200]); hold off;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

slopes = cell2mat(slopes);
meanSlope = mean((slopes),2);
stdSlope = std((slopes),[],2);
semSlope = stdSlope/sqrt(size(slopes,2));
slopeThreshold = meanSlope - 3*semSlope;

rejectIndices = (int8(slopes(1,:)*10) < int8(slopeThreshold(1,1)*10));

changeInPowerAfterRejection = changeInPower;
changeInPowerAfterRejection(rejectIndices,:) = [];

rawPSDStimAfterRejection = rawPSDStim;
rawPSDStimAfterRejection(rejectIndices,:) = [];

rawPSDBLAfterRejection = rawPSDBL;
rawPSDBLAfterRejection(rejectIndices,:) = [];

subjectsSelected = subjectNamesUnique;
rejectIndices = find(rejectIndices);
for iRej = 1:length(rejectIndices)
    subjectsSelected{1,rejectIndices(iRej)} = '';
end
subjectsSelected(strcmp('',subjectsSelected)) = [];

% rawPowerAllSub = squeeze(mean(rawPower,3));
% tfBL = (tfTAxis>BLMin) & (tfTAxis<=BLMax);
% SRawBL = rawPowerAllSub(tfBL,:);
% mlogSRawBL = conv2Log(mean(SRawBL,1));
% SChange = 10*(conv2Log(rawPowerAllSub) - repmat(mlogSRawBL,size(rawPowerAllSub,1),1));
% figure; pcolor(tfTAxis,tfFAxis,SChange'); axis tight; shading interp;

meanPSDStim = mean(conv2Log(rawPSDStimAfterRejection),1);
stdPSDStim = std(conv2Log(rawPSDStimAfterRejection),1,1);
semPSDStim = stdPSDStim/sqrt(size(rawPSDStimAfterRejection,1));

meanPSDBL = mean(conv2Log(rawPSDBLAfterRejection),1);
stdPSDSBL = std(conv2Log(rawPSDBLAfterRejection),1,1);
semPSDBL = stdPSDSBL/sqrt(size(rawPSDBLAfterRejection,1));

for subNum = 1:size(rawPSDStimAfterRejection,1)
    colorVals = getColorRGB(subNum);
    figure(figK); subplot(1,3,1);
    plot(fAxis,changeInPowerAfterRejection(subNum,:),'color',colorVals); xlim([0 100]); hold on;
    subplot(1,3,3); plot(fAxis,conv2Log(rawPSDStimAfterRejection(subNum,:)),'linewidth',1,'color',colorVals); xlim([0 200]); hold on;   
end

figure(figK); subplot(1,3,1);
legend(subjectsSelected); title(['No. of subjects: ' num2str(size(subjectsSelected,2))]);
plot(fAxis,mean(changeInPowerAfterRejection,1),'k','linewidth',3); xlim([0 100]); hold off;

subplot(1,3,2); plot(fAxis,meanPSDStim,'b','linewidth',2); xlim([0 100]); hold on;
plot(fAxis,meanPSDStim + semPSDStim,'b','linewidth',1); xlim([0 100]); hold on;
plot(fAxis,meanPSDStim - semPSDStim,'b','linewidth',1); xlim([0 100]); hold on;

plot(fAxis,meanPSDBL,'k','linewidth',2); xlim([0 100]); hold on;
plot(fAxis,meanPSDBL + semPSDBL,'k','linewidth',1); xlim([0 100]); hold on;
plot(fAxis,meanPSDBL - semPSDBL,'k','linewidth',1); xlim([0 100]); hold off;

subplot(1,3,3); legend(subjectsSelected); 
title(['No. of subjects: ' num2str(size(subjectsSelected,2))]);
plot(fAxis,meanPSDStim,'b','linewidth',2); xlim([0 200]); hold off;


subjectsRejected = setdiff(subjectNamesUnique,subjectsSelected);