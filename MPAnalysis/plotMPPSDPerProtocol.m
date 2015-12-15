function plotMPPSDPerProtocol(dataLog,EEGChannel,freqBand,refChan,BLPeriod,STPeriod,downSampleSize)

if ~exist('dataLog','var')
    try
        dataLog = evalin('base','dataLog');
    catch
        fileExt = {'*.mat'};
        [hdrfile,path] = uigetfile(fileExt, 'Select dataLog file...');
        if hdrfile(1) == 0, return; end
        fname = fullfile(path,hdrfile);
        dataL = load(fname);
        dataLog = dataL.dataLog;
    end
end

if ~exist('EEGChannel','var')||isempty(EEGChannel); EEGChannel = 92; end;
if ~exist('freqBand','var')||isempty(freqBand); freqBand = [0 150]; end;
if ~exist('refChan','var')||isempty(refChan); refChan = 'Bipolar'; end;
% if ~exist('numElec','var')||isempty(numElec); numElec = 5; end;
if ~exist('BLPeriod','var')||isempty(BLPeriod); BLPeriod = [-0.5 0]; end;
if ~exist('STPeriod','var')||isempty(STPeriod); STPeriod = [0.25 0.75]; end;
if ~exist('downSampleSize','var')||isempty(downSampleSize); downSampleSize = 1; end;

[~,folderName]=getFolderDetails(dataLog);
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

plotNum = 1;
for a=1:aLen
    for e=1:eLen
        for s=1:sLen
            for f=1:fLen
                for o=1:oLen
                    for c=1:cLen
                        for t=1:tLen
                            for aa=1:aaLen
                                for ae=1:aeLen
                                    for as=1:asLen
                                        for ao=1:aoLen
                                            for av=1:avLen
                                                for at=1:atLen                                                    
                                                    [dPower,fRangeVal] = calculateMPPSDPerCombinationPerElectrode(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,dataLog,EEGChannel,...
                                                            freqBand,refChan,BLPeriod,STPeriod,downSampleSize);                                   
                                                    
                                                    rgbVals = getColorRGB(plotNum);
                                                    figure(1008); hold on;
                                                    plot(fRangeVal,dPower,'Color',rgbVals,'Linewidth',1);
                                                    
                                                    drawnow
                                                    plotNum = plotNum + 1;
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
end

