function [nmaxIndex,nmaxIndexOriginal] = findIndexNMax(Data,N,cutOffRange,gridMontage,refChan)
    [sortedData(:,1),sortedData(:,2)] = sort(Data,'descend');
    if iscell(cutOffRange)
        sortedData((~ismember(sortedData(:,2),cell2mat(cutOffRange))),:) = [];%(1) | sortedData(:,2)>=cutOffRange(2)),:) = [];
    else
        sortedData((sortedData(:,2)<cutOffRange(1) | sortedData(:,2)>=cutOffRange(2)),:) = [];
    end
    if ~exist('N','var') || isempty(N); N = size(sortedData,1); end;
    nmaxIndex = sortedData(1:N,2);
%     nmaxIndexNum = nmaxIndex;
    
    if strcmp(refChan,'Bipolar')
        [~,~,bipolarLocs] = loadChanLocs(gridMontage,4);        
        nmaxIndexOriginal = bipolarLocs(nmaxIndex,:);
    elseif strcmpi(refChan,'SingleWire')
        nmaxIndexOriginal = nmaxIndex;
    end
end