function plotProtocolResults(dataLogList,subjectIndices,protocolType,poolProtocolType,plotHandles,refChan,numElec,gammaBand,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth)

% Get dataLog index
protocolType = upper(protocolType);
poolProtocolType = upper(poolProtocolType);
protocolIndices = find(strcmp(protocolType,dataLogList.protocolTypes));
dataLogIndex = intersect(subjectIndices,protocolIndices);
if length(dataLogIndex)>1; 
    warning(['More than one index for protocol type: ' protocolType '. Taking only the first index']);
    dataLogIndex(2:end)=[];
end

% Get dataLog file
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

Fs = dataLog{9, 2};
mtmParams.Fs = Fs;

% Get chanlocs
switch refChan
    case 'Bipolar'
        refType = 4;
        noseDir = '-Y';
    case 'Hemisphere'
        refType = 2;
        noseDir = '+X';
end
chanlocs = loadChanLocs(gridMontage,refType);

% Load parameter combinations and timeVals
folderExtract = fullfile(folderName,'extractedData');
folderSegment = fullfile(folderName,'segmentedData');
folderLFP = fullfile(folderSegment,'LFP');
[~,aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,cValsUnique,tValsUnique,aaValsUnique,...
        aeValsUnique,asValsUnique,aoValsUnique,avValsUnique,atValsUnique] = loadParameterCombinations(folderExtract);
[~,timeVals] = loadlfpInfo(folderLFP);
switch protocolType
    case 'AZI';        xValsUnique = aValsUnique;
    case 'ELEV';        xValsUnique = eValsUnique;
    case 'SIZE';        xValsUnique = sValsUnique;
    case 'SF';        xValsUnique = fValsUnique;
    case 'ORI';        xValsUnique = oValsUnique;
    case 'CON';        xValsUnique = cValsUnique;
    case 'TFDF';        xValsUnique = tValsUnique; % For Drifting gratings
    case 'TFCP';        xValsUnique = tValsUnique; % For Counterphasing gratings
    case 'AUDAZI';        xValsUnique = aaValsUnique;
    case 'AUDELEV';        xValsUnique = aeValsUnique;
    case 'RF';        xValsUnique = asValsUnique;
    case 'RP';        xValsUnique = aoValsUnique;
    case 'RIPVOL';        xValsUnique = avValsUnique;
    case 'RIPVEL';        xValsUnique = atValsUnique;
end

switch poolProtocolType
    case 'AZI';        poolValsUnique = aValsUnique;
    case 'ELEV';        poolValsUnique = eValsUnique;
    case 'SIZE';        poolValsUnique = sValsUnique;
    case 'SF';        poolValsUnique = fValsUnique;
    case 'ORI';        poolValsUnique = oValsUnique;
    case 'CON';        poolValsUnique = cValsUnique;
    case 'TFDF';        poolValsUnique = tValsUnique; % For Drifting gratings
    case 'TFCP';        poolValsUnique = tValsUnique; % For Counterphasing gratings
    case 'AUDAZI';        poolValsUnique = aaValsUnique;
    case 'AUDELEV';        poolValsUnique = aeValsUnique;
    case 'RF';        poolValsUnique = asValsUnique;
    case 'RP';        poolValsUnique = aoValsUnique;
    case 'RIPVOL';        poolValsUnique = avValsUnique;
    case 'RIPVEL';        poolValsUnique = atValsUnique;
    case 'NONE'; poolValsUnique = 1;
end
xLen = length(xValsUnique);
poolLen = length(poolValsUnique);
a = 1; e = 1; s = 1; f = 1; o = 1; c = 1; t = 1; 
aa = 1; ae = 1; as = 1; ao = 1; av = 1; at = 1;

% Get plot handles
capHandle = plotHandles.topo;
gridPos = plotHandles.gridPos;
plotHandle = plotHandles.plot;
hGridPlot = rowCat(eval('getPlotHandles(2,xLen,gridPos,0.002)'));

% Find out the best condition
load(fullfile(folderName,['analysedDataAllElec_' refChan '.mat']));
combMat = [analysedDataAllElec.a; analysedDataAllElec.e; analysedDataAllElec.s; analysedDataAllElec.f; analysedDataAllElec.o; analysedDataAllElec.c; analysedDataAllElec.t;...
    analysedDataAllElec.aa; analysedDataAllElec.ae; analysedDataAllElec.as; analysedDataAllElec.ao; analysedDataAllElec.av; analysedDataAllElec.at];
combMat = combMat';
for x=1:xLen
    for p = 1:poolLen
        switch protocolType
            case 'AZI';        a = x;
            case 'ELEV';        e = x;
            case 'SIZE';        s = x;
            case 'SF';        f = x;
            case 'ORI';        o = x;
            case 'CON';        c = x;
            case 'TFDF';        t = x; % For Drifting gratings
            case 'TFCP';        t = x; % For Counterphasing gratings
            case 'AUDAZI';        aa = x;
            case 'AUDELEV';        ae = x;
            case 'RF';        as = x;
            case 'RP';        ao = x;
            case 'RIPVOL';        av = x;
            case 'RIPVEL';        at = x;
        end

        switch poolProtocolType
            case 'AZI';        a = p;
            case 'ELEV';        e = p;
            case 'SIZE';        s = p;
            case 'SF';        f = p;
            case 'ORI';        o = p;
            case 'CON';        c = p;
            case 'TFDF';        t = p; % For Drifting gratings
            case 'TFCP';        t = p; % For Counterphasing gratings
            case 'AUDAZI';        aa = p;
            case 'AUDELEV';        ae = p;
            case 'RF';        as = p;
            case 'RP';        ao = p;
            case 'RIPVOL';        av = p;
            case 'RIPVEL';        at = p;
        end

        index = multiIntersect(find(combMat(:,1) == a), find(combMat(:,2) == e), find(combMat(:,3) == s),...
            find(combMat(:,4) == f), find(combMat(:,5) == o), find(combMat(:,6) == c), find(combMat(:,7) == t),...
            find(combMat(:,8) == aa), find(combMat(:,9) == ae), find(combMat(:,10) == as),...
            find(combMat(:,11) == ao), find(combMat(:,12) == av), find(combMat(:,13) == at));
        
        switch gammaBand
            case 'High Gamma'
                peakPower(index,:) = analysedDataAllElec(index).meanPowerAllElecHG{1, 1};
                fMin = 51;
                fMax = 80;
            case 'Low Gamma'
                peakPower(index,:) = analysedDataAllElec(index).meanPowerAllElecLG{1, 1};
                fMin = 21;
                fMax = 50;
        end
        
        [~,EEGChannels] = findIndexNMax(peakPower(index,:),numElec,[50 96],gridMontage,refChan);
        EEGChannelsToExtract = rowCat(EEGChannels);
        [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,EEGChannelsToExtract); 
    %     [plotData,trialNums,allBadTrials] = getDataGAV(1,1,1,1,x,1,1,1,1,1,1,1,1,folderName,folderLFP,EEGChannelsToExtract);
        [dataProt,goodPosProt] = getRefData(plotData,trialNums,allBadTrials(EEGChannelsToExtract));
        
        if p>1            
            Data = cat(2,dataProt,Data);
            for ePos = 1:size(goodPosProt,2)
%                 goodPos = cat(2,goodPosProt,goodPos);
                goodPos{1, ePos} = [goodPos{1, ePos},(goodPosProt{1, ePos} + numTrials)];                
            end
            peakPowerPooled(x,:) = peakPowerPooled(x,:) + peakPower(index,:);
            numTrials = numTrials + size(dataProt,2);
        else            
            Data = dataProt;            
            goodPos = goodPosProt;
            peakPowerPooled(x,:) = peakPower(index,:);
            numTrials = size(dataProt,2);
        end
    
    end
    peakPowerPooled = peakPowerPooled/p;
    dataBestElec = squeeze(Data(1,:,:));
    dataTFAllElec = [];
    for iCD=1:size(Data,1)                                                        
        dataTF=Data(iCD,goodPos{iCD},:);
        dataTF=squeeze(dataTF);
        dataTFAllElec = [dataTFAllElec;dataTF];
    end
        [~,dSBestElec] = getSTFT(dataBestElec,movingWin,mtmParams,timeVals,BLMin,BLMax);
        [~,dSAllElec,tAxis,fAxis] = getSTFT(dataTFAllElec,movingWin,mtmParams,timeVals,BLMin,BLMax);
                                                    
        % get time and frequency axes
        tStim =  (tAxis>=STMin) & (tAxis<=STMax);

        fRange =   (fAxis>=fMin) & (fAxis<=fMax);
        fRangeVal = fAxis(fRange);                                                    

        % get power values in LG and HG bands for best electrode
        dPowerBestElec = dSBestElec(tStim,fRange);
        meanPeakFreqForCondition = findPeakBandWidth(dPowerBestElec,fRangeVal);
        fBandMin = meanPeakFreqForCondition - (desiredBandWidth/2-1);
        fBandMax = meanPeakFreqForCondition + (desiredBandWidth/2);
        fBandRange =   (fAxis>=fBandMin) & (fAxis<=fBandMax);
        meanPowerBestElec(x) = mean(mean(dSBestElec(tStim,fBandRange),2));
        
        % get power values in LG and HG bands for all electrodes
        dPowerAllElec = dSAllElec(tStim,fRange);
        meanPeakFreqForCondition = findPeakBandWidth(dPowerAllElec,fRangeVal);
        fBandMin = meanPeakFreqForCondition - (desiredBandWidth/2-1);
        fBandMax = meanPeakFreqForCondition + (desiredBandWidth/2);
        fBandRange =   (fAxis>=fBandMin) & (fAxis<=fBandMax);
        meanPowerAllElec(x) = mean(mean(dSAllElec(tStim,fBandRange),2));

%         subplot(hGridPlot(x)); pcolor(tAxis,fAxis,dSBestElec'); shading interp; ylim([0 100]); caxis([-8 8]);
%         text(0,0.9,['n = ' num2str(size(dataBestElec,1))],'unit','normalized','fontsize',9,'Parent',hGridPlot(x));
%         text(0.4,0.9,[protocolType '= ' num2str(xValsUnique(x))],'unit','normalized','fontsize',9,'Parent',hGridPlot(x));
        
        if p == poolLen            
            [gaborBackground,gaborRing] = getStimulusGaborsGAV(dataLog,a,e,s,f,o,c,t);
            stimulusImage = drawStimulus(hGridPlot(x),gaborBackground,gaborRing);
%             if strcmp(protocolType,'CON')
%                 stimulusImage = stimulusImage*(cValsUnique(c)/100);
%             end
            subplot(hGridPlot(x)); sc(stimulusImage,[min(min(stimulusImage)) max(max(stimulusImage))]*(cValsUnique(c)/100));
        end
        
        colormap('default');
        subplot(hGridPlot(x+xLen)); pcolor(tAxis,fAxis,dSAllElec'); shading interp; ylim([0 100]); caxis([-3 3]);
        text(0.1,0.9,['n = ' num2str(size(dataTFAllElec,1))],'unit','normalized','fontsize',9,'Parent',hGridPlot(x+xLen));
        if x ~= 1; set(hGridPlot(x+xLen),'yticklabel',[]); end
end

% Plot topoplot for best condition
[~,bestCond] = max(meanPowerAllElec);
subplot(capHandle); topoplot(peakPowerPooled(bestCond,:),chanlocs,'electrodes','off','style','both','drawaxis','off','nosedir',noseDir);
text(0.1,0.9,protocolType,'unit','normalized','fontsize',9,'fontweight','bold','Parent',capHandle);

% Plot tuning curves
if strcmp(protocolType,'SF') || strcmp(protocolType,'SIZE')
    subplot(plotHandle); plot(log2(xValsUnique),meanPowerBestElec,'b','LineWidth',1,'Marker','+'); hold on;
    subplot(plotHandle); plot(log2(xValsUnique),meanPowerAllElec,'k','LineWidth',1,'Marker','*');
    set(plotHandle,'xtick',log2(xValsUnique)); axis tight;
    set(plotHandle,'xticklabel',xValsUnique); axis tight;
    
elseif strcmp(protocolType,'TFDF') || strcmp(protocolType,'TFCP')
    subplot(plotHandle); plot([-2 log2(xValsUnique(2:end))],meanPowerBestElec,'b','LineWidth',1,'Marker','+'); hold on;
    subplot(plotHandle); plot([-2 log2(xValsUnique(2:end))],meanPowerAllElec,'k','LineWidth',1,'Marker','*');
    set(plotHandle,'xtick',[-2 log2(xValsUnique(2:end))]); axis tight;
    set(plotHandle,'xticklabel',xValsUnique); axis tight;
    
% elseif strcmp(protocolType,'ORI')
%     subplot(plotHandle); polar([xValsUnique*(pi/180)],meanPowerBestElec,'-b'); hold on;
%     subplot(plotHandle); plot([xValsUnique*(pi/180)],meanPowerAllElec,'-k');
else
    subplot(plotHandle); plot(xValsUnique,meanPowerBestElec,'b','LineWidth',1,'Marker','+'); hold on;
    subplot(plotHandle); plot(xValsUnique,meanPowerAllElec,'k','LineWidth',1,'Marker','*');
    set(plotHandle,'xtick',xValsUnique); axis tight;
end

legendHandle = legend(plotHandle,'Best elec','5 elecs','Location','Best');
set(legendHandle,'Color','none');
set(legendHandle,'Box','off');
ylabel(plotHandle,'10*(log10(dPower)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmpi(protocolType,'CON'); protocolType = 'Contrast'; end
makeDirectory(fullfile(pwd,'Plots','VisualGammaProject','SubjectWise',subjectName));
save(fullfile(pwd,'Plots','VisualGammaProject','SubjectWise',subjectName,[protocolType '.mat']));
end