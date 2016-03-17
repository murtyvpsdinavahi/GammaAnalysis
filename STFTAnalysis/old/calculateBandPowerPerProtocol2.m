% function [meanPowerAlphaAllElec,meanMinFreqForConditionAlpha,meanPowerGammaAllElec,meanPowerHGAllElec,meanPeakFreqForConditionGamma,meanPeakFreqForConditionHG] = calculateBandPowerPerProtocol2(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,dataLog,...
%     AlphaBand,GammaBand,~,desiredBandWidth,EEGChannels,refChan,movingWin,Fs,tapers,BLPeriod,STPeriod)

    if ~exist('AlphaBand','var')||isempty(AlphaBand); AlphaBand = [7 15]; end;
    if ~exist('GammaBand','var')||isempty(GammaBand); GammaBand = [21 80]; end;
%     if ~exist('HGBand','var')||isempty(HGBand); HGBand = [51 80]; end;
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
    
    fBand = [0 150];
    fBandMinAlpha = AlphaBand(1);
    fBandMaxAlpha = AlphaBand(2);
    fBandMinGamma = GammaBand(1);
    fBandMaxGamma = GammaBand(2);
%     fBandMinHG = HGBand(1);    
%     fBandMaxHG = HGBand(2);
    
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
%%
    numElec = size(Data,1);
    
    % allocate output
    meanPowerAlphaAllElec=zeros(1,numElec);
    meanPowerGammaAllElec=zeros(1,numElec);
%     meanPowerHGAllElec=zeros(1,numElec);
    
    meanMinFreqForConditionAlpha = zeros(1,numElec);
    meanPeakFreqForConditionGamma = zeros(1,numElec);
%     meanPeakFreqForConditionHG = zeros(1,numElec);    
    
    hWB = waitbar(0,['Analysing elec ' num2str(1) ' of ' num2str(numElec) ' elecs...']);
%     for iElec=1:numElec
%         iElec = 92;
        waitbar((iElec-1)/numElec,hWB,['Analysing elec ' num2str(iElec) ' of ' num2str(numElec) ' elecs...']);
        
%         if ~isempty(goodPos{iElec})
        
            % get data for given electrode
            dataTF=squeeze(Data(iElec,goodPos{iElec},:));               

%             % TFA; calculate power at all freqs and time points
            [~,diffPower,tAxis,fAxis,rawPower] = getSTFT((dataTF),movingWin,mtmParams,timeVals,BLMin,BLMax);
            
%             figure; pcolor(tAxis,fAxis,diffPower'); shading interp;

            % get time and frequency axes
            tStim =  (tAxis>STMin) & (tAxis<=STMax);
            tBL = (tAxis>BLMin) & (tAxis<=BLMax);
            
            fRange = (fAxis>=fBand(1)) & (fAxis<=fBand(2));
            fRangeVal = fAxis(fRange);
            fRangeAlpha =   (fAxis>=fBandMinAlpha) & (fAxis<=fBandMaxAlpha);
            fRangeValAlpha = fAxis(fRangeAlpha);
            fRangeGamma =   (fAxis>=fBandMinGamma) & (fAxis<=fBandMaxGamma);
            fRangeValGamma = fAxis(fRangeGamma);
%             fRangeHG = (fAxis>=fBandMinHG) & (fAxis<=fBandMaxHG);
%             fRangeValHG = fAxis(fRangeHG);

            
    
            rawPSDStim = trapz(tAxis(tStim),rawPower(tStim,fRange),1);
            rawPSDBL = trapz(tAxis(tBL),rawPower(tBL,fRange),1);
            
            rawMeanPSDStim = mean(rawPower(tStim,fRange),1);
            rawMeanPSDBL = mean(rawPower(tBL,fRange),1);
            
            [p20,~,mu20] = polyfit(fRangeVal,(conv2Log(rawPSDStim./rawPSDBL)),20);
            x20 = linspace(fRangeVal(1),fRangeVal(end),1000);
            y20 = polyval(p20,x20,[],mu20);
            [LocalMax,LocalMin,fVMax,fVMin] = SignalExtrema(y20,x20);
            
            [LocalMax,LocalMin,fVMax,fVMin] = SignalExtrema((rawPSDStim./rawPSDBL),fRangeVal);
            
                       
%             figure; plot(fRangeVal,conv2Log(rawPSDStim./rawPSDBL),'b'); hold on;
%             plot(fRangeVal,conv2Log(rawPSDStim),'r'); hold on;
%             plot(fRangeVal,conv2Log(rawPSDBL),'k'); hold off;
%
%             plot(fRangeVal,conv2Log(rawMeanPSDStim./rawMeanPSDBL),'b'); hold on;
%             plot(fRangeVal,conv2Log(rawMeanPSDStim),'r'); hold on;
%             plot(fRangeVal,conv2Log(rawMeanPSDBL),'k'); hold off;
            
            % Define gamma bumps
            peakGammaBumpIndices = find((fVMax>=fBandMinGamma) & (fVMax<fBandMaxGamma));
            
            for iBump = 1:length(peakGammaBumpIndices)
                gamma(iElec).numberOfBumps = length(peakGammaBumpIndices);
                gamma(iElec).(['bump' num2str(iBump)]).peakFrequency = fVMax(peakGammaBumpIndices(iBump));
                gamma(iElec).(['bump' num2str(iBump)]).width = [fVMin(peakGammaBumpIndices(iBump)),fVMin(peakGammaBumpIndices(iBump)+1)];
                
                freqIndices = find(fRangeVal>=fVMin(peakGammaBumpIndices(iBump)),1,'first'):find(fRangeVal<=fVMin(peakGammaBumpIndices(iBump)+1),1,'last');
                gammaEnergyStim = trapz(fRangeVal(freqIndices),(rawPSDStim(freqIndices)));
                gammaEnergyBL = trapz(fRangeVal(freqIndices),(rawPSDBL(freqIndices)));
                gamma(iElec).(['bump' num2str(iBump)]).meanPowerGamma = 10*conv2Log(gammaEnergyStim/gammaEnergyBL);
            end
            
            % Calculate change in alpha power
            
            % Calculate change in gamma power
%             rawEnergyStimGamma = trapz(fRangeValGamma,trapz(tAxis(tStim),rawPower(tStim,fRangeGamma),1));
%             rawEnergyBLGamma = trapz(fRangeValGamma,trapz(tAxis(tBL),rawPower(tBL,fRangeGamma),1));            
%             meanPowerGammaAllElec(iElec) = 10*conv2Log(rawEnergyStimGamma/rawEnergyBLGamma);
            
            %
%         else
%             
%             disp(['No good trials for electrode ' num2str(iElec) '. Hence putting all values for this electrode for this combination to zero.']);
%             meanMinFreqForConditionAlpha(iElec) = 0;
%             meanPeakFreqForConditionGamma(iElec) = 0;
%             meanPeakFreqForConditionHG(iElec) = 0;
%             meanPowerAlphaAllElec(iElec) = 0;
%             meanPowerGammaAllElec(iElec) = 0;
%             meanPowerHGAllElec(iElec) = 0;
%             
%         end
%     end
    close(hWB);
    clear hWB;   
% end
    



