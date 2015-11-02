function plotFreqPoolElec(dataLog,refChan,elecForPool)

[~,folderName]=getFolderDetails(dataLog);
load(fullfile(folderName,['analysedDataAllElec_' refChan '.mat']));
numCond = size(analysedDataAllElec,2);

folderExtract = fullfile(folderName,'extractedData');
[~,aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,cValsUnique,tValsUnique,aaValsUnique,...
        aeValsUnique,asValsUnique,aoValsUnique,avValsUnique,atValsUnique] = loadParameterCombinations(folderExtract);
    
aLen = length(aValsUnique);
eLen = length(eValsUnique);
sLen = length(sValsUnique);
fLen = length(fValsUnique);
oLen = length(oValsUnique);
cLen = length(cValsUnique);
tLen = length(tValsUnique);
aaLen = length(aaValsUnique);
aeLen = length(aeValsUnique);
asLen = length(asValsUnique);
aoLen = length(aoValsUnique);
avLen = length(avValsUnique);
atLen = length(atValsUnique);

if aLen == numCond; xAxis = aValsUnique; xTitle = 'Azimuth'; end
if eLen == numCond; xAxis = eValsUnique; xTitle = 'Elevation'; end
if sLen == numCond; xAxis = sValsUnique; xTitle = 'Size'; end
if fLen == numCond; xAxis = fValsUnique; xTitle = 'Spatial Frequency'; end
if oLen == numCond; xAxis = oValsUnique; xTitle = 'Orientation'; end
if cLen == numCond; xAxis = cValsUnique; xTitle = 'Contrast'; end
if tLen == numCond; xAxis = tValsUnique; xTitle = 'Temporal Frequency'; end
if aaLen == numCond; xAxis = aaValsUnique; xTitle = 'Auditory Azimuth'; end
if aeLen == numCond; xAxis = aeValsUnique; xTitle = 'Auditory Elevation'; end
if asLen == numCond; xAxis = asValsUnique; xTitle = 'Ripple Frequency'; end
if aoLen == numCond; xAxis = aoValsUnique; xTitle = 'Ripple Phase'; end
if avLen == numCond; xAxis = avValsUnique; xTitle = 'Ripple Volume'; end
if atLen == numCond; xAxis = atValsUnique; xTitle = 'Ripple Velocity'; end

for iElec = 1:length(elecForPool)
    Elec = elecForPool(iElec);
    for iCond = 1:size(analysedDataAllElec,2)
        peakFreqHG = analysedDataAllElec(iCond).meanPeakFreqAllElecHG{1, 1};
        peakFreqHGElec(iCond,iElec) = peakFreqHG(Elec);

        peakFreqLG = analysedDataAllElec(iCond).meanPeakFreqAllElecLG{1, 1};
        peakFreqLGElec(iCond,iElec) = peakFreqLG(Elec);
    end
end

figure; plot(xAxis,mean(peakFreqLGElec,2),'b'); xlabel(xTitle);
figure; plot(xAxis,mean(peakFreqHGElec,2),'r'); xlabel(xTitle);
end