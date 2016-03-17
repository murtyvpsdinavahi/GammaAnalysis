% Modified by MD (10-03-2016) from Supratim's code
% (displayGammaTuningSFOri.m)

function badFreqPos = getBadFreqPos(noisePeak,noiseBandwidth,freqVals)
badFreqs = noisePeak:noisePeak:max(freqVals);

badFreqPos = [];
for i=1:length(badFreqs)
    badFreqPos = cat(2,badFreqPos,intersect(find(freqVals>=badFreqs(i)-noiseBandwidth),find(freqVals<=badFreqs(i)+noiseBandwidth)));
end
end