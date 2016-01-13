function calculateMPSpectrumPerProtocol(dataLog,parallelFlag,refChan,Max_iterations,freqRange,timeRange,wrap)

    % Define defaults
    if ~exist('refChan','var') || isempty(refChan); refChan = 'Bipolar'; end
    if ~exist('Max_iterations','var') || isempty(Max_iterations); Max_iterations = 100; end    
    if ~exist('freqRange','var') || isempty(freqRange); freqRange = [0 250]; end
    if ~exist('timeRange','var') || isempty(timeRange); timeRange = [-0.5 1.5]; end
    if ~exist('wrap','var') || isempty(wrap); wrap = 1; end
    if ~exist('parallelFlag','var') || isempty(parallelFlag); parallelFlag = 1; end
    
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
    diary(fullfile(folderName,['MPSpectrumAllElec_' refChan '.txt']));
    disp(['Total Combinations: ' num2str(totLen)]);
    hW = waitbar(0,['Calculating MP Spectrum for combination 1 of ' num2str(totLen)],'position',[465.0000  409.7500  270.0000   56.2500]);
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
                                                        
                                                        waitbar((iLoop-1)/totLen,hW,['Calculating MP Spectrum for combination ' num2str(iLoop) ' of ' num2str(totLen)]);
                                                        
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
                                                        
                                                        if parallelFlag
                                                            folderMP = parCalculateAndSaveMPSpectrumPerCombination(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,dataLog,...
                                                                refChan,Max_iterations,wrap,freqRange,timeRange);
                                                        else
                                                            folderMP = calculateAndSaveMPSpectrumPerCombination(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,dataLog,...
                                                                refChan,Max_iterations,wrap,freqRange,timeRange);
                                                        end
                                                        
                                                        MPSpectrumAllElec(iLoop).a = a;
                                                        MPSpectrumAllElec(iLoop).e = e;
                                                        MPSpectrumAllElec(iLoop).s = s;
                                                        MPSpectrumAllElec(iLoop).f = f;
                                                        MPSpectrumAllElec(iLoop).o = o;
                                                        MPSpectrumAllElec(iLoop).c = c;
                                                        MPSpectrumAllElec(iLoop).t = t;
                                                        MPSpectrumAllElec(iLoop).aa = aa;
                                                        MPSpectrumAllElec(iLoop).ae = ae;
                                                        MPSpectrumAllElec(iLoop).as = as;
                                                        MPSpectrumAllElec(iLoop).ao = ao;
                                                        MPSpectrumAllElec(iLoop).av = av;
                                                        MPSpectrumAllElec(iLoop).at = at;
                                                        
                                                        MPSpectrumAllElec(iLoop).folderMP = folderMP;                                                        
                                                                                                                
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
    save(fullfile(folderName,['MPSpectrumAllElec_' refChan '.mat']),'MPSpectrumAllElec');    
    disp(['Data saved to ' fullfile(folderName,['MPSpectrumAllElec_' refChan '.mat'])]); 
    elapsedTime = toc/60;
    disp(['Total time taken for Analysis: ' num2str(elapsedTime) ' min.']);
    diary('off');
end
