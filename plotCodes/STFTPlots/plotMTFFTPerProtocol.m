function plotPos = plotMTFFTPerProtocol(dataLog,EEGChannels,freqBandToPlot,freqBands,refChan,saveFlag,averageAllElecFlag,plotPos,BLPeriod,STPeriod,tapers,Fs)

if ~exist('freqBandToPlot','var')||isempty(freqBandToPlot); freqBandToPlot = [11 90]; end;
if ~exist('freqBands','var')||isempty(freqBands); freqBands = {'LGamma','HGamma'}; end;
if ~exist('refChan','var')||isempty(refChan); refChan = 'Bipolar'; end;
if ~exist('saveFlag','var')||isempty(saveFlag); saveFlag = 1; end;
if ~exist('BLPeriod','var')||isempty(BLPeriod); BLPeriod = [-0.5 0]; end;
if ~exist('STPeriod','var')||isempty(STPeriod); STPeriod = [0.25 0.75]; end;
if ~exist('tapers','var')||isempty(tapers); tapers = [2 3]; end;
if ~exist('Fs','var')||isempty(Fs); Fs = dataLog{9, 2}; end;

mtmParams.Fs = Fs;
mtmParams.tapers = tapers;
mtmParams.trialave=1;
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


rowNum = [];
colNum = [];

% Variable 1: xAxis
if aLen > 1 && isempty(rowNum); rowNum = aValsUnique; rowTitle = 'Azi'; end
if eLen > 1 && isempty(rowNum); rowNum = eValsUnique; rowTitle = 'Elev'; end
if sLen > 1 && isempty(rowNum); rowNum = sValsUnique; rowTitle = 'Size'; end
if fLen > 1 && isempty(rowNum); rowNum = fValsUnique; rowTitle = 'SF'; end
if oLen > 1 && isempty(rowNum); rowNum = oValsUnique; rowTitle = 'Ori'; end
if cLen > 1 && isempty(rowNum); rowNum = cValsUnique; rowTitle = 'Contrast'; end
if tLen > 1 && isempty(rowNum); rowNum = tValsUnique; rowTitle = 'TF'; end
if aaLen > 1 && isempty(rowNum); rowNum = aaValsUnique; rowTitle = 'Aud Azi'; end
if aeLen > 1 && isempty(rowNum); rowNum = aeValsUnique; rowTitle = 'Aud Elev'; end
if asLen > 1 && isempty(rowNum); rowNum = asValsUnique; rowTitle = 'RF'; end
if aoLen > 1 && isempty(rowNum); rowNum = aoValsUnique; rowTitle = 'RP'; end
if avLen > 1 && isempty(rowNum); rowNum = avValsUnique; rowTitle = 'Rip Vol'; end
if atLen > 1 && isempty(rowNum); rowNum = atValsUnique; rowTitle = 'Rip Vel'; end

% Variable 2: yAxis
if aLen > 1 && ~isequal(rowNum,aValsUnique); colNum = aValsUnique; colTitle = 'Azi'; end
if eLen > 1 && ~isequal(rowNum,eValsUnique); colNum = eValsUnique; colTitle = 'Elev'; end
if sLen > 1 && ~isequal(rowNum,sValsUnique); colNum = sValsUnique; colTitle = 'Size'; end
if fLen > 1 && ~isequal(rowNum,fValsUnique); colNum = fValsUnique; colTitle = 'SF'; end
if oLen > 1 && ~isequal(rowNum,oValsUnique); colNum = oValsUnique; colTitle = 'Ori'; end
if cLen > 1 && ~isequal(rowNum,cValsUnique); colNum = cValsUnique; colTitle = 'Contrast'; end
if tLen > 1 && ~isequal(rowNum,tValsUnique); colNum = tValsUnique; colTitle = 'TF'; end
if aaLen > 1 && ~isequal(rowNum,aaValsUnique); colNum = aaValsUnique; colTitle = 'Aud Azi'; end
if aeLen > 1 && ~isequal(rowNum,aeValsUnique); colNum = aeValsUnique; colTitle = 'Aud Elev'; end
if asLen > 1 && ~isequal(rowNum,asValsUnique); colNum = asValsUnique; colTitle = 'RF'; end
if aoLen > 1 && ~isequal(rowNum,aoValsUnique); colNum = aoValsUnique; colTitle = 'RP'; end
if avLen > 1 && ~isequal(rowNum,avValsUnique); colNum = avValsUnique; colTitle = 'Rip Vol'; end
if atLen > 1 && ~isequal(rowNum,atValsUnique); colNum = atValsUnique; colTitle = 'Rip Vel'; end
if isempty(colNum); colNum = 1; colTitle = 'None'; end;

if length(rowNum)>length(colNum);
    tNum = rowNum; rowNum = colNum; colNum = tNum;
    tTitle = rowTitle; rowTitle = colTitle; colTitle = tTitle;
end
if ~exist('plotPos','var')||isempty(plotPos) 
    figG = figure(randi([500 50000],[1 1])); 
    gridPos = [0.05 0.05 0.9 0.9];    
    set(figG,'numbertitle', 'off','name',[dataLog{1,2} ': ' rowTitle ' vs ' colTitle]);
    [~,~,plotPos] = getPlotHandles(length(rowNum),length(colNum),gridPos,0.01,0.01);
end

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
                                                    clear combMat index peakPower
                                                    combMat = [gammaBandDataAllElec.a; gammaBandDataAllElec.e; gammaBandDataAllElec.s; gammaBandDataAllElec.f; gammaBandDataAllElec.o; gammaBandDataAllElec.c; gammaBandDataAllElec.t;...
                                                        gammaBandDataAllElec.aa; gammaBandDataAllElec.ae; gammaBandDataAllElec.as; gammaBandDataAllElec.ao; gammaBandDataAllElec.av; gammaBandDataAllElec.at];
                                                    combMat = combMat';
                                                    index = multiIntersect(find(combMat(:,1) == a), find(combMat(:,2) == e), find(combMat(:,3) == s),...
                                                            find(combMat(:,4) == f), find(combMat(:,5) == o), find(combMat(:,6) == c), find(combMat(:,7) == t),...
                                                            find(combMat(:,8) == aa), find(combMat(:,9) == ae), find(combMat(:,10) == as),...
                                                            find(combMat(:,11) == ao), find(combMat(:,12) == av), find(combMat(:,13) == at));
                                             
                                                    switch rowTitle
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
                                                        case 'Contrast'
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
                                                        case 'None'
                                                            iX = 1;
                                                    end

                                                    switch colTitle
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
                                                        case 'Contrast'
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
                                                        case 'None'
                                                            iY = 1;
                                                    end  
                                                    
                                                    for iBand = 1:length(freqBands)
                                                        freqBand = freqBands{iBand};
                                                        switch freqBand
                                                            case 'AllGamma'
                                                                peakPower = gammaBandDataAllElec(index).changePowerAllGamma{1,1};
                                                            case 'LGamma'
                                                                peakPower = gammaBandDataAllElec(index).changePowerLGamma{1,1};
                                                            case 'HGamma'
                                                                peakPower = gammaBandDataAllElec(index).changePowerHGamma{1,1};
                                                        end

                                                        for iSide = 1:size(EEGChannels,1) 
                                                            clear bipolarLocs nmaxIndexOriginal EEGChannelsToExtract nmaxIndex nonsignificantElecIndex

                                                            
                                                                [~,~,bipolarLocs] = loadChanLocs(gridMontage,4);
                                                                [nmaxIndex,nmaxIndexOriginal] = findIndexNMax(peakPower,[],EEGChannels{iSide,:},gridMontage,refChan);
                                                                if ~averageAllElecFlag
                                                                    nonsignificantElecIndex = peakPower(nmaxIndex)<0.5*peakPower(nmaxIndex(1));
                                                                    nmaxIndexOriginal(nonsignificantElecIndex,:)=[];
                                                                    nmaxIndex(nonsignificantElecIndex,:) = [];
                                                                end
    %                                                             nmaxIndexOriginal = bipolarLocs(EEGChannels(iSide,:),:);
                                                            if strcmp(refChan,'Bipolar')
                                                                EEGChannelsToExtract = rowCat(nmaxIndexOriginal);
                                                            else
                                                                EEGChannelsToExtract = rowCat(nmaxIndex);
                                                            end
                                                            
                                                            if isempty(EEGChannelsToExtract); disp('No EEG Channels found with significant increase in power!!'); continue; end;
                                                            clear plotData trialNums allBadTrials Data goodPos
                                                            [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,EEGChannelsToExtract);                                                        
%                                                             if strcmp(refChan,'Bipolar')
                                                                [Data,goodPos] = getRefData(plotData,trialNums,allBadTrials(EEGChannelsToExtract),refChan);
%                                                             else
%                                                                 Data = plotData;
%                                                                 for iGP = 1:length(EEGChannelsToExtract)
%                                                                     badPos = allBadTrials{EEGChannelsToExtract(iGP)};
%                                                                     goodTrials = setdiff(trialNums,badPos);
%                                                                     goodPos{iGP} = find(ismember(trialNums,goodTrials));
%                                                                 end
%                                                                 error(['Check code for non-bipolar referencing schemes']);
%                                                             end

                                                            clear dataMT rawPSDStimElec rawPSDBLElec
                                                            for iCD=1:size(Data,1)                                                        
                                                                dataMT=Data(iCD,goodPos{iCD},:);
                                                                dataMT=squeeze(dataMT);
                                                                
                                                                if size(dataMT,1)>size(dataMT,2); dataMT = dataMT'; end;

                                                                % get time axes
                                                                tStim =  (timeVals>STMin) & (timeVals<=STMax);
                                                                tBL = (timeVals>BLMin) & (timeVals<=BLMax);

                                                                % calculate MTFFT in stim and BL periods
                                                                [rawPSDStimElec(:,iCD),fAxisStim]=mtspectrumc(dataMT(:,tStim)',mtmParams);
                                                                [rawPSDBLElec(:,iCD),fAxisBL]=mtspectrumc(dataMT(:,tBL)',mtmParams);
        %                                                         rawPSDStim{iX,iY,iCD,:} = rawPSDStimElec';
        %                                                         rawPSDBL{iX,iY,iCD,:} = rawPSDBLElec';

        %                                                         if (fAxisStim ~= fAxisBL); error('frequency axes in BL and stim period different'); else fAxis = fAxisStim; end;
        %                                                         fRangeToPlot =   (fAxis>=freqBandToPlot(1)) & (fAxis<=freqBandToPlot(2));
        %                                                         fRangeValToPlot = fAxis(fRangeToPlot);
        % 
        %                                                         subplot(hPlots(iX,iY)); hold on;
        %                                                         plot(fRangeValToPlot,conv2Log(rawPSDStimElec(fRangeToPlot,:)./rawPSDBLElec(fRangeToPlot,:)),'linewidth',2,'color',(iCD/size(Data,1))*[0.8 0.8 0.8])
        %                                                         axis tight; ylim([-1 1]); hold off;
        %                                                         drawnow
                                                            end 

                                                            if (fAxisStim ~= fAxisBL); error('frequency axes in BL and stim period different'); else fAxis = fAxisStim; end;
                                                            fRangeToPlot =   (fAxis>=freqBandToPlot(1)) & (fAxis<=freqBandToPlot(2));
                                                            fRangeValToPlot = fAxis(fRangeToPlot);

                                                            clear hPlots changeInPower
                                                            hPlots = getPlotHandles(1,length(freqBands),plotPos{iX,iY},0.002,0.002);

                                                            changeInPower = conv2Log(rawPSDStimElec(fRangeToPlot,:)./rawPSDBLElec(fRangeToPlot,:));
                                                            meanChangeInPower = conv2Log(mean(rawPSDStimElec(fRangeToPlot,:),2)./mean(rawPSDBLElec(fRangeToPlot,:),2));
                                                            subplot(hPlots(1,iBand)); hold on;
                                                            
                                                            rgbVals = getColorRGB(iSide+1);
                                                            if averageAllElecFlag
                                                                rgbVals = 0.5*rgbVals;
                                                            end
%                                                             plot(fRangeValToPlot,changeInPower,'linewidth',1,'color',0.5*rgbVals);
                                                            plot(fRangeValToPlot,meanChangeInPower,'linewidth',2,'color',rgbVals);
                                                            if ~averageAllElecFlag
                                                                text(0.1,0.1*iSide,num2str(nmaxIndex'),'unit','normalized','fontsize',7,'Parent',hPlots(1,iBand),'color',rgbVals);
                                                            end
                                                            axis tight; ylim([-1 1]); hold off;
                                                            drawnow
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
end

if saveFlag
    saveFolder = fullfile(dataLog{14,2},'Plots','VisualGammaProject',[rowTitle '_vs_' colTitle]);
    makeDirectory(saveFolder);
    savefig(figG,fullfile(saveFolder,[dataLog{1,2} '.fig']));
    save(fullfile(saveFolder,[dataLog{1,2} '.mat']));
    close(figG);
    clear figG;
else
    disp('saveFlag set to 0. Figure and Data not saved.')
end
end
