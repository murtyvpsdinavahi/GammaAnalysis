function [meanMinFreqForCondition,meanPowerAtMinFreqForCondition] = findMinBandWidth(powerVals,freqVals)
    meanPowerVals = mean(powerVals,1);
    meanMinFreqForCondition = freqVals(find(meanPowerVals == (min(meanPowerVals)),1));
    meanPowerAtMinFreqForCondition = min(meanPowerVals);
%     for iT = 1:size(powerVals,1)        
%         peakFreq(iT,1) = freqVals(powerVals(iT,:) == (max(powerVals(iT,:))));
%         powerAtPeakFreq(iT,1) = max(powerVals(iT,:));
%     end
%     meanPeakFreqForCondition = mean(peakFreq);
%     meanPowerAtPeakFreqForCondition = mean(powerAtPeakFreq);
end
