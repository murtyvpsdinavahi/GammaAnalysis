function [meanPowerAlphaAllElec,meanMinFreqForConditionAlpha,meanPowerLGAllElec,meanPowerHGAllElec,meanPeakFreqForConditionLG,meanPeakFreqForConditionHG] = calculateMPBandPowerPerCombination(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,dataLog,...
    AlphaBand,LGBand,HGBand,desiredBandWidth,EEGChannels,refChan,BLPeriod,STPeriod,Fs)

    if ~exist('AlphaBand','var')||isempty(AlphaBand); AlphaBand = [7 15]; end;
    if ~exist('LGBand','var')||isempty(LGBand); LGBand = [21 50]; end;
    if ~exist('HGBand','var')||isempty(HGBand); HGBand = [51 80]; end;
    if ~exist('desiredBandWidth','var')||isempty(desiredBandWidth); desiredBandWidth = 20; else desiredBandWidth = (ceil(desiredBandWidth/2))*2; end;
    if ~exist('EEGChannels','var')||isempty(EEGChannels); EEGChannels = dataLog{7, 2}; end;
    if ~exist('refChan','var')||isempty(refChan); refChan = 'Bipolar'; end;
    if ~exist('BLPeriod','var')||isempty(BLPeriod); BLPeriod = [-0.5 0]; end;
    if ~exist('STPeriod','var')||isempty(STPeriod); STPeriod = [0.25 0.75]; end;
    if ~exist('Fs','var')||isempty(Fs); Fs = dataLog{9, 2}; end;
    
    gridMontage = dataLog{15,2};
    
    if strcmp(refChan,'Bipolar')
        [~,~,chanLocs] = loadChanLocs(gridMontage,4);
    else
        chanLocs = loadChanLocs(gridMontage);
    end
    
    [~,folderName]=getFolderDetails(dataLog);    
    load(fullfile(folderName,['MPSpectrumAllElec_' refChan '.mat']));
    combMat = [MPSpectrumAllElec.a; MPSpectrumAllElec.e; MPSpectrumAllElec.s; MPSpectrumAllElec.f; MPSpectrumAllElec.o; MPSpectrumAllElec.c; MPSpectrumAllElec.t;...
        MPSpectrumAllElec.aa; MPSpectrumAllElec.ae; MPSpectrumAllElec.as; MPSpectrumAllElec.ao; MPSpectrumAllElec.av; MPSpectrumAllElec.at];
    combMat = combMat';
    
    mpIndex = multiIntersect(find(combMat(:,1) == a), find(combMat(:,2) == e), find(combMat(:,3) == s),...
        find(combMat(:,4) == f), find(combMat(:,5) == o), find(combMat(:,6) == c), find(combMat(:,7) == t),...
        find(combMat(:,8) == aa), find(combMat(:,9) == ae), find(combMat(:,10) == as),...
        find(combMat(:,11) == ao), find(combMat(:,12) == av), find(combMat(:,13) == at));

    folderMP = MPSpectrumAllElec(mpIndex).folderMP;
    load(fullfile(folderMP,'MPExtractionInfo.mat'));
    timeVals = MPExtractionInfo{2, 2};
    freqAxis = MPExtractionInfo{1, 2};
    conversionFactor = MPExtractionInfo{6, 2};
    
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
    
    blL = find(timeVals>=BLMin,1);           % lower index of baseline
    blU = find(timeVals<BLMax,1,'last');     % upper index of baseline
    
    % get time and frequency axes
    tStim =  (timeVals>=STMin) & (timeVals<=STMax);

    fRangeAlpha =   (freqAxis>=fBandMinAlpha) & (freqAxis<=fBandMaxAlpha);
    fRangeValAlpha = freqAxis(fRangeAlpha);
    fRangeLG =   (freqAxis>=fBandMinLG) & (freqAxis<=fBandMaxLG);
    fRangeValLG = freqAxis(fRangeLG);
    fRangeHG = (freqAxis>=fBandMinHG) & (freqAxis<=fBandMaxHG);
    fRangeValHG = freqAxis(fRangeHG);
            
    numElec = size(chanLocs,1);
    
    % allocate output
    meanPowerAlphaAllElec=zeros(1,numElec);
    meanPowerLGAllElec=zeros(1,numElec);
    meanPowerHGAllElec=zeros(1,numElec);
    
    meanMinFreqForConditionAlpha = zeros(1,numElec);
    meanPeakFreqForConditionLG = zeros(1,numElec);
    meanPeakFreqForConditionHG = zeros(1,numElec);    
    
    hWB = waitbar(0,['Analysing elec ' num2str(1) ' of ' num2str(numElec) ' elecs...']);
%     for iElec=1:numElec
        iElec = 92;
        waitbar((iElec-1)/numElec,hWB,['Analysing elec ' num2str(iElec) ' of ' num2str(numElec) ' elecs...']);
        clear rawEnergy diffPower baselineEnergy dPowerAlpha dPowerLG dPowerHG 
        clear fBandAlphaMin fBandAlphaMax fAlphaRange 
        clear fBandLGMin fBandLGMax fLGRange
        clear fBandHGMin fBandHGMax fHGRange
        clear diffPowerAlpha diffPowerLG diffPowerHG
            % get MP Spectrum for the given electrode
            rawEnergy = loadMPSpectrum(folderMP,iElec,conversionFactor);
            
            % calculate diffPower from spectrum            
            baselineEnergy=mean(rawEnergy(:,blL:blU),2);        % baseline TF Energy Matrix
            diffPower = 10*(rawEnergy-repmat(baselineEnergy,1,size(rawEnergy,2))); % change in dB
            diffPower = diffPower';            

            % get power values in LG and HG bands
            dPowerAlpha = diffPower(tStim,fRangeAlpha);
            dPowerLG = diffPower(tStim,fRangeLG);
            dPowerHG = diffPower(tStim,fRangeHG);

            % find optimum bandwidths based on power
            meanMinFreqForConditionAlpha(iElec) = findMinBandWidth(dPowerAlpha,fRangeValAlpha);
            fBandAlphaMin = meanMinFreqForConditionAlpha(iElec) - 2;
            fBandAlphaMax = meanMinFreqForConditionAlpha(iElec) + 2;
            fAlphaRange=   (freqAxis>=fBandAlphaMin) & (freqAxis<=fBandAlphaMax);

            meanPeakFreqForConditionLG(iElec) = findPeakBandWidth(dPowerLG,fRangeValLG);
            fBandLGMin = meanPeakFreqForConditionLG(iElec) - (desiredBandWidth/2-1);
            fBandLGMax = meanPeakFreqForConditionLG(iElec) + (desiredBandWidth/2);
            fLGRange=   (freqAxis>=fBandLGMin) & (freqAxis<=fBandLGMax);

            meanPeakFreqForConditionHG(iElec) = findPeakBandWidth(dPowerHG,fRangeValHG);        
            fBandHGMin = meanPeakFreqForConditionHG(iElec) - (desiredBandWidth/2-1);
            fBandHGMax = meanPeakFreqForConditionHG(iElec) + (desiredBandWidth/2);        
            fHGRange=   (freqAxis>=fBandHGMin) & (freqAxis<=fBandHGMax);

            % find mean power in Alpha band
            diffPowerAlpha = diffPower(tStim,fAlphaRange);
            meanPowerAlphaAllElec(iElec)=mean(mean(diffPowerAlpha,2));

            % find mean power in LG band
            diffPowerLG = diffPower(tStim,fLGRange);
            meanPowerLGAllElec(iElec)=mean(mean(diffPowerLG,2));

            % find mean power in HG band
            diffPowerHG = diffPower(tStim,fHGRange);
            meanPowerHGAllElec(iElec)=mean(mean(diffPowerHG,2));
            
%     end
    close(hWB);
    clear hWB;   
end
    



