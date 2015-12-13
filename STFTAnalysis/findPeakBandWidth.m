function [meanPeakFreqForCondition,meanPowerAtPeakFreqForCondition] = findPeakBandWidth(powerVals,freqVals)
    meanPowerVals = mean(powerVals,1);
    meanPeakFreqForCondition = freqVals(find(meanPowerVals == (max(meanPowerVals)),1));
    meanPowerAtPeakFreqForCondition = max(meanPowerVals);
%     for iT = 1:size(powerVals,1)        
%         peakFreq(iT,1) = freqVals(powerVals(iT,:) == (max(powerVals(iT,:))));
%         powerAtPeakFreq(iT,1) = max(powerVals(iT,:));
%     end
%     meanPeakFreqForCondition = mean(peakFreq);
%     meanPowerAtPeakFreqForCondition = mean(powerAtPeakFreq);
end