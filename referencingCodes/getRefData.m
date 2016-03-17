function [Data,goodPos] = getRefData(plotData,trialNums,allBadTrials,refChan)
    numChan = size(plotData,1);   
    
    if strcmpi(refChan,'Bipolar')
        datCount = 1;
        for iNC = 1:2:(numChan-1)
            Data(datCount,:,:) = plotData(iNC,:,:)-plotData(iNC+1,:,:);
            badPos = union(allBadTrials{iNC},allBadTrials{iNC+1});
            goodTrials = setdiff(trialNums,badPos);
            goodPos{datCount} = find(ismember(trialNums,goodTrials));
            datCount = datCount + 1;
        end
    elseif strcmpi(refChan,'SingleWire')
        Data = plotData;
        for iGP = 1:numChan
            badPos = allBadTrials{iGP};
            goodTrials = setdiff(trialNums,badPos);
            goodPos{iGP} = find(ismember(trialNums,goodTrials));
        end
    end
    
end