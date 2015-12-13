function [nmaxIndex,nmaxIndexOriginal] = findIndexNMax(Data,N,cutOffRange,gridMontage,refChan)
    [sortedData(:,1),sortedData(:,2)] = sort(Data,'descend');
    sortedData((sortedData(:,2)<cutOffRange(1) | sortedData(:,2)>=cutOffRange(2)),:) = [];
    nmaxIndex = sortedData(1:N,2);
%     nmaxIndexNum = nmaxIndex;
    
    if strcmp(refChan,'Bipolar')
        [~,~,bipolarLocs] = loadChanLocs(gridMontage,4);        
        nmaxIndexOriginal = bipolarLocs(nmaxIndex,:);
    end
end