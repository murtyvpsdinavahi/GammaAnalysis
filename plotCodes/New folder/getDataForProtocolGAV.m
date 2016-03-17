function [Data,goodPos,timeVals,xValsUnique] = getDataForProtocolGAV(dataLog,protocolType,refChan,commonEEGChannels)

    protocolType = upper(protocolType);
    % EEG Channels to extract
    clear bipolarLocs commonUnipolarEEGChannels EEGChannelsToExtract    
    refChan = [upper(refChan(1)) lower(refChan(2:end))];
    switch refChan
        case 'Bipolar'
            gridMontage = dataLog{15,2};
            [~,~,bipolarLocs] = loadChanLocs(gridMontage,4);        
            commonUnipolarEEGChannels = bipolarLocs(commonEEGChannels,:);
        otherwise
            commonUnipolarEEGChannels = commonEEGChannels;
    end
    EEGChannelsToExtract = rowCat(commonUnipolarEEGChannels);

    % Load parameter combinations and timeVals
    [~,folderName]=getFolderDetails(dataLog);
    folderExtract = fullfile(folderName,'extractedData');
    [~,aValsUnique,eValsUnique,sValsUnique,~,oValsUnique,cValsUnique,tValsUnique,aaValsUnique,...
            aeValsUnique,asValsUnique,aoValsUnique,avValsUnique,atValsUnique] = loadParameterCombinations(folderExtract);
    switch protocolType
        case 'AZI';        xValsUnique = aValsUnique;
        case 'ELEV';        xValsUnique = eValsUnique;
        case 'SIZE';        xValsUnique = sValsUnique;
%         case 'SF';        xValsUnique = fValsUnique; % SF protocol is not included
        case 'ORI';        xValsUnique = oValsUnique(1:end-1); % Ignoring 180 degrees as it is same as 0 degrees. 
            % This step needs more refinement (eg. a case when the last oValsUnique is not 180 or the first is not 0 degrees.
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
    xLen = length(xValsUnique);
    a = 1; e = 1; s = 1; f = 1; o = 1; c = 1; t = 1; 
    aa = 1; ae = 1; as = 1; ao = 1; av = 1; at = 1;
    
    % Load data and timeVals
    clear folderSegment folderLFP plotData trialNums allBadTrials
    folderSegment = fullfile(folderName,'segmentedData');
    folderLFP = fullfile(folderSegment,'LFP');
    [~,timeVals] = loadlfpInfo(folderLFP);
    
    for x=1:xLen
        switch protocolType
            case 'AZI';        a = x;
            case 'ELEV';        e = x;
            case 'SIZE';        s = x;
            case 'SF';        f = x;
            case 'ORI';        o = x;
            case 'CON';        c = x;
            case 'TFDF';        t = x; % For Drifting gratings
            case 'TFCP';        t = x; % For Counterphasing gratings
            case 'AUDAZI';        aa = x;
            case 'AUDELEV';        ae = x;
            case 'RF';        as = x;
            case 'RP';        ao = x;
            case 'RIPVOL';        av = x;
            case 'RIPVEL';        at = x;
        end
        
        clear plotData trialNums allBadTrials
        [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,EEGChannelsToExtract);
        if ~exist('Data','var')
%             Data = cell(length(commonEEGChannels),length(trialNums),size(plotData,3),xLen);
            Data = cell(1,xLen);
%             goodPos = cell(length(commonEEGChannels),xLen);
            goodPos = cell(1,xLen);
        end
        clear refData goodPosRef
        [refData,goodPosRef] = getRefData(plotData,trialNums,allBadTrials(EEGChannelsToExtract),refChan);
%         Data(:,:,:,x) = {refData};
        Data(1,x) = {refData};
        goodPos(1,x) = {goodPosRef};        
    end
end