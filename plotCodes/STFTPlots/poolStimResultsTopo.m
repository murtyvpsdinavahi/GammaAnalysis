% poolStimResultsTopo
% Created by MD: 01/02/16

function poolStimResultsTopo(dataLogList,protocolType,subjectIndices,freqBands,refChan)
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

    % Load parameter combinations
    subjectName1 = dataLogList.subjectNames{1,dataLogIndices(1)};
    expDate1 = dataLogList.expDates{1,dataLogIndices(1)};
    protocolName1 = dataLogList.protocolNames{1,dataLogIndices(1)};

    dataL1{1,2} = subjectName1;
    dataL1{2,2} = dataLogList.gridType;
    dataL1{3,2} = expDate1;
    dataL1{4,2} = protocolName1;
    dataL1{14,2} = dataLogList.folderSourceString;

    [~,folderName1]=getFolderDetails(dataL1);
            
    folderExtract = fullfile(folderName1,'extractedData');
    [~,aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,cValsUnique,tValsUnique,aaValsUnique,...
            aeValsUnique,asValsUnique,aoValsUnique,avValsUnique,atValsUnique] = loadParameterCombinations(folderExtract);
    
    switch protocolType
        case 'AZI';        xValsUnique = aValsUnique;
        case 'ELEV';        xValsUnique = eValsUnique;
        case 'SIZE';        xValsUnique = sValsUnique;
        case 'SF';        xValsUnique = fValsUnique;
        case 'ORI';        xValsUnique = oValsUnique;
        case 'CON';        xValsUnique = cValsUnique;
        case 'TFDF';        xValsUnique = tValsUnique; % For Drifting gratings
        case 'TFCP';        xValsUnique = tValsUnique; % For Counterphasing gratings
        case 'AUDAZI';        xValsUnique = aaValsUnique;
        case 'AUDELEV';        xValsUnique = aeValsUnique;
        case 'RF';        xValsUnique = asValsUnique;
        case 'RP';        xValsUnique = aoValsUnique;
        case 'RIPVOL';        xValsUnique = avValsUnique;
        case 'RIPVEL';        xValsUnique = atValsUnique;
    end

    hString='';
    for iC = 1:length(xValsUnique)
        outArray{iC} = num2str(xValsUnique(iC));
        hString = cat(2,hString,[outArray{iC} '|']);
    end    
    clear outArray
    
    hParamVal = uicontrol('Unit','Normalized', 'Parent',figH, ...
        'Position',[0.01 0.01 0.05 0.05], ...
        'Style','popup','String',hString,'FontSize',15);
    
    hFreqVal = uicontrol('Unit','Normalized', 'Parent',figH, ...
        'Position',[0.07 0.01 0.05 0.05], ...
        'Style','popup','String',freqBands,'FontSize',15);
    
    hPlotType = uicontrol('Unit','Normalized', 'Parent',figH, ...
        'Position',[0.13 0.01 0.05 0.05], ...
        'Style','popup','String','Headplot|Topoplot','FontSize',15);
    
    hPlotButton = uicontrol('Unit','Normalized', 'Parent',figH, ...
        'Position',[0.19 0.01 0.05 0.05], ...
        'Style','pushbutton','String','Plot','FontSize',15,'callback',{@updatePlot_Callback});

    a = 1; e = 1; s = 1; f = 1; o = 1; c = 1; t = 1; 
    aa = 1; ae = 1; as = 1; ao = 1; av = 1; at = 1;
    
    updatePlot_Callback;
    
    function updatePlot_Callback(~,~)
        xVal = get(hParamVal,'val');
        freqVal = get(hFreqVal,'val');
        
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
%             clear dataLog
%             dataLog = loadDataLog(folderName);


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

            switch protocolType
                case 'AZI';        a = xVal;
                case 'ELEV';        e = xVal;
                case 'SIZE';        s = xVal;
                case 'SF';        f = xVal;
                case 'ORI';        o = xVal;
                case 'CON';        c = xVal;
                case 'TFDF';        t = xVal; % For Drifting gratings
                case 'TFCP';        t = xVal; % For Counterphasing gratings
                case 'AUDAZI';        aa = xVal;
                case 'AUDELEV';        ae = xVal;
                case 'RF';        as = xVal;
                case 'RP';        ao = xVal;
                case 'RIPVOL';        av = xVal;
                case 'RIPVEL';        at = xVal;
            end

            index = multiIntersect(find(combMat(:,1) == a), find(combMat(:,2) == e), find(combMat(:,3) == s),...
                find(combMat(:,4) == f), find(combMat(:,5) == o), find(combMat(:,6) == c), find(combMat(:,7) == t),...
                find(combMat(:,8) == aa), find(combMat(:,9) == ae), find(combMat(:,10) == as),...
                find(combMat(:,11) == ao), find(combMat(:,12) == av), find(combMat(:,13) == at));   

            freqBand = freqBands{freqVal};
            switch freqBand
                case 'AllGamma'
                    peakPower = gammaBandDataAllElec(index).changePowerAllGamma{1, 1};
                case 'LGamma'
                    peakPower = gammaBandDataAllElec(index).changePowerLGamma{1, 1};
                case 'HGamma'
                    peakPower = gammaBandDataAllElec(index).changePowerHGamma{1, 1};
            end

            figure(figH); subplot(numPlotRows,numPlotCols,dataLogIndex); cla(gca,'reset'); axis off;
            plotType = get(hPlotType,'val');
            switch plotType
                case 1
                    headplot(peakPower,'bipMon.mat','electrodes','off','view','back');
                case 2
                    topoplot(peakPower,chanlocs,'electrodes','numbers','style','both','drawaxis','off','nosedir',noseDir);
            end            
            caxis([-2 2]); title(subjectName); colorbar;
        end

    
    end
end