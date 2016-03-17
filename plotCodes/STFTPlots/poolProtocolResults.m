function poolProtocolResults(dataLogList,subjectIndices,protocolType,poolProtocolType,subjectToPlotTopo,refChan,numElec,freqBands,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth,lineSpecifiers)

% Get dataLog index
protocolType = upper(protocolType);
    switch protocolType
        case 'AZI';        protocolTypeName = 'AZIMUTH'; units = 'Deg';
        case 'ELEV';        protocolTypeName = 'ELEVATION'; units = 'Deg';
        case 'SIZE';        protocolTypeName = 'SIZE'; units = 'Deg';
        case 'SF';        protocolTypeName = 'SPATIAL FREQUENCY'; units = 'Hz';
        case 'ORI';        protocolTypeName = 'ORIENTATION'; units = 'Deg';
        case 'CON';        protocolTypeName = 'CONTRAST'; units = '%';
        case 'TFDF';        protocolTypeName = 'TEMP FREQ: DRIFTING'; units = 'Hz'; % For Drifting gratings
        case 'TFCP';        protocolTypeName = 'TEMP FREQ: COUNTERPHASE'; units = 'Hz'; % For Counterphasing gratings
        case 'AUDAZI';        protocolTypeName = 'AUDITORY AZIMUTH'; units = 'Deg';
        case 'AUDELEV';        protocolTypeName = 'AUDITORY ELEVATION'; units = 'Deg';
        case 'RF';        protocolTypeName = 'RIPPLE FREQUENCY'; units = 'Cycles/Deg';
        case 'RP';        protocolTypeName = 'RIPPLE PHASE'; units = 'Deg';
        case 'RIPVOL';        protocolTypeName = 'RIPPLE VOLUME'; units = '%';
        case 'RIPVEL';        protocolTypeName = 'RIPPLE VELOCITY'; units = 'Hz';
    end
poolProtocolType = upper(poolProtocolType);
protocolIndices = find(strcmp(protocolType,dataLogList.protocolTypes));
dataLogIndices = intersect(subjectIndices,protocolIndices);
subjectForTopo = find(strcmp(subjectToPlotTopo,dataLogList.subjectNames));
dataLogIndexForTopo = find(intersect(dataLogIndices,subjectForTopo) == dataLogIndices);

% Get plot handles
figNum = randi(10000);
figH = figure(figNum);
plotCols = length(freqBands);
gridPos = [0.1 0.1 0.8 0.8];
hGridPlot = getPlotHandles(2,plotCols,gridPos,0.1,0.1,0); 
uicontrol('Unit','Normalized', ...
        'Position',[0.4 0.96 0.2 0.03], ...
        'Style','text','String',protocolTypeName,'FontSize',15);

% colorVectors = 0.5*rand(length(dataLogIndices),3)+0.1;

for iBand = 1:plotCols
    freqBand = freqBands{iBand};
    legendTitle = {};
    for dataLogIndex = 1:length(dataLogIndices)
        
    % Get dataLog file
    subjectName = dataLogList.subjectNames{1,dataLogIndices(dataLogIndex)};
    expDate = dataLogList.expDates{1,dataLogIndices(dataLogIndex)};
    protocolName = dataLogList.protocolNames{1,dataLogIndices(dataLogIndex)};
    gridMontage = dataLogList.capMontage{1,dataLogIndices(dataLogIndex)};
    legendTitle = cat(2,legendTitle,{subjectName});

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
    
    % Find out the best condition
    load(fullfile(folderName,['analysedDataAllElec_' refChan '.mat']));
    combMat = [analysedDataAllElec.a; analysedDataAllElec.e; analysedDataAllElec.s; analysedDataAllElec.f; analysedDataAllElec.o; analysedDataAllElec.c; analysedDataAllElec.t;...
        analysedDataAllElec.aa; analysedDataAllElec.ae; analysedDataAllElec.as; analysedDataAllElec.ao; analysedDataAllElec.av; analysedDataAllElec.at];
    combMat = combMat';
    clear peakPowerPooledSub
        for x=1:xLen    
            clear peakPower
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

                switch freqBand
                    case 'High Gamma'
                        peakPower(index,:) = analysedDataAllElec(index).meanPowerAllElecHG{1, 1};
                        fMin = 51;
                        fMax = 80;
                    case 'Low Gamma'
                        peakPower(index,:) = analysedDataAllElec(index).meanPowerAllElecLG{1, 1};
                        fMin = 21;
                        fMax = 50;
                    case 'Alpha'
                        peakPower(index,:) = -1*(analysedDataAllElec(index).meanPowerAllElecAlpha{1, 1});
                        fMin = 7;
                        fMax = 15;
                end
                
%                 if strcmp(gridMontage,'brainCap64') && strcmp(refChan,'Bipolar') % brainCap64 has one electrode less than actiCap64 in bipolar maontage system
%                     peakPowerMont(1,end+1) = peakPowerMont(1,end);
%                 end
%                 
%                 peakPower(index,:) = peakPowerMont;                    

                [~,EEGChannels] = findIndexNMax(peakPower(index,:),numElec,[50 96],gridMontage,refChan);
                EEGChannelsToExtract = rowCat(EEGChannels);
                [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,EEGChannelsToExtract); 
                [dataProt,goodPosProt] = getRefData(plotData,trialNums,allBadTrials(EEGChannelsToExtract));

                if p>1            
                    Data = cat(2,dataProt,Data);
                    for ePos = 1:size(goodPosProt,2)
                        goodPos{1, ePos} = [goodPos{1, ePos},(goodPosProt{1, ePos} + numTrials)];                
                    end
                    peakPowerPooledSub(x,:) = peakPowerPooledSub(x,:) + peakPower(index,:);
                    numTrials = numTrials + size(dataProt,2);
                else            
                    Data = dataProt;            
                    goodPos = goodPosProt;
                    peakPowerPooledSub(x,:) = peakPower(index,:);
                    numTrials = size(dataProt,2);
                end

            end
            peakPowerPooled{iBand,dataLogIndex,x} = peakPowerPooledSub(x,:)/p;
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
            if strcmp(freqBand,'Alpha')
                meanPeakFreqForCondition = findMinBandWidth(dPowerBestElec,fRangeVal);
            else
                meanPeakFreqForCondition = findPeakBandWidth(dPowerBestElec,fRangeVal);
            end
            fBandMin = meanPeakFreqForCondition - (desiredBandWidth/2-1);
            fBandMax = meanPeakFreqForCondition + (desiredBandWidth/2);
            fBandRange =   (fAxis>=fBandMin) & (fAxis<=fBandMax);
            meanPowerBestElec(iBand,dataLogIndex,x) = mean(mean(dSBestElec(tStim,fBandRange),2));

            % get power values in LG and HG bands for all electrodes
            dPowerAllElec = dSAllElec(tStim,fRange);
            if strcmp(freqBand,'Alpha')
                meanPeakFreqForCondition = findMinBandWidth(dPowerAllElec,fRangeVal);
            else
                meanPeakFreqForCondition = findPeakBandWidth(dPowerAllElec,fRangeVal);
            end
            fBandMin = meanPeakFreqForCondition - (desiredBandWidth/2-1);
            fBandMax = meanPeakFreqForCondition + (desiredBandWidth/2);
            fBandRange =   (fAxis>=fBandMin) & (fAxis<=fBandMax);
            meanPowerAllElec(iBand,dataLogIndex,x) = mean(mean(dSAllElec(tStim,fBandRange),2));

        end
        
        % Plot tuning curves
        powerData = squeeze(meanPowerAllElec(iBand,dataLogIndex,:));
        if strcmp(freqBand,'Alpha')
            curveData(dataLogIndex,:) = powerData/max(abs(powerData)); % Normalise for comparison
        else
            curveData(dataLogIndex,:) = powerData/max(powerData); % Normalise for comparison
        end
        meanCurveData = mean(curveData,1);
        stdCurveData = std(curveData,1,1);
        semCurveData = stdCurveData/sqrt(length(dataLogIndices));
%         curveColor = colorVectors(dataLogIndex,:);
        curveColor = getColorRGB(dataLogIndex);
        curveSpecifier = lineSpecifiers{dataLogIndex};
        
        if strcmp(protocolType,'SF') || strcmp(protocolType,'SIZE')
            subplot(hGridPlot(2,iBand)); hold on;
            plot(log2(xValsUnique),curveData(dataLogIndex,:),curveSpecifier,'Color',curveColor);
        elseif strcmp(protocolType,'TFDF') || strcmp(protocolType,'TFCP')
            subplot(hGridPlot(2,iBand)); hold on;
            plot([-2 log2(xValsUnique(2:end))],curveData(dataLogIndex,:),curveSpecifier,'Color',curveColor);            
        % elseif strcmp(protocolType,'ORI')
        %     subplot(plotHandle); polar([xValsUnique*(pi/180)],meanPowerBestElec,'-b'); hold on;
        %     subplot(plotHandle); polar([xValsUnique*(pi/180)],meanPowerAllElec,'-k');
        else
            subplot(hGridPlot(2,iBand)); hold on;
            plot(xValsUnique,curveData(dataLogIndex,:),curveSpecifier,'Color',curveColor);
        end
    end
    
        % Plot means and set error bars and legends
        if strcmp(protocolType,'SF') || strcmp(protocolType,'SIZE')
            errorbar(log2(xValsUnique),meanCurveData,semCurveData,'-ok','LineWidth',2);
            set(hGridPlot(2,iBand),'xtick',log2(xValsUnique)); axis tight;
            set(hGridPlot(2,iBand),'xticklabel',xValsUnique); axis tight;
        elseif strcmp(protocolType,'TFDF') || strcmp(protocolType,'TFCP')
            errorbar([-2 log2(xValsUnique(2:end))],meanCurveData,semCurveData,'-ok','LineWidth',2);
            set(hGridPlot(2,iBand),'xtick',[-2 log2(xValsUnique(2:end))]); axis tight;
            set(hGridPlot(2,iBand),'xticklabel',xValsUnique); axis tight;
        else
            errorbar(xValsUnique,meanCurveData,semCurveData,'-ok','LineWidth',2);
            set(hGridPlot(2,iBand),'xtick',xValsUnique); axis tight;
        end
        
        set(hGridPlot(2,iBand),'FontSize',15);
        set(hGridPlot(2,iBand),'FontSize',15);
        ylabel(hGridPlot(2,iBand),'10*(log10(dPower)');
        xlabel(hGridPlot(2,iBand),[protocolTypeName '(' units ')']);
        
%         % Add legend
%         legendTitle = cat(2,legendTitle,{'Mean'});
%         legendHandle = legend(hGridPlot(2,iBand),legendTitle);
%         set(legendHandle,'Location','best');
%         set(legendHandle,'Color','none');
%         set(legendHandle,'Box','off');
        
    
        % Plot topoplot for best condition
        if strcmp(freqBand,'Alpha')
            [~,bestCond] = min(meanPowerAllElec(iBand,dataLogIndexForTopo,:));
            peakPowerToPlot = -1*(squeeze(peakPowerPooled{iBand,dataLogIndexForTopo,bestCond}));
        else
            [~,bestCond] = max(meanPowerAllElec(iBand,dataLogIndexForTopo,:));
            peakPowerToPlot = squeeze(peakPowerPooled{iBand,dataLogIndexForTopo,bestCond});
        end
                
        subplot(hGridPlot(1,iBand)); topoplot(peakPowerToPlot,chanlocs,'electrodes','numbers','style','both','drawaxis','off','nosedir',noseDir);
        title(freqBand,'FontSize',15);
end

if strcmp(protocolType,'CON'); protocolType = 'Contrast'; end
makeDirectory(fullfile(pwd,'Plots','VisualGammaProject',protocolType));
savefig(figH,fullfile(pwd,'Plots','VisualGammaProject',protocolType,[protocolType '.fig']));
save(fullfile(pwd,'Plots','VisualGammaProject',protocolType,[protocolType '.mat']));
close(figH);
end
