function [dPower,fRangeVal] = calculateMPPSDPerCombinationPerElectrode(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,dataLog,EEGChannels,...
    freqBand,refChan,BLPeriod,STPeriod,downSampleSize)

    if ~exist('freqBand','var')||isempty(freqBand); freqBand = [0 150]; end;
%     if ~exist('EEGChannels','var')||isempty(EEGChannels); EEGChannels = dataLog{7, 2}; end;
    if ~exist('refChan','var')||isempty(refChan); refChan = 'Bipolar'; end;
    if ~exist('BLPeriod','var')||isempty(BLPeriod); BLPeriod = [-0.5 0]; end;
    if ~exist('STPeriod','var')||isempty(STPeriod); STPeriod = [0.25 0.75]; end;
    if ~exist('downSampleSize','var')||isempty(downSampleSize); downSampleSize = 1; end;
    
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
    
    blL = find(timeVals>=BLMin,1);           % lower index of baseline
    blU = find(timeVals<BLMax,1,'last');     % upper index of baseline
    
    % get time and frequency axes
    tStim =  (timeVals>=STMin) & (timeVals<=STMax);

    fRange =   (freqAxis>=freqBand(1)) & (freqAxis<=freqBand(2));
    fRangeVal = downsample(freqAxis(fRange),downSampleSize);
    
    iElec = EEGChannels;
    % get MP Spectrum for the given electrode
    rawEnergy = loadMPSpectrum(folderMP,iElec,conversionFactor);

    % calculate diffPower from spectrum            
    baselineEnergy=mean(rawEnergy(:,blL:blU),2);        % baseline TF Energy Matrix
    diffPower = 10*(rawEnergy-repmat(baselineEnergy,1,size(rawEnergy,2))); % change in dB
    diffPower = diffPower';            

    % get power values in LG and HG bands
    dPower = downsample(mean(diffPower(tStim,fRange),1),downSampleSize);  
end