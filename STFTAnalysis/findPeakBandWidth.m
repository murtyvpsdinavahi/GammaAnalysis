function [meanPeakFreqForCondition,meanPowerAtPeakFreqForCondition,fwhmXVals,fwhmYVals,fwhmPower] = findPeakBandWidth(powerVals,freqVals)%,powerFit,muFit)
    
    meanPowerVals = mean(powerVals,1);
    meanPeakFreqForCondition = freqVals(find(meanPowerVals == (max(meanPowerVals)),1));
    meanPowerAtPeakFreqForCondition = max(meanPowerVals);

%     halfMax = meanPowerAtPeakFreqForCondition/2;
%     
%     ascHalfPowerVals = fliplr(powerVals(freqVals<=meanPeakFreqForCondition));
%     desHalfPowerVals = powerVals(freqVals>meanPeakFreqForCondition);
%     
%     fwhm1 = length(ascHalfPowerVals) - (find(ascHalfPowerVals<=halfMax,1,'first')) + 2;
%     fwhm2 = length(ascHalfPowerVals) + (find(desHalfPowerVals<=halfMax,1,'first')) - 1;
%     
%     fwhmXVals = freqVals(fwhm1:fwhm2);
%     fwhmYVals = meanPowerVals(fwhm1:fwhm2);
 
%     fwhmIntegral = polyint(powerFit);
%     fwhmPower = diff(polyval(fwhmIntegral,[fwhmXVals(1) fwhmXVals(end)],[],muFit));
    
%     fwhmPower=trapz(fwhmXVals,fwhmYVals);
end