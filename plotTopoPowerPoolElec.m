function plotTopoPowerPoolElec(dataLog,refChan)

if ~exist('refChan','var')||isempty(refChan); refChan = 'Bipolar'; end
[~,folderName]=getFolderDetails(dataLog);
load(fullfile(folderName,['analysedDataAllElec_' refChan '.mat']));

switch refChan
    case 'Bipolar'
        refType = 4;
        noseDir = '-Y';
    case 'Hemisphere'
        refType = 2;
        noseDir = '+X';
end
gridMontage = dataLog{15,2};
chanlocs = loadChanLocs(gridMontage,refType);

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
    
combMat = [analysedDataAllElec.a; analysedDataAllElec.e; analysedDataAllElec.s; analysedDataAllElec.f; analysedDataAllElec.o; analysedDataAllElec.c; analysedDataAllElec.t;...
    analysedDataAllElec.aa; analysedDataAllElec.ae; analysedDataAllElec.as; analysedDataAllElec.ao; analysedDataAllElec.av; analysedDataAllElec.at];
combMat = combMat';

totLen = aLen*eLen*sLen*fLen*oLen*cLen*tLen*aaLen*aeLen*asLen*aoLen*avLen*atLen;
xNum = max(factor(totLen));
yNum = totLen/xNum;
if yNum < 4; tNum = yNum; yNum = xNum; xNum = tNum; end
plotNum = 1;

figHG = figure(101); set(figHG,'numbertitle', 'off','name','High Gamma');
figLG = figure(102); set(figLG,'numbertitle', 'off','name','Low Gamma');
figAlpha = figure(103); set(figAlpha,'numbertitle', 'off','name','Alpha');

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

                                                    % High gamma
                                                    peakPowerHG = analysedDataAllElec(index).meanPowerAllElecHG{1, 1};
                                                    figure(figHG); subplot(xNum,yNum,plotNum); topoplot(peakPowerHG,chanlocs,'electrodes','numbers','style','both','drawaxis','off','nosedir',noseDir);
                                                    caxis([-2 2]); title([xTitle ': ' num2str(xAxis(iX)) '; ' yTitle ': ' num2str(yAxis(iY))]);

                                                    % Low gamma
                                                    peakPowerLG = analysedDataAllElec(index).meanPowerAllElecLG{1, 1};
                                                    figure(figLG); subplot(xNum,yNum,plotNum); topoplot(peakPowerLG,chanlocs,'electrodes','numbers','style','both','drawaxis','off','nosedir',noseDir);
                                                    caxis([-2 2]); title([xTitle ': ' num2str(xAxis(iX)) '; ' yTitle ': ' num2str(yAxis(iY))]);

                                                    % Alpha
                                                    peakPowerAlpha = analysedDataAllElec(index).meanPowerAllElecAlpha{1, 1};
                                                    figure(figAlpha); subplot(xNum,yNum,plotNum); topoplot(peakPowerAlpha,chanlocs,'electrodes','numbers','style','both','drawaxis','off','nosedir',noseDir);
                                                    caxis([-2 2]); title([xTitle ': ' num2str(xAxis(iX)) '; ' yTitle ': ' num2str(yAxis(iY))]);

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
