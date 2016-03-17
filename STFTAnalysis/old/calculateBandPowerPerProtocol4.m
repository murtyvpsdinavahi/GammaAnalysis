function [powerGammaAllElec,peakFreqForConditionGamma] = calculateBandPowerPerProtocol4(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,dataLog,lowGamma,highGamma,EEGChannels,refChan,Fs,tapers,BLPeriod,STPeriod)

    if ~exist('GammaBand','var')||isempty(lowGamma); lowGamma = [21 40]; end;
    if ~exist('GammaBand','var')||isempty(highGamma); highGamma = [41 70]; end;
    if ~exist('EEGChannels','var')||isempty(EEGChannels); EEGChannels = dataLog{7, 2}; end;
    if ~exist('refChan','var')||isempty(refChan); refChan = 'Bipolar'; end;
    if ~exist('Fs','var')||isempty(Fs); Fs = dataLog{9, 2}; end;
    if ~exist('tapers','var')||isempty(tapers); tapers = [2 3]; end;
    if ~exist('BLPeriod','var')||isempty(BLPeriod); BLPeriod = [-0.5 0]; end;
    if ~exist('STPeriod','var')||isempty(STPeriod); STPeriod = [0.25 0.75]; end;
    
    mtmParams.Fs = Fs;
    mtmParams.tapers = tapers;
    mtmParams.trialave=1;
    mtmParams.err=0;
    mtmParams.pad=-1;
    
    BLMin = BLPeriod(1);
    BLMax = BLPeriod(2);
    STMin = STPeriod(1);
    STMax = STPeriod(2);
    
    fBandMinLGamma = lowGamma(1);
    fBandMaxLGamma = lowGamma(2);
    fBandMinHGamma = highGamma(1);
    fBandMaxHGamma = highGamma(2);
    
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
    
    hWB = waitbar(0,['Analysing elec ' num2str(1) ' of ' num2str(numElec) ' elecs...']);
    for iElec=1:numElec
%         iElec = 24;
        waitbar((iElec-1)/numElec,hWB,['Analysing elec ' num2str(iElec) ' of ' num2str(numElec) ' elecs...']);
        
        if ~isempty(goodPos{iElec})
        
            % get data for given electrode
            dataTF=squeeze(Data(iElec,goodPos{iElec},:));
            
            if size(dataTF,2) ~= length(timeVals) && size(dataTF,1) == length(timeVals)
                dataTF = dataTF';
            end

            % get time and frequency axes
            tStim =  (timeVals>STMin) & (timeVals<=STMax);
            tBL = (timeVals>BLMin) & (timeVals<=BLMax);

            % calculate MTFFT in stim and BL periods
            [rawPSDStim,fAxisStim]=mtspectrumc(dataTF(:,tStim)',mtmParams);
            [rawPSDBL,fAxisBL]=mtspectrumc(dataTF(:,tBL)',mtmParams);
            
            if (fAxisStim ~= fAxisBL); error('frequency axes in BL and stim period different'); else fAxis = fAxisStim; end;
            
            % define frequency axes
            fRangeLGamma =   (fAxis>=fBandMinLGamma) & (fAxis<=fBandMaxLGamma);
            fRangeValLGamma = fAxis(fRangeLGamma); 
            
            fRangeHGamma =   (fAxis>=fBandMinHGamma) & (fAxis<=fBandMaxHGamma);
            fRangeValHGamma = fAxis(fRangeHGamma);
            
            % Calculate change in gamma power (1st band)
            rawPowerStimLGamma = trapz(fRangeValLGamma,rawPSDStim(fRangeLGamma));
            rawPowerBLLGamma = trapz(fRangeValLGamma,rawPSDBL(fRangeLGamma));
            changePowerLGamma = 10*conv2Log(rawPowerStimLGamma./rawPowerBLLGamma);
            
            changeLGammaPSD = 10*conv2Log(rawPSDStim(fRangeLGamma)./rawPSDBL(fRangeLGamma));
            [powerGammaAllElec(iElec),maxFreqIndex] = max(changeLGammaPSD);
            peakFreqForConditionGamma(iElec) = fRangeValLGamma(maxFreqIndex);
            
%             plot(fRangeValGamma,changeGammaPSD); ylim([0 10]);
        else            
            disp(['No good trials for electrode ' num2str(iElec) '. Hence putting all values for this electrode for this combination to zero.']);
            powerGammaAllElec(iElec) = 0;
            peakFreqForConditionGamma(iElec) = 0;
        end
    end
    close(hWB);
    clear hWB;   
end
    



