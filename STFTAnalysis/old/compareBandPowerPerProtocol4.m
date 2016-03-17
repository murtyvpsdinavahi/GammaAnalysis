function gammaDataAllElec = compareBandPowerPerProtocol4(dataLog,GammaBand,EEGChannels,refChan,Fs,tapers,BLPeriod,STPeriod)

    if ~exist('GammaBand','var')||isempty(GammaBand); GammaBand = [21 80]; end;
    if ~exist('EEGChannels','var')||isempty(EEGChannels); EEGChannels = dataLog{7, 2}; end;
    if ~exist('refChan','var')||isempty(refChan); refChan = 'Bipolar'; end;
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
    diary(fullfile(folderName,['gammaDataAllElec_' refChan '.txt']));
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
                                                        
                                                        [powerGammaAllElec,peakFreqGammaAllElec] = calculateBandPowerPerProtocol4(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,dataLog,GammaBand,EEGChannels,refChan,Fs,tapers,BLPeriod,STPeriod);
                                                                        
                                                        
                                                        gammaDataAllElec(iLoop).a = a;
                                                        gammaDataAllElec(iLoop).e = e;
                                                        gammaDataAllElec(iLoop).s = s;
                                                        gammaDataAllElec(iLoop).f = f;
                                                        gammaDataAllElec(iLoop).o = o;
                                                        gammaDataAllElec(iLoop).c = c;
                                                        gammaDataAllElec(iLoop).t = t;
                                                        gammaDataAllElec(iLoop).aa = aa;
                                                        gammaDataAllElec(iLoop).ae = ae;
                                                        gammaDataAllElec(iLoop).as = as;
                                                        gammaDataAllElec(iLoop).ao = ao;
                                                        gammaDataAllElec(iLoop).av = av;
                                                        gammaDataAllElec(iLoop).at = at;
                                                        
                                                        gammaDataAllElec(iLoop).powerGammaAllElec = {powerGammaAllElec};
                                                        gammaDataAllElec(iLoop).peakFreqGammaAllElec = {peakFreqGammaAllElec};
                                                                                                                
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
    save(fullfile(folderName,['gammaDataAllElec_' refChan '.mat']),'gammaDataAllElec');    
    disp(['Data saved to ' fullfile(folderName,['gammaDataAllElec_' refChan '.mat'])]); 
    elapsedTime = toc/60;
    disp(['Total time taken for Analysis: ' num2str(elapsedTime) ' min.']);
    diary('off');
end
