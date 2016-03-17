function BestEEGChans = plotSpectrogramPoolElec_02(dataLog,gammaBand,refChan,EEGChannelsToPlot,movingWin,BLPeriod,STPeriod,tapers,Fs)

if ~exist('dataLog','var')
    try
        dataLog = evalin('base','dataLog');
    catch
        fileExt = {'*.mat'};
        [hdrfile,path] = uigetfile(fileExt, 'Select dataLog file...');
        if hdrfile(1) == 0, return; end
        fname = fullfile(path,hdrfile);
        dataL = load(fname);
        dataLog = dataL.dataLog;
    end
end

if ~exist('gammaBand','var')||isempty(gammaBand); gammaBand = 'Low Gamma'; end;
if ~exist('refChan','var')||isempty(refChan); refChan = 'Bipolar'; end;
% if ~exist('EEGChannelsToPlot','var')||isempty(EEGChannelsToPlot); EEGChannelsToPlot = []; end;

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

desiredBandWidth = 20;

gridMontage = dataLog{15,2};
clear plotData Data
[~,folderName]=getFolderDetails(dataLog);
folderSegment = fullfile(folderName,'segmentedData');
folderLFP = fullfile(folderSegment,'LFP');
[~,timeVals] = loadlfpInfo(folderLFP);

% load(fullfile(folderName,['analysedDataAllElec_' refChan '.mat']));
load(fullfile(folderName,['gammaBandDataAllElec_' refChan '.mat']));

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


xAxis = [];
yAxis = [];

% Variable 1: xAxis
if aLen > 1 && isempty(xAxis); xAxis = aValsUnique; xTitle = 'Azi'; end
if eLen > 1 && isempty(xAxis); xAxis = eValsUnique; xTitle = 'Elev'; end
if sLen > 1 && isempty(xAxis); xAxis = sValsUnique; xTitle = 'Size'; end
if fLen > 1 && isempty(xAxis); xAxis = fValsUnique; xTitle = 'SF'; end
if oLen > 1 && isempty(xAxis); xAxis = oValsUnique; xTitle = 'Ori'; end
if cLen > 1 && isempty(xAxis); xAxis = cValsUnique; xTitle = 'Con'; end
if tLen > 1 && isempty(xAxis); xAxis = tValsUnique; xTitle = 'TF'; end
if aaLen > 1 && isempty(xAxis); xAxis = aaValsUnique; xTitle = 'Aud Azi'; end
if aeLen > 1 && isempty(xAxis); xAxis = aeValsUnique; xTitle = 'Aud Elev'; end
if asLen > 1 && isempty(xAxis); xAxis = asValsUnique; xTitle = 'RF'; end
if aoLen > 1 && isempty(xAxis); xAxis = aoValsUnique; xTitle = 'RP'; end
if avLen > 1 && isempty(xAxis); xAxis = avValsUnique; xTitle = 'Rip Vol'; end
if atLen > 1 && isempty(xAxis); xAxis = atValsUnique; xTitle = 'Rip Vel'; end

% Variable 2: yAxis
if aLen > 1; yAxis = aValsUnique; yTitle = 'Azi'; end
if eLen > 1; yAxis = eValsUnique; yTitle = 'Elev'; end
if sLen > 1; yAxis = sValsUnique; yTitle = 'Size'; end
if fLen > 1; yAxis = fValsUnique; yTitle = 'SF'; end
if oLen > 1; yAxis = oValsUnique; yTitle = 'Ori'; end
if cLen > 1; yAxis = cValsUnique; yTitle = 'Con'; end
if tLen > 1; yAxis = tValsUnique; yTitle = 'TF'; end
if aaLen > 1; yAxis = aaValsUnique; yTitle = 'Aud Azi'; end
if aeLen > 1; yAxis = aeValsUnique; yTitle = 'Aud Elev'; end
if asLen > 1; yAxis = asValsUnique; yTitle = 'RF'; end
if aoLen > 1; yAxis = aoValsUnique; yTitle = 'RP'; end
if avLen > 1; yAxis = avValsUnique; yTitle = 'Rip Vol'; end
if atLen > 1; yAxis = atValsUnique; yTitle = 'Rip Vel'; end
    
% combMat = [analysedDataAllElec.a; analysedDataAllElec.e; analysedDataAllElec.s; analysedDataAllElec.f; analysedDataAllElec.o; analysedDataAllElec.c; analysedDataAllElec.t;...
%     analysedDataAllElec.aa; analysedDataAllElec.ae; analysedDataAllElec.as; analysedDataAllElec.ao; analysedDataAllElec.av; analysedDataAllElec.at];
combMat = [gammaBandDataAllElec.a; gammaBandDataAllElec.e; gammaBandDataAllElec.s; gammaBandDataAllElec.f; gammaBandDataAllElec.o; gammaBandDataAllElec.c; gammaBandDataAllElec.t;...
    gammaBandDataAllElec.aa; gammaBandDataAllElec.ae; gammaBandDataAllElec.as; gammaBandDataAllElec.ao; gammaBandDataAllElec.av; gammaBandDataAllElec.at];
combMat = combMat';

totLen = aLen*eLen*sLen*fLen*oLen*cLen*tLen*aaLen*aeLen*asLen*aoLen*avLen*atLen;
if isprime(totLen);
    xNum = max(factor(totLen+1));
else
    xNum = max(factor(totLen));
end
% xNum = max(factor(totLen));
yNum = ceil(totLen/xNum);
if yNum < 4; tNum = yNum; yNum = xNum; xNum = tNum; end
plotNum = 1;

figG = figure(10121); set(figG,'numbertitle', 'off','name','Pooled Spectrogram');
% figV = figure(10122); set(figV,'numbertitle', 'off','name','Mean Change in Power');

BestEEGChans = [];

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
                                                    index = multiIntersect(find(combMat(:,1) == a), find(combMat(:,2) == e), find(combMat(:,3) == s),...
                                                        find(combMat(:,4) == f), find(combMat(:,5) == o), find(combMat(:,6) == c), find(combMat(:,7) == t),...
                                                        find(combMat(:,8) == aa), find(combMat(:,9) == ae), find(combMat(:,10) == as),...
                                                        find(combMat(:,11) == ao), find(combMat(:,12) == av), find(combMat(:,13) == at));

                                                    switch xTitle
                                                        case 'Azi'
                                                            iX = a;
                                                        case 'Elev'
                                                            iX = e;
                                                        case 'Size'
                                                            iX = s;
                                                        case 'SF'
                                                            iX = f;
                                                        case 'Ori'
                                                            iX = o;
                                                        case 'Con'
                                                            iX = c;
                                                        case 'TF'
                                                            iX = t;
                                                        case 'Aud Azi'
                                                            iX = aa;
                                                        case 'Aud Elev'
                                                            iX = ae;
                                                        case 'RF'
                                                            iX = as;
                                                        case 'RP'
                                                            iX = ao;
                                                        case 'Rip Vol'
                                                            iX = av;
                                                        case 'Rip Vel'
                                                            iX = at;
                                                    end

                                                    switch yTitle
                                                        case 'Azi'
                                                            iY = a;
                                                        case 'Elev'
                                                            iY = e;
                                                        case 'Size'
                                                            iY = s;
                                                        case 'SF'
                                                            iY = f;
                                                        case 'Ori'
                                                            iY = o;
                                                        case 'Con'
                                                            iY = c;
                                                        case 'TF'
                                                            iY = t;
                                                        case 'Aud Azi'
                                                            iY = aa;
                                                        case 'Aud Elev'
                                                            iY = ae;
                                                        case 'RF'
                                                            iY = as;
                                                        case 'RP'
                                                            iY = ao;
                                                        case 'Rip Vol'
                                                            iY = av;
                                                        case 'Rip Vel'
                                                            iY = at;
                                                    end

                                                    switch gammaBand
                                                        case 'High Gamma'
%                                                             peakPower = analysedDataAllElec(index).meanPowerAllElecHG{1, 1};
                                                            peakPower = gammaBandDataAllElec(index).changePowerHGamma{1, 1};
                                                            fMin = 51;
                                                            fMax = 80;
                                                        case 'Low Gamma'
%                                                             peakPower = analysedDataAllElec(index).meanPowerAllElecLG{1, 1};
                                                            peakPower = gammaBandDataAllElec(index).changePowerLGamma{1, 1};
                                                            fMin = 21;
                                                            fMax = 50;
                                                    end
                                                    
                                                    [EEGChannelsBip,EEGChannels] = findIndexNMax(peakPower,[],EEGChannelsToPlot,gridMontage,refChan); % Only central, temporal, parietal and occipital electrodes.
                                                                                                            % Excluding Frontal and fronto-central electrodes                                                            
                                                    
                                                    EEGChannelsToExtract = rowCat(EEGChannels);
                                                    [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,EEGChannelsToExtract);                                                        
%                                                     [Data,goodPos] = bipolarRef(plotData,refChan,gridMontage,trialNums,allBadTrials);
                                                    [Data,goodPos] = getRefData(plotData,trialNums,allBadTrials(EEGChannelsToExtract),refChan);
                                                    
%                                                     for i=1:size(EEGChannels,1)                                                        
%                                                         dataTF=Data(EEGChannels(i),goodPos{EEGChannels(i)},:);
%                                                         dataTF=squeeze(dataTF);                    
% 
%                                                         [~,dS1,t2,f2] = getSTFT(dataTF,movingWin,mtmParams,timeVals,BLMin,BLMax);
%                                                         dSPower(i,:,:) = dS1;
%                                                         
%                                                     end
                                                    
                                                    totPos = 0;
                                                    for iCD=1:size(Data,1)                                                        
                                                        dataTF=Data(iCD,goodPos{iCD},:);
                                                        dataTF=squeeze(dataTF);                    

                                                        [~,dS1,tAxis,fAxis] = getSTFT(dataTF,movingWin,mtmParams,timeVals,BLMin,BLMax);
                                                        dSPower(iCD,:,:) = dS1;
                                                        totPos = totPos + length(goodPos{iCD});
                                                    end 
                                                    
                                                    specPower = squeeze(mean(dSPower,1));
                                                    
%                                                     % get time and frequency axes
%                                                     tStim =  (tAxis>=STMin) & (tAxis<=STMax);
% 
%                                                     fRange =   (fAxis>=fMin) & (fAxis<=fMax);
%                                                     fRangeVal = fAxis(fRange);                                                    
% 
%                                                     % get power values in LG and HG bands
%                                                     dPower = specPower(tStim,fRange);
%                                                     meanPeakFreqForCondition = findPeakBandWidth(dPower,fRangeVal);
%                                                     fBandMin = meanPeakFreqForCondition - (desiredBandWidth/2-1);
%                                                     fBandMax = meanPeakFreqForCondition + (desiredBandWidth/2);
%                                                     fBandRange =   (fAxis>=fBandMin) & (fAxis<=fBandMax);
%                                                     meanPower(plotNum) = mean(mean(specPower(tStim,fBandRange),2));                                                    
            
                                                    
                                                    figure(figG); subplot(xNum,yNum,plotNum); pcolor(tAxis,fAxis,specPower'); shading interp; ylim([0 100]); caxis([-3 3]);
                                                    title([num2str(plotNum) '; ' xTitle ': ' num2str(xAxis(iX)) '; ' yTitle ': ' num2str(yAxis(iY)) '; n=' num2str(totPos)]);
                                                    xlabel(['Elecs: ' num2str(EEGChannelsBip')]);
                                                    
%                                                     figure(figV); bar(meanPower);
%                                                     set(gca,'XTick',1:plotNum);
% %                                                     title([xTitle ': ' num2str(xAxis(iX)) '; ' yTitle ': ' num2str(yAxis(iY))]);
% %                                                     xlabel(['Elecs: ' num2str(EEGChannelsBip')]);
                                                    
                                                    if a>1 || e>1 || s>4 || f>1 || o>1 || c>4 || t<7 || aa>1 || ae>1 || as>1 || ao>1 || av>1 || at>1 || plotNum == 1
                                                        BestEEGChans = union(BestEEGChans,EEGChannelsBip);
                                                    end
    
                                                    drawnow
                                                    plotNum = plotNum + 1;
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

end
