function AllSubAnalysis(dataLogList,protocolType,subjectIndices,freqBands,refChan)

freqBandToPlot = [0 150];
% Load parameter combinations
protocolIndices = find(strcmpi(protocolType,dataLogList.protocolTypes));
dataLogIndices = intersect(subjectIndices,protocolIndices);

for subjectIndex = 1:length(dataLogIndices)
%     subjectIndex = 2;
    subjectName = dataLogList.subjectNames{1,dataLogIndices(subjectIndex)};
    expDate = dataLogList.expDates{1,dataLogIndices(subjectIndex)};
    protocolName = dataLogList.protocolNames{1,dataLogIndices(subjectIndex)};

    dataLog{1,2} = subjectName;
    dataLog{2,2} = dataLogList.gridType;
    dataLog{3,2} = expDate;
    dataLog{4,2} = protocolName;
    dataLog{14,2} = dataLogList.folderSourceString;

    [~,folderName]=getFolderDetails(dataLog);
    clear dataLog
    load(fullfile(folderName,'dataLog.mat'));

    if ~exist('movingWin','var')||isempty(movingWin); movingWin = [0.4 0.01]; end;
    if ~exist('Fs','var')||isempty(Fs); Fs = dataLog{9, 2}; end;
    if ~exist('tapers','var')||isempty(tapers); tapers = [2 3]; end;
    if ~exist('BLPeriod','var')||isempty(BLPeriod); BLPeriod = [-0.5 0]; end;
    if ~exist('STPeriod','var')||isempty(STPeriod); STPeriod = [0.25 0.75]; end;

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
    [~,~,plotsPos] = getPlotHandles(1,2,figArea,0.01);
    [plotPlotsHandle,~,plotPlotsPos] = getPlotHandles(3,2,plotsPos{1},0.01);

    plotBestElecSTFTHandles = getPlotHandles(1,2,plotPlotsPos{1,1},0.01);
    plotBestElecPSDHandles = getPlotHandles(1,2,plotPlotsPos{1,2},0.01);

    plotAveElecSTFTHandles = getPlotHandles(1,2,plotPlotsPos{2,1},0.01);
    plotAveElecPSDHandles = getPlotHandles(1,2,plotPlotsPos{2,2},0.01);

    plotCommonAveElecSTFTHandles = getPlotHandles(1,2,plotPlotsPos{3,1},0.01);
    plotCommonAveElecPSDHandles = getPlotHandles(1,2,plotPlotsPos{3,2},0.01);

    plotTopoHandle = getPlotHandles(2,1,plotsPos{2},0.01);

    % plotsPos = [0.05 0.05 0.65 0.9]; toposPos = [0.75 0.05 0.2 0.9];
    % plotPlotsPos = getPlotHandles(3,2,plotsPos,0.01);
    % plotTopoPos = getPlotHandles(2,1,toposPos,0.01);

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
    load(fullfile(folderName,['gammaBandDataAllElec_' refChan '.mat']));
    folderExtract = fullfile(folderName,'extractedData');
    
    a = 1; e = 1; s = 1; f = 1; o = 1; c = 1; t = 1; 
    aa = 1; ae = 1; as = 1; ao = 1; av = 1; at = 1;
    
    if strcmpi(protocolType,'SF')
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
    
    

    combMat = [gammaBandDataAllElec.a; gammaBandDataAllElec.e; gammaBandDataAllElec.s; gammaBandDataAllElec.f; gammaBandDataAllElec.o; gammaBandDataAllElec.c; gammaBandDataAllElec.t;...
        gammaBandDataAllElec.aa; gammaBandDataAllElec.ae; gammaBandDataAllElec.as; gammaBandDataAllElec.ao; gammaBandDataAllElec.av; gammaBandDataAllElec.at];
    combMat = combMat';
    index = multiIntersect(find(combMat(:,1) == a), find(combMat(:,2) == e), find(combMat(:,3) == s),...
            find(combMat(:,4) == f), find(combMat(:,5) == o), find(combMat(:,6) == c), find(combMat(:,7) == t),...
            find(combMat(:,8) == aa), find(combMat(:,9) == ae), find(combMat(:,10) == as),...
            find(combMat(:,11) == ao), find(combMat(:,12) == av), find(combMat(:,13) == at));

    % Best Electrode and topoplots
    for iBand = 1:length(freqBands)
    %     iBand = 1;
        freqBand = freqBands{iBand};
        clear peakPower 
        switch freqBand
            case 'AllGamma'
                peakPower = gammaBandDataAllElec(index).changePowerAllGamma{1,1};
            case 'LGamma'
                peakPower = gammaBandDataAllElec(index).changePowerLGamma{1,1};
            case 'TGamma'
                peakPower = gammaBandDataAllElec(index).changePowerHGamma{1,1};
        end

        clear nmaxIndex nmaxIndexOriginal EEGChannelsToExtract
        [commonBipolarEEGChannels,nmaxIndexOriginal] = findIndexNMax(peakPower,1,[81 96],gridMontage,refChan);
        EEGChannelsToExtract = rowCat(nmaxIndexOriginal);

        % Load data
        clear plotData trialNums allBadTrials Data goodPos
        [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,EEGChannelsToExtract);                                                        
        [Data,goodPos] = getRefData(plotData,trialNums,allBadTrials(EEGChannelsToExtract),refChan);
        dataMT=Data(1,goodPos{1},:);
        dataMT=squeeze(dataMT);
        if size(dataMT,1)>size(dataMT,2); dataMT = dataMT'; end;

        % get time axes
        tStim =  (timeVals>STMin) & (timeVals<=STMax);
        tBL = (timeVals>BLMin) & (timeVals<=BLMax);

        % STFT
        mtmParams.trialave=0;
        [~,dSpectrogram,tAxis,fAxis] = getSTFT(dataMT,movingWin,mtmParams,timeVals,BLMin,BLMax);
        subplot(plotBestElecSTFTHandles(iBand)); pcolor(tAxis,fAxis,dSpectrogram'); shading interp; ylim([0 100]); caxis([-3 3]);
        text(0.1,0.9,['Elec: ' num2str(commonBipolarEEGChannels) '; n=' num2str(length(goodPos{1}))],'unit','normalized','Parent',plotBestElecSTFTHandles(iBand),'fontsize',9);
        text(0.1,0.8,freqBand,'unit','normalized','Parent',plotBestElecSTFTHandles(iBand),'fontsize',9);

        % MTFFT  
        mtmParams.trialave=1;
        [rawPSDStimElec,fAxisStim]=mtspectrumc(dataMT(:,tStim)',mtmParams);
        [rawPSDBLElec,fAxisBL]=mtspectrumc(dataMT(:,tBL)',mtmParams);
        clear fAxis;
        if (fAxisStim ~= fAxisBL); error('frequency axes in BL and stim period different'); else fAxis = fAxisStim; end;
        fRangeToPlot =   (fAxis>=freqBandToPlot(1)) & (fAxis<=freqBandToPlot(2));
        fRangeValToPlot = fAxis(fRangeToPlot);
        subplot(plotBestElecPSDHandles(iBand)); plot(fRangeValToPlot,conv2Log(rawPSDStimElec(fRangeToPlot,:)),'linewidth',2,'color','b'); hold on;
        plot(fRangeValToPlot,conv2Log(rawPSDBLElec(fRangeToPlot,:)),'linewidth',2,'color','k'); hold off;
        text(0.1,0.9,['Elec: ' num2str(commonBipolarEEGChannels) '; n=' num2str(length(goodPos{1}))],'unit','normalized','Parent',plotBestElecPSDHandles(iBand),'fontsize',9);
        text(0.1,0.8,freqBand,'unit','normalized','Parent',plotBestElecPSDHandles(iBand),'fontsize',9);

        % Topoplots
        subplot(plotTopoHandle(iBand)); topoplot(peakPower,chanlocs,'electrodes','numbers','style','both','drawaxis','off','nosedir',noseDir);
        text(0.1,0.9,freqBand,'unit','normalized','Parent',plotTopoHandle(iBand),'fontsize',9); colorbar;
    end

    % Pool across average elecs
    for iSide = 1:2 

        switch iSide        
            case 1
                commonBipolarEEGChannels = [81:84 90:92];
                side = 'Left Hemisphere';
            case 2
                commonBipolarEEGChannels = [85:89 93:96];
                side = 'Right Hemisphere';
        end

        [~,~,bipolarLocs] = loadChanLocs(gridMontage,4);        
        commonUnipolarEEGChannels = bipolarLocs(commonBipolarEEGChannels,:);
        EEGChannelsToExtract = rowCat(commonUnipolarEEGChannels);
        % Load data
        clear plotData trialNums allBadTrials Data goodPos
        [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,EEGChannelsToExtract);                                                        
        [Data,goodPos] = getRefData(plotData,trialNums,allBadTrials(EEGChannelsToExtract),refChan);

        % get time axes
        tStim =  (timeVals>STMin) & (timeVals<=STMax);
        tBL = (timeVals>BLMin) & (timeVals<=BLMax);

        dataTFAllElec = [];
        totPos = 0;
        for iCD = 1:size(Data,1)
            dataMT=Data(iCD,goodPos{iCD},:);
            dataMT=squeeze(dataMT);
            if size(dataMT,1)>size(dataMT,2); dataMT = dataMT'; end;
            dataTFAllElec = [dataTFAllElec;dataMT];

            mtmParams.trialave=1;
            rawPSDStimSingleElec(iCD,:)=mtspectrumc(dataMT(:,tStim)',mtmParams);

            totPos = totPos + length(goodPos{iCD});
        end

        % STFT
        mtmParams.trialave=0;
        [~,dSpectrogram,tAxisSpec,fAxisSpec] = getSTFT(dataTFAllElec,movingWin,mtmParams,timeVals,BLMin,BLMax);
        subplot(plotAveElecSTFTHandles(iSide)); pcolor(tAxisSpec,fAxisSpec,dSpectrogram'); shading interp; ylim([0 100]); caxis([-3 3]);
        text(0.1,0.9,['n=' num2str(totPos)],'unit','normalized','Parent',plotAveElecSTFTHandles(iSide),'fontsize',9);
        text(0.1,0.8,side,'unit','normalized','Parent',plotAveElecSTFTHandles(iSide),'fontsize',9);

        % MTFFT  
        mtmParams.trialave=1;
        [rawPSDStimElec,fAxisStim]=mtspectrumc(dataTFAllElec(:,tStim)',mtmParams);
        [rawPSDBLElec,fAxisBL]=mtspectrumc(dataTFAllElec(:,tBL)',mtmParams);
        clear fAxis;
        if (fAxisStim ~= fAxisBL); error('frequency axes in BL and stim period different'); else fAxis = fAxisStim; end;
        fRangeToPlot =   (fAxis>=freqBandToPlot(1)) & (fAxis<=freqBandToPlot(2));
        fRangeValToPlot = fAxis(fRangeToPlot);
        subplot(plotAveElecPSDHandles(iSide)); plot(fRangeValToPlot,conv2Log(rawPSDStimElec(fRangeToPlot,:)),'linewidth',2,'color','b'); hold on;
        plot(fRangeValToPlot,conv2Log(rawPSDStimSingleElec(:,fRangeToPlot)),'linewidth',1,'color',[0.5 0.5 0.5]);
        plot(fRangeValToPlot,conv2Log(rawPSDBLElec(fRangeToPlot,:)),'linewidth',2,'color','k'); hold off;    
        text(0.1,0.9,['n=' num2str(totPos)],'unit','normalized','Parent',plotAveElecPSDHandles(iSide),'fontsize',9);
        text(0.1,0.8,side,'unit','normalized','Parent',plotAveElecPSDHandles(iSide),'fontsize',9);
    end

    % Pool across elecs common to all subjects 
    for iBand = 1:2

        switch freqBand        
            case 1
                commonBipolarEEGChannels = [83 84 92];
                side = 'Left Hemisphere';
            case 2
                commonBipolarEEGChannels = [86 87 94];
                side = 'Right Hemisphere';
        end

        [~,~,bipolarLocs] = loadChanLocs(gridMontage,4);        
        commonUnipolarEEGChannels = bipolarLocs(commonBipolarEEGChannels,:);
        EEGChannelsToExtract = rowCat(commonUnipolarEEGChannels);
        % Load data
        clear plotData trialNums allBadTrials Data goodPos
        [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,EEGChannelsToExtract);                                                        
        [Data,goodPos] = getRefData(plotData,trialNums,allBadTrials(EEGChannelsToExtract),refChan);

        % get time axes
        tStim =  (timeVals>STMin) & (timeVals<=STMax);
        tBL = (timeVals>BLMin) & (timeVals<=BLMax);

        dataTFAllElec = [];
        totPos = 0;
        for iCD = 1:size(Data,1)
            dataMT=Data(iCD,goodPos{iCD},:);
            dataMT=squeeze(dataMT);
            if size(dataMT,1)>size(dataMT,2); dataMT = dataMT'; end;
            dataTFAllElec = [dataTFAllElec;dataMT];

            mtmParams.trialave=1;
            rawPSDStimSingleElec(iCD,:)=mtspectrumc(dataMT(:,tStim)',mtmParams);

            totPos = totPos + length(goodPos{iCD});
        end

        % STFT
        mtmParams.trialave=0;
        [~,dSpectrogram,tAxisSpec,fAxisSpec] = getSTFT(dataTFAllElec,movingWin,mtmParams,timeVals,BLMin,BLMax);
        subplot(plotCommonAveElecSTFTHandles(iBand)); pcolor(tAxisSpec,fAxisSpec,dSpectrogram'); shading interp; ylim([0 100]); caxis([-3 3]);
        text(0.1,0.9,['n=' num2str(totPos)],'unit','normalized','Parent',plotCommonAveElecSTFTHandles(iBand),'fontsize',9);
        text(0.1,0.8,freqBand,'unit','normalized','Parent',plotCommonAveElecSTFTHandles(iBand),'fontsize',9);

        % MTFFT  
        mtmParams.trialave=1;
        [rawPSDStimElec,fAxisStim]=mtspectrumc(dataTFAllElec(:,tStim)',mtmParams);
        [rawPSDBLElec,fAxisBL]=mtspectrumc(dataTFAllElec(:,tBL)',mtmParams);
        clear fAxis;
        if (fAxisStim ~= fAxisBL); error('frequency axes in BL and stim period different'); else fAxis = fAxisStim; end;
        fRangeToPlot =   (fAxis>=freqBandToPlot(1)) & (fAxis<=freqBandToPlot(2));
        fRangeValToPlot = fAxis(fRangeToPlot);
        subplot(plotCommonAveElecPSDHandles(iBand)); plot(fRangeValToPlot,conv2Log(rawPSDStimElec(fRangeToPlot,:)),'linewidth',2,'color','b'); hold on;
        plot(fRangeValToPlot,conv2Log(rawPSDStimSingleElec(:,fRangeToPlot)),'linewidth',1,'color',[0.5 0.5 0.5]);
        plot(fRangeValToPlot,conv2Log(rawPSDBLElec(fRangeToPlot,:)),'linewidth',2,'color','k'); hold off; 
        text(0.1,0.9,['n=' num2str(totPos)],'unit','normalized','Parent',plotCommonAveElecPSDHandles(iBand),'fontsize',9);
        text(0.1,0.8,freqBand,'unit','normalized','Parent',plotCommonAveElecPSDHandles(iBand),'fontsize',9);
    end
    
    if strcmpi(protocolType,'CON'); protocolType = 'Contrast'; end;
    saveFolder = fullfile(dataLog{14,2},'Plots','VisualGammaProject',refChan,protocolType);
    makeDirectory(saveFolder);
    savefig(figH,fullfile(saveFolder,[subjectName '.fig']));
    save(fullfile(saveFolder,[subjectName '.mat']));
    close(figH)
    if strcmpi(protocolType,'Contrast'); protocolType = 'CON'; end;
end
end