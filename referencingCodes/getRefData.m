function [Data,goodPos] = getRefData(plotData,trialNums,allBadTrials)
    numChan2 = size(plotData,1);
    datCount = 1;
    for iNC = 1:2:(numChan2-1)
        Data(datCount,:,:) = plotData(iNC,:,:)-plotData(iNC+1,:,:);
        badPos = union(allBadTrials{iNC},allBadTrials{iNC+1});
        goodTrials = setdiff(trialNums,badPos);
        goodPos{datCount} = find(ismember(trialNums,goodTrials));
        datCount = datCount + 1;
    end
end