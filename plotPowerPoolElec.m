function plotPowerPoolElec(dataLog,refChan,elecForPool,numCond)

[~,folderName]=getFolderDetails(dataLog);
load(fullfile(folderName,['analysedDataAllElec_' refChan '.mat']));
if ~exist('numCond','var')||isempty(numCond); numCond = size(analysedDataAllElec,2); end

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
    for iCond = 1:numCond
        peakPowerHG = analysedDataAllElec(iCond).meanPowerAllElecHG{1, 1};
        peakPowerHGElec(iCond,iElec) = peakPowerHG(Elec);

        peakPowerLG = analysedDataAllElec(iCond).meanPowerAllElecLG{1, 1};
        peakPowerLGElec(iCond,iElec) = peakPowerLG(Elec); 
    end
end

figure; plot(xAxis,mean(peakPowerLGElec,2),'b')
hold on; plot(xAxis,mean(peakPowerHGElec,2),'r')
xlabel(xTitle);

end