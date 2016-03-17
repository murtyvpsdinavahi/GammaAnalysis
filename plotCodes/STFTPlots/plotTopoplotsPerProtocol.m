function plotTopoplotsPerProtocol(dataLog,freqBandToPlot,refChan)

if ~exist('freqBandToPlot','var')||isempty(freqBandToPlot); freqBandToPlot = 'HGamma'; end;
if ~exist('refChan','var')||isempty(refChan); refChan = 'Bipolar'; end;

switch refChan
    case 'Bipolar'
        refType = 4;
        noseDir = '-Y';
    case 'Hemisphere'
        refType = 2;
        noseDir = '+X';
    case 'SingleWire'
        refType = 1;
        noseDir = '+X';
end

gridMontage = dataLog{15,2};
chanlocs = loadChanLocs(gridMontage,refType);

[~,folderName]=getFolderDetails(dataLog);
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
if cLen > 1 && isempty(rowNum); rowNum = cValsUnique; rowTitle = 'Con'; end
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
if cLen > 1 && ~isequal(rowNum,cValsUnique); colNum = cValsUnique; colTitle = 'Con'; end
if tLen > 1 && ~isequal(rowNum,tValsUnique); colNum = tValsUnique; colTitle = 'TF'; end
if aaLen > 1 && ~isequal(rowNum,aaValsUnique); colNum = aaValsUnique; colTitle = 'Aud Azi'; end
if aeLen > 1 && ~isequal(rowNum,aeValsUnique); colNum = aeValsUnique; colTitle = 'Aud Elev'; end
if asLen > 1 && ~isequal(rowNum,asValsUnique); colNum = asValsUnique; colTitle = 'RF'; end
if aoLen > 1 && ~isequal(rowNum,aoValsUnique); colNum = aoValsUnique; colTitle = 'RP'; end
if avLen > 1 && ~isequal(rowNum,avValsUnique); colNum = avValsUnique; colTitle = 'Rip Vol'; end
if atLen > 1 && ~isequal(rowNum,atValsUnique); colNum = atValsUnique; colTitle = 'Rip Vel'; end
if isempty(colNum); colNum = 1; colTitle = 'None'; end;

figG = figure; 
gridPos = [0.05 0.05 0.9 0.9];
if length(rowNum)>length(colNum);
    tNum = rowNum; rowNum = colNum; colNum = tNum;
    tTitle = rowTitle; rowTitle = colTitle; colTitle = tTitle;
end
set(figG,'numbertitle', 'off','name',[dataLog{1,2} ': ' rowTitle ' vs ' colTitle ' Gamma Range: ' freqBandToPlot]);
hPlots = getPlotHandles(length(rowNum),length(colNum),gridPos,0.002,0.002);

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
                                                        
                                                        switch freqBandToPlot
                                                            case 'AllGamma'
                                                                peakPower = gammaBandDataAllElec(index).changePowerAllGamma{1,1};
                                                            case 'LGamma'
                                                                peakPower = gammaBandDataAllElec(index).changePowerLGamma{1,1};
                                                            case 'HGamma'
                                                                peakPower = gammaBandDataAllElec(index).changePowerHGamma{1,1};
                                                        end
                                                    
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
                                                        case 'None'
                                                            iY = 1;
                                                    end                                                                                                                                                                 
                                                     
                                                    subplot(hPlots(iX,iY)); hold on;
                                                    topoplot(peakPower,chanlocs,'electrodes','numbers','style','both','drawaxis','off','nosedir',noseDir); caxis([-3 3]);
                                                    hold off;                                                    
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
