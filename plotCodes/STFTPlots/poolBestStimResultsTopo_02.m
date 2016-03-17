% poolBestStimResultsTopo
% Created by MD: 01/02/16

function peakPower = poolBestStimResultsTopo_02(dataLogList,protocolType,subjectIndices,freqBands,refChan)

protocolIndices = find(strcmpi(protocolType,dataLogList.protocolTypes));
dataLogIndices = intersect(subjectIndices,protocolIndices);

% Get plot handles
figNum = randi(10000);
figH = figure(figNum);
numPlots = length(dataLogIndices);
if isprime(numPlots);
    numPlotRows = max(factor(numPlots+1));
else
    numPlotRows = max(factor(numPlots));
end
numPlotCols = ceil(numPlots/numPlotRows);
if numPlotCols < 4; tNum = numPlotCols; numPlotCols = numPlotRows; numPlotRows = tNum; end

for dataLogIndex = 1:numPlots
    % Get dataLog file
    subjectName = dataLogList.subjectNames{1,dataLogIndices(dataLogIndex)};
    expDate = dataLogList.expDates{1,dataLogIndices(dataLogIndex)};
    
    protocolName = dataLogList.protocolNames{1,dataLogIndices(dataLogIndex)};
    gridMontage = dataLogList.capMontage{1,dataLogIndices(dataLogIndex)};

    dataL{1,2} = subjectName;
    dataL{2,2} = dataLogList.gridType;
    dataL{3,2} = expDate;
    dataL{4,2} = protocolName;
    dataL{14,2} = dataLogList.folderSourceString;

    [~,folderName]=getFolderDetails(dataL);
    clear dataLog
    load(fullfile(folderName,'dataLog.mat'));
    folderExtract = fullfile(folderName,'extractedData');
    [~,~,~,sValsUnique,~,~,cValsUnique,tValsUnique] = loadParameterCombinations(folderExtract);
    
    a = 1; e = 1; s = 1; f = 1; o = 1; c = 1; t = 1; 
    aa = 1; ae = 1; as = 1; ao = 1; av = 1; at = 1;
    
    switch protocolType
        case 'SIZE';        s = length(sValsUnique);
        case 'CON';         c = length(cValsUnique);
        case 'TFDF';        t = length(tValsUnique); % For Drifting gratings
        case 'TFCP';        t = length(tValsUnique); % For Counterphasing gratings
    end

    % Get chanlocs
    switch refChan
        case 'Bipolar'
            refType = 4;
            noseDir = '-Y';
        case 'Hemisphere'
            refType = 2;
            noseDir = '+X';
    end
    chanlocs = loadChanLocs(gridMontage,refType);


    % Find out the best condition
    load(fullfile(folderName,['gammaBandDataAllElec_' refChan '.mat']));
    combMat = [gammaBandDataAllElec.a; gammaBandDataAllElec.e; gammaBandDataAllElec.s; gammaBandDataAllElec.f; gammaBandDataAllElec.o; gammaBandDataAllElec.c; gammaBandDataAllElec.t;...
        gammaBandDataAllElec.aa; gammaBandDataAllElec.ae; gammaBandDataAllElec.as; gammaBandDataAllElec.ao; gammaBandDataAllElec.av; gammaBandDataAllElec.at];
    combMat = combMat';

    index = multiIntersect(find(combMat(:,1) == a), find(combMat(:,2) == e), find(combMat(:,3) == s),...
        find(combMat(:,4) == f), find(combMat(:,5) == o), find(combMat(:,6) == c), find(combMat(:,7) == t),...
        find(combMat(:,8) == aa), find(combMat(:,9) == ae), find(combMat(:,10) == as),...
        find(combMat(:,11) == ao), find(combMat(:,12) == av), find(combMat(:,13) == at));   

    freqVal = 1;
    freqBand = freqBands{freqVal};
    switch freqBand
        case 'AllGamma'
            peakPower(dataLogIndex,:) = gammaBandDataAllElec(index).changePowerAllGamma{1, 1};
        case 'LGamma'
            peakPower(dataLogIndex,:) = gammaBandDataAllElec(index).changePowerLGamma{1, 1};
        case 'TGamma'
            peakPower(dataLogIndex,:) = gammaBandDataAllElec(index).changePowerHGamma{1, 1};
    end
    
    normalisedPeakPower(dataLogIndex,:) = peakPower(dataLogIndex,:)./max(peakPower(dataLogIndex,81:96));
    figure(figH); subplot(numPlotRows,numPlotCols,dataLogIndex); cla(gca,'reset'); axis off;            
    topoplot(peakPower(dataLogIndex,:),chanlocs,'electrodes','numbers','style','both','drawaxis','off','nosedir',noseDir);                       
    caxis([-2 2]); title(subjectName); colorbar;
end


peakPowerAll = mean(normalisedPeakPower,1);
figure; topoplot(peakPowerAll,chanlocs,'electrodes','numbers','style','both','drawaxis','off','nosedir',noseDir);

    
%     end
end