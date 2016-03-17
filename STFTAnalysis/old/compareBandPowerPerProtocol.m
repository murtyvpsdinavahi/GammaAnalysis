function analysedDataAllElec = compareBandPowerPerProtocol(dataLog,AlphaBand,LGBand,HGBand,desiredBandWidth,EEGChannels,refChan,movingWin,Fs,tapers,BLPeriod,STPeriod)

    if ~exist('AlphaBand','var')||isempty(AlphaBand); AlphaBand = [7 15]; end;
    if ~exist('LGBand','var')||isempty(LGBand); LGBand = [21 50]; end;
    if ~exist('HGBand','var')||isempty(HGBand); HGBand = [51 80]; end;
    if ~exist('desiredBandWidth','var')||isempty(desiredBandWidth); desiredBandWidth = 20; else desiredBandWidth = (floor(desiredBandWidth/2))*2; end;
    if ~exist('EEGChannels','var')||isempty(EEGChannels); EEGChannels = dataLog{7, 2}; end;
    if ~exist('refChan','var')||isempty(refChan); refChan = 'Bipolar'; end;
    if ~exist('movingWin','var')||isempty(movingWin); movingWin = [0.4 0.01]; end;
    if ~exist('Fs','var')||isempty(Fs); Fs = dataLog{9, 2}; end;
    if ~exist('tapers','var')||isempty(tapers); tapers = [2 3]; end;
    if ~exist('BLPeriod','var')||isempty(BLPeriod); BLPeriod = [-0.5 0]; end;
    if ~exist('STPeriod','var')||isempty(STPeriod); STPeriod = [0.25 0.75]; end;
    
    [~,folderName]=getFolderDetails(dataLog);
    folderExtract = fullfile(folderName,'extractedData');    
    [~,aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,cValsUnique,tValsUnique,aaValsUnique,...
        aeValsUnique,asValsUnique,aoValsUnique,avValsUnique,atValsUnique] = loadParameterCombinations(folderExtract);
    
    aLen = length(aValsUnique);
    eLen = length(eValsUnique);
    sLen = length(sValsUnique);
    fLen = length(fValsUnique);
    oLen = length(oValsUnique);
    cLen = length(cValsUnique);
    tLen = length(tValsUnique);
    aaLen = length(aaValsUnique);
    aeLen = length(aeValsUnique);
    asLen = length(asValsUnique);
    aoLen = length(aoValsUnique);
    avLen = length(avValsUnique);
    atLen = length(atValsUnique);
    
    totLen = aLen*eLen*sLen*fLen*oLen*cLen*tLen*aaLen*aeLen*asLen*aoLen*avLen*atLen;
    iLoop = 1;
    
    tic;
    diary(fullfile(folderName,['analysedDataAllElec_' refChan '.txt']));
    disp(['Total Combinations: ' num2str(totLen)]);
    hW = waitbar(0,['Calculating band power for combination 1 of ' num2str(totLen)],'position',[465.0000  409.7500  270.0000   56.2500]);
    for a=1:aLen
        for e=1:eLen
            for s=1:sLen
                for f=1:fLen
                    for o=1:oLen
                        for c=1:cLen
                            for t=1:tLen
                                for aa=1:aaLen
                                    for ae=1:aeLen
                                        for as=1:asLen
                                            for ao=1:aoLen
                                                for av=1:avLen
                                                    for at=1:atLen
                                                        
                                                        waitbar((iLoop-1)/totLen,hW,['Calculating band power for combination ' num2str(iLoop) ' of ' num2str(totLen)]);
                                                        
                                                        disp([char(10) 'Combination: ']);
                                                        disp(['a = ' num2str(a) ' | ' num2str(aValsUnique(a))]);
                                                        disp(['e = ' num2str(e) ' | ' num2str(eValsUnique(e))]);
                                                        disp(['s = ' num2str(s) ' | ' num2str(sValsUnique(s))]);
                                                        disp(['f = ' num2str(f) ' | ' num2str(fValsUnique(f))]);
                                                        disp(['o = ' num2str(o) ' | ' num2str(oValsUnique(o))]);
                                                        disp(['c = ' num2str(c) ' | ' num2str(cValsUnique(c))]);
                                                        disp(['t = ' num2str(t) ' | ' num2str(tValsUnique(t))]);
                                                        disp(['aa = ' num2str(aa) ' | ' num2str(aaValsUnique(aa))]);
                                                        disp(['ae = ' num2str(ae) ' | ' num2str(aeValsUnique(ae))]);
                                                        disp(['as = ' num2str(as) ' | ' num2str(asValsUnique(as))]);
                                                        disp(['ao = ' num2str(ao) ' | ' num2str(aoValsUnique(ao))]);
                                                        disp(['av = ' num2str(av) ' | ' num2str(avValsUnique(av))]);
                                                        disp(['at = ' num2str(at) ' | ' num2str(atValsUnique(at))]);                                                        
                                                        
                                                        [meanPowerAlphaAllElec,meanMinFreqForConditionAlpha,meanPowerLGAllElec,meanPowerHGAllElec,meanPeakFreqForConditionLG,meanPeakFreqForConditionHG] = calculateBandPowerPerProtocol(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,dataLog,...
                                                                            AlphaBand,LGBand,HGBand,desiredBandWidth,EEGChannels,refChan,movingWin,Fs,tapers,BLPeriod,STPeriod);                                                                        
                                                        
                                                        analysedDataAllElec(iLoop).a = a;
                                                        analysedDataAllElec(iLoop).e = e;
                                                        analysedDataAllElec(iLoop).s = s;
                                                        analysedDataAllElec(iLoop).f = f;
                                                        analysedDataAllElec(iLoop).o = o;
                                                        analysedDataAllElec(iLoop).c = c;
                                                        analysedDataAllElec(iLoop).t = t;
                                                        analysedDataAllElec(iLoop).aa = aa;
                                                        analysedDataAllElec(iLoop).ae = ae;
                                                        analysedDataAllElec(iLoop).as = as;
                                                        analysedDataAllElec(iLoop).ao = ao;
                                                        analysedDataAllElec(iLoop).av = av;
                                                        analysedDataAllElec(iLoop).at = at;
                                                        
                                                        analysedDataAllElec(iLoop).meanPowerAllElecAlpha = {meanPowerAlphaAllElec};
                                                        analysedDataAllElec(iLoop).meanPowerAllElecLG = {meanPowerLGAllElec};
                                                        analysedDataAllElec(iLoop).meanPowerAllElecHG = {meanPowerHGAllElec};
                                                        analysedDataAllElec(iLoop).meanMinFreqAllElecAlpha = {meanMinFreqForConditionAlpha};
                                                        analysedDataAllElec(iLoop).meanPeakFreqAllElecLG = {meanPeakFreqForConditionLG};
                                                        analysedDataAllElec(iLoop).meanPeakFreqAllElecHG = {meanPeakFreqForConditionHG};
                                                        
                                                        disp(['Done...']);
                                                        iLoop = iLoop + 1;
        
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    close(hW);
    save(fullfile(folderName,['analysedDataAllElec_' refChan '.mat']),'analysedDataAllElec');    
    disp(['Data saved to ' fullfile(folderName,['analysedDataAllElec_' refChan '.mat'])]); 
    elapsedTime = toc/60;
    disp(['Total time taken for Analysis: ' num2str(elapsedTime) ' min.']);
    diary('off');
end
