function AllSubJackKnifeAnalysis

% Defaults
freqBandToPlot = [0 150];
LGamma = [25 35];
TGamma = [40 70];
subjectsToIgnore = [3 5 7 15 16];
protocolType = 'Ori';
refChan = 'Bipolar';
movingWin = [0.4 0.01];

tapers = [1 1];
BLPeriod = [-0.5 0];
STPeriod = [0.25 0.75];
    

[dataLogList.folderEEG,dataLogList.subjectNames,dataLogList.expDates,dataLogList.protocolNames,dataLogList.protocolTypes,...
    dataLogList.gridType,dataLogList.folderSourceString,dataLogList.capMontage] = allDataLogsForAnalysisVisualGammaEEG;
subjectNamesUnique = unique(dataLogList.subjectNames);

for subjectNum = 1:length(subjectNamesUnique)
    if ismember(subjectNum,subjectsToIgnore); continue; end;
%     subjectNum = 17;    
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

    dataLog{1,2} = subjectName;
    dataLog{2,2} = dataLogList.gridType;
    dataLog{3,2} = expDate;
    dataLog{4,2} = protocolName;
    dataLog{14,2} = dataLogList.folderSourceString;

    [~,folderName]=getFolderDetails(dataLog);
    clear dataLog
    load(fullfile(folderName,'dataLog.mat'));

    Fs = dataLog{9, 2};
    
    mtmParams.Fs = Fs;
    mtmParams.tapers = tapers;
    mtmParams.err=0;
    mtmParams.pad=-1;

    BLMin = BLPeriod(1);
    BLMax = BLPeriod(2);

    STMin = STPeriod(1);
    STMax = STPeriod(2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figH = figure(randi(10000)); set(figH,'numbertitle', 'off','name',['Subject: ' subjectName '; Best stimulus from protocol: ' protocolType]);
    figArea = [0.05 0.05 0.9 0.9];
    [~,~,plotsPos] = getPlotHandles(1,1,figArea,0.01);
    [plotPlotsHandle,~,plotPlotsPos] = getPlotHandles(3,2,plotsPos{1},0.01);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    gridMontage = dataLog{15,2};
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

    clear plotData Data
    folderSegment = fullfile(folderName,'segmentedData');
    folderLFP = fullfile(folderSegment,'LFP');
    [~,timeVals] = loadlfpInfo(folderLFP);

    % load(fullfile(folderName,['analysedDataAllElec_' refChan '.mat']));
%     load(fullfile(folderName,['gammaBandDataAllElec_' refChan '.mat']));
    folderExtract = fullfile(folderName,'extractedData');
    
    a = 1; e = 1; s = 1; f = 1; o = 1; c = 1; t = 1; 
    aa = 1; ae = 1; as = 1; ao = 1; av = 1; at = 1;
    
    if strcmpi(protocolType,'SF') || strcmpi(protocolType,'Ori')
        load(fullfile('D:','Plots','bestStimulus.mat'));
        bestStimIndex = find(strcmpi({bestStimulus.subjectName},subjectName));
        subjectSF = bestStimulus(bestStimIndex).SF;
        subjectOri = bestStimulus(bestStimIndex).Orientation;
        [~,~,~,~,fValsUnique,oValsUnique] = loadParameterCombinations(folderExtract);
        f = find(int8(fValsUnique*10) == int8(subjectSF*10));
        o = find(oValsUnique == subjectOri);
    else
        [~,~,~,sValsUnique,~,~,cValsUnique,tValsUnique] = loadParameterCombinations(folderExtract);
        switch protocolType
            case 'SIZE';        s = length(sValsUnique);
            case 'CON';        c = length(cValsUnique);
            case 'TFDF';        t = length(tValsUnique); % For Drifting gratings
            case 'TFCP';        t = length(tValsUnique); % For Counterphasing gratings
        end
    end
    
%     combMat = [gammaBandDataAllElec.a; gammaBandDataAllElec.e; gammaBandDataAllElec.s; gammaBandDataAllElec.f; gammaBandDataAllElec.o; gammaBandDataAllElec.c; gammaBandDataAllElec.t;...
%         gammaBandDataAllElec.aa; gammaBandDataAllElec.ae; gammaBandDataAllElec.as; gammaBandDataAllElec.ao; gammaBandDataAllElec.av; gammaBandDataAllElec.at];
%     combMat = combMat';
%     index = multiIntersect(find(combMat(:,1) == a), find(combMat(:,2) == e), find(combMat(:,3) == s),...
%             find(combMat(:,4) == f), find(combMat(:,5) == o), find(combMat(:,6) == c), find(combMat(:,7) == t),...
%             find(combMat(:,8) == aa), find(combMat(:,9) == ae), find(combMat(:,10) == as),...
%             find(combMat(:,11) == ao), find(combMat(:,12) == av), find(combMat(:,13) == at));
        
    % Pool across elecs common to all subjects 
    for iSide = 1:3

        clear commonBipolarEEGChannels side
        switch iSide        
            case 1
                commonBipolarEEGChannels = [83 84 92];
                side = 'LeftHemisphere';
            case 2
                commonBipolarEEGChannels = [86 87 94];
                side = 'RightHemisphere';
            case 3
                commonBipolarEEGChannels = [83 84 92 86 87 94];
                side = 'BothHemispheres';
        end

        clear bipolarLocs commonUnipolarEEGChannels EEGChannelsToExtract
        [~,~,bipolarLocs] = loadChanLocs(gridMontage,4);        
        commonUnipolarEEGChannels = bipolarLocs(commonBipolarEEGChannels,:);
        EEGChannelsToExtract = rowCat(commonUnipolarEEGChannels);
        
        % Load data
        clear plotData trialNums allBadTrials Data goodPos
        [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,EEGChannelsToExtract);                                                        
        [Data,goodPos] = getRefData(plotData,trialNums,allBadTrials(EEGChannelsToExtract),refChan);

        % get time axes
        clear tStim tBL
        tStim =  (timeVals>STMin) & (timeVals<=STMax);
        tBL = (timeVals>BLMin) & (timeVals<=BLMax);

        clear dataTFAllElec totPos
        dataTFAllElec = [];
        totPos = 0;
        for iCD = 1:size(Data,1)
            clear dataMT
            dataMT=Data(iCD,goodPos{iCD},:);
            dataMT=squeeze(dataMT);
            if size(dataMT,1)>size(dataMT,2); dataMT = dataMT'; end;
            dataTFAllElec = [dataTFAllElec;dataMT];
            totPos = totPos + length(goodPos{iCD});
        end

        % STFT
        clear dSpectrogram tAxisSpec fAxisSpec
        mtmParams.trialave=0;
        mtmParams.err = 0;
        [~,dSpectrogram,tAxisSpec,fAxisSpec] = getSTFT(dataTFAllElec,movingWin,mtmParams,timeVals,BLMin,BLMax);
        subplot(plotPlotsHandle(iSide,1)); pcolor(tAxisSpec,fAxisSpec,dSpectrogram'); shading interp; ylim([0 100]); caxis([-3 3]); xlim([-0.2 1.2]);
        text(0.1,0.9,['n=' num2str(totPos)],'unit','normalized','Parent',plotPlotsHandle(iSide,1),'fontsize',9);
        text(0.1,0.8,side,'unit','normalized','Parent',plotPlotsHandle(iSide,1),'fontsize',9);

        % MTFFT  
        clear rawPSDStimElecAllTrials fAxisStim rawPSDBLElecAllTrials fAxisBL rawPSDStimElec rawPSDBLElec
        mtmParams.trialave=0;
        [rawPSDStimElecAllTrials,fAxisStim]=mtspectrumc(dataTFAllElec(:,tStim)',mtmParams);
        [rawPSDBLElecAllTrials,fAxisBL]=mtspectrumc(dataTFAllElec(:,tBL)',mtmParams);
        rawPSDStimElec = squeeze(mean(rawPSDStimElecAllTrials,2));
        rawPSDBLElec = squeeze(mean(rawPSDBLElecAllTrials,2));
        
        % Calculate jackknife intervals
        clear rawPSDStimElecErr rawPSDBLElecErr
        mtmParams.trialave=1;
        mtmParams.err = [2 0.05];
        [~,~,rawPSDStimElecErr] = mtspectrumc(dataTFAllElec(:,tStim)',mtmParams);
        [~,~,rawPSDBLElecErr] = mtspectrumc(dataTFAllElec(:,tBL)',mtmParams);        
        
        % Plot
        clear fAxis;
        if (fAxisStim ~= fAxisBL); error('frequency axes in BL and stim period different'); else fAxis = fAxisStim; end;
        
        clear fRangeToPlot fRangeValToPlot
        fRangeToPlot =   (fAxis>=freqBandToPlot(1)) & (fAxis<=freqBandToPlot(2));
        fRangeValToPlot = fAxis(fRangeToPlot);
        subplot(plotPlotsHandle(iSide,2)); plot(fAxis,conv2Log(rawPSDStimElec),'linewidth',2,'color',[0 0 1]); hold on;
        plot(fAxis,conv2Log(rawPSDBLElec),'linewidth',2,'color',[0 0 0]); hold on; 
        plot(fAxis,conv2Log(rawPSDStimElecErr'),'linewidth',1,'color',[0 0 0.5]); hold on;
        plot(fAxis,conv2Log(rawPSDBLElecErr'),'linewidth',1,'color',[0.5 0.5 0.5]); hold on;
        xlim([fRangeValToPlot(1) fRangeValToPlot(end)]); hold off;        
        
        % Save gammaDetails in a struct
        gammaDetails(subjectNum).subjectName = subjectName;
        gammaDetails(subjectNum).(['rawPSDStim' side]) = rawPSDStimElec;
        gammaDetails(subjectNum).(['rawPSDBL' side]) = rawPSDBLElec;
        gammaDetails(subjectNum).(['rawPSDStimErr' side]) = rawPSDStimElecErr;
        gammaDetails(subjectNum).(['rawPSDBLErr' side]) = rawPSDBLElecErr;
        
        % Calculate power per trial per band
        for iBand = 1:2
            clear freqGamma bandName
            switch iBand
                case 1
                    freqGamma = LGamma;
                    bandName = 'LGamma';
                case 2
                    freqGamma = TGamma;
                    bandName = 'TGamma';
            end
            
            clear fRangeGamma rawPowerStim rawPowerBL changeInPower
            fRangeGamma =   (fAxis>=freqGamma(1)) & (fAxis<=freqGamma(2));
            rawPowerStim = mean(rawPSDStimElecAllTrials(fRangeGamma,:),1);
            rawPowerBL = mean(rawPSDBLElecAllTrials(fRangeGamma,:),1);
            changeInPower = (10*conv2Log(rawPowerStim./rawPowerBL));
            meanChangeInPower = mean(changeInPower);

            % Run right-tailed paired-t test: Ho: change in power is equal
            % to 1 dB; Ha: change in power is greater than 1 dB
            clear h p
            [h,p]=ttest(changeInPower,1,'Tail','right');
            subplot(plotPlotsHandle(iSide,2)); sigstar({freqGamma},p);
            
            % Save gammaDetails in a struct
            gammaDetails(subjectNum).(['hValue' side bandName]) = h;
            gammaDetails(subjectNum).(['pValue' side bandName]) = p;
            gammaDetails(subjectNum).(['meanChangeInPower' side bandName]) = meanChangeInPower;
        end
        
        text(0.1,0.9,['n=' num2str(totPos)],'unit','normalized','Parent',plotPlotsHandle(iSide,2),'fontsize',9);
        text(0.1,0.8,side,'unit','normalized','Parent',plotPlotsHandle(iSide,2),'fontsize',9);
    end

    if strcmpi(protocolType,'CON'); protocolType = 'Contrast'; end;
    saveFolder = fullfile(dataLog{14,2},'Plots','VisualGammaProject','jackknife',refChan,protocolType);
    makeDirectory(saveFolder);
    savefig(figH,fullfile(saveFolder,[subjectName '.fig']));
    save(fullfile(saveFolder,[subjectName '.mat']));
    close(figH)
    if strcmpi(protocolType,'Contrast'); protocolType = 'CON'; end;
    
    clearvars -except freqBandToPlot LGamma TGamma subjectsToIgnore protocolType refChan ...
        dataLogList subjectNamesUnique subjectNum movingWin tapers BLPeriod STPeriod saveFolder gammaDetails
end

save(fullfile(saveFolder,'gammaDetails.mat'),'gammaDetails');
end