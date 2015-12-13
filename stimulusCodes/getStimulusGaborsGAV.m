function [gaborBackground,gaborRing] = getStimulusGaborsGAV(dataLog,a,e,s,f,o,c,t)

rFactor = 10;

% Load parameter combinations and timeVals
[~,folderName]=getFolderDetails(dataLog);
folderExtract = fullfile(folderName,'extractedData');
[~,aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,cValsUnique,tValsUnique] = loadParameterCombinations(folderExtract);
    
gaborBackground.azimuthDeg = aValsUnique(a);
gaborBackground.elevationDeg = eValsUnique(e);
gaborBackground.sigmaDeg = sValsUnique(s);
gaborBackground.spatialFreqCPD = fValsUnique(f);
gaborBackground.orientationDeg = oValsUnique(o);
gaborBackground.contrastPC = cValsUnique(c);
gaborBackground.temporalFreqHz = tValsUnique(t);
gaborBackground.spatialPhaseDeg = 0;
% gaborBackground.radiusDeg = [0 3*sValsUnique(s)/rFactor];
gaborBackground.radiusDeg = [0 1*sValsUnique(s)/rFactor]; % MD, as for GAV protocols, radius:sigma = 1; 

gaborRing.azimuthDeg = 0;
gaborRing.elevationDeg = 0;
gaborRing.sigmaDeg = 0;
gaborRing.spatialFreqCPD = 0;
gaborRing.orientationDeg = 0;
gaborRing.contrastPC = 0;
gaborRing.temporalFreqHz = 0;
gaborRing.spatialPhaseDeg = 0;
gaborRing.radiusDeg = 0;
end