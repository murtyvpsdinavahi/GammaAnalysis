function [meanPowerAlphaAllElec,meanMinFreqForConditionAlpha,meanPowerLGAllElec,meanPowerHGAllElec,meanPeakFreqForConditionLG,meanPeakFreqForConditionHG] = calculateBandPowerPerProtocol(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,dataLog,...
    AlphaBand,LGBand,HGBand,desiredBandWidth,EEGChannels,refChan,movingWin,Fs,tapers,BLPeriod,STPeriod)

    if ~exist('AlphaBand','var')||isempty(AlphaBand); AlphaBand = [7 15]; end;
    if ~exist('LGBand','var')||isempty(LGBand); LGBand = [21 50]; end;
    if ~exist('HGBand','var')||isempty(HGBand); HGBand = [51 80]; end;
    if ~exist('desiredBandWidth','var')||isempty(desiredBandWidth); desiredBandWidth = 20; else desiredBandWidth = (ceil(desiredBandWidth/2))*2; end;
    if ~exist('EEGChannels','var')||isempty(EEGChannels); EEGChannels = dataLog{7, 2}; end;
    if ~exist('refChan','var')||isempty(refChan); refChan = 'Bipolar'; end;
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
    
    fBandMinAlpha = AlphaBand(1);
    fBandMaxAlpha = AlphaBand(2);
    fBandMinLG = LGBand(1);
    fBandMaxLG = LGBand(2);
    fBandMinHG = HGBand(1);    
    fBandMaxHG = HGBand(2);
    
    if ischar(refChan)
        refChanIndex = refChan;
    else
        refChanIndex = find(EEGChannelsToPool == refChan);
    end
    
    gridMontage = dataLog{15,2};
    
    clear plotData Data
    [~,folderName]=getFolderDetails(dataLog);
    folderSegment = fullfile(folderName,'segmentedData');
    folderLFP = fullfile(folderSegment,'LFP');
    [~,timeVals] = loadlfpInfo(folderLFP);
    
    [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,EEGChannels);                                                        
    [Data,goodPos] = bipolarRef(plotData,refChanIndex,gridMontage,trialNums,allBadTrials);
    
    numElec = size(Data,1);
    
    % allocate output
    meanPowerAlphaAllElec=zeros(1,numElec);
    meanPowerLGAllElec=zeros(1,numElec);
    meanPowerHGAllElec=zeros(1,numElec);
    
    meanMinFreqForConditionAlpha = zeros(1,numElec);
    meanPeakFreqForConditionLG = zeros(1,numElec);
    meanPeakFreqForConditionHG = zeros(1,numElec);    
    
    hWB = waitbar(0,['Analysing elec ' num2str(1) ' of ' num2str(numElec) ' elecs...']);
    for iElec=1:numElec
%         iElec = 92;
        waitbar((iElec-1)/numElec,hWB,['Analysing elec ' num2str(iElec) ' of ' num2str(numElec) ' elecs...']);
        
        if ~isempty(goodPos{iElec})
        
            % get data for given electrode
            dataTF=squeeze(Data(iElec,goodPos{iElec},:));               

            % TFA; calculate power at all freqs and time points
            [~,diffPower,tAxis,fAxis] = getSTFT(dataTF,movingWin,mtmParams,timeVals,BLMin,BLMax);

            % get time and frequency axes
            tStim =  (tAxis>=STMin) & (tAxis<=STMax);

            fRangeAlpha =   (fAxis>=fBandMinAlpha) & (fAxis<=fBandMaxAlpha);
            fRangeValAlpha = fAxis(fRangeAlpha);
            fRangeLG =   (fAxis>=fBandMinLG) & (fAxis<=fBandMaxLG);
            fRangeValLG = fAxis(fRangeLG);
            fRangeHG = (fAxis>=fBandMinHG) & (fAxis<=fBandMaxHG);
            fRangeValHG = fAxis(fRangeHG);

            % get power values in LG and HG bands
            dPowerAlpha = diffPower(tStim,fRangeAlpha);
            dPowerLG = diffPower(tStim,fRangeLG);
            dPowerHG = diffPower(tStim,fRangeHG);

            % find optimum bandwidths based on power
            meanMinFreqForConditionAlpha(iElec) = findMinBandWidth(dPowerAlpha,fRangeValAlpha);
            fBandAlphaMin = meanMinFreqForConditionAlpha(iElec) - 2;
            fBandAlphaMax = meanMinFreqForConditionAlpha(iElec) + 2;
            fAlphaRange=   (fAxis>=fBandAlphaMin) & (fAxis<=fBandAlphaMax);

            meanPeakFreqForConditionLG(iElec) = findPeakBandWidth(dPowerLG,fRangeValLG);
            fBandLGMin = meanPeakFreqForConditionLG(iElec) - (desiredBandWidth/2-1);
            fBandLGMax = meanPeakFreqForConditionLG(iElec) + (desiredBandWidth/2);
            fLGRange=   (fAxis>=fBandLGMin) & (fAxis<=fBandLGMax);

            meanPeakFreqForConditionHG(iElec) = findPeakBandWidth(dPowerHG,fRangeValHG);        
            fBandHGMin = meanPeakFreqForConditionHG(iElec) - (desiredBandWidth/2-1);
            fBandHGMax = meanPeakFreqForConditionHG(iElec) + (desiredBandWidth/2);        
            fHGRange=   (fAxis>=fBandHGMin) & (fAxis<=fBandHGMax);

            % find mean power in Alpha band
            diffPowerAlpha = diffPower(tStim,fAlphaRange);
            meanPowerAlphaAllElec(iElec)=mean(mean(diffPowerAlpha,2));

            % find mean power in LG band
            diffPowerLG = diffPower(tStim,fLGRange);
            meanPowerLGAllElec(iElec)=mean(mean(diffPowerLG,2));

            % find mean power in HG band
            diffPowerHG = diffPower(tStim,fHGRange);
            meanPowerHGAllElec(iElec)=mean(mean(diffPowerHG,2));
            
        else
            
            disp(['No good trials for electrode ' num2str(iElec) '. Hence putting all values for this electrode for this combination to zero.']);
            meanMinFreqForConditionAlpha(iElec) = 0;
            meanPeakFreqForConditionLG(iElec) = 0;
            meanPeakFreqForConditionHG(iElec) = 0;
            meanPowerAlphaAllElec(iElec) = 0;
            meanPowerLGAllElec(iElec) = 0;
            meanPowerHGAllElec(iElec) = 0;
            
        end
    end
    close(hWB);
    clear hWB;   
end
    



