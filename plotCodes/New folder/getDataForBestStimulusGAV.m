function [Data,goodPos,timeVals] = getDataForBestStimulusGAV(dataLog,protocolType,refChan,commonEEGChannels,bestStimulusFolder)

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

    % Get parameters for best stimulus from a specified GAV protocol
    if ~exist('bestStimulusFolder','var'); bestStimulusFolder = []; end;
    [a,e,s,f,o,c,t,aa,ae,as,ao,av,at] = getBestStimulusParametersForProtocolGAV(dataLog,protocolType,bestStimulusFolder);
    
    % Load data and timeVals
    clear folderSegment folderLFP plotData trialNums allBadTrials
    [~,folderName]=getFolderDetails(dataLog);
    folderSegment = fullfile(folderName,'segmentedData');
    folderLFP = fullfile(folderSegment,'LFP');        
    [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,EEGChannelsToExtract);                                                        
    [Data,goodPos] = getRefData(plotData,trialNums,allBadTrials(EEGChannelsToExtract),refChan);
    [~,timeVals] = loadlfpInfo(folderLFP);
end