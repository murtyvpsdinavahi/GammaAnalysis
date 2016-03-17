function [rawPSDStimSingleElec,rawPSDBLSingleElec,rawPSDStimPoolElec,rawPSDBLPoolElec,fAxis] = getMTSpectrumForData(Data,timeVals,goodPos,mtmParams,BLPeriod,STPeriod)
% get time axes
    clear tStim tBL    
    tStim =  (timeVals>STPeriod(1)) & (timeVals<=STPeriod(2));
    tBL = (timeVals>BLPeriod(1)) & (timeVals<=BLPeriod(2));

    clear dataTFAllElec totPos
    dataMTAllElec = [];
    totPos = 0;    
    
    for iCD = 1:size(Data,1)
        clear dataMT
        dataMT=Data(iCD,goodPos{iCD},:);
        dataMT=squeeze(dataMT);
        if size(dataMT,1)>size(dataMT,2); dataMT = dataMT'; end;
        dataMTAllElec = [dataMTAllElec;dataMT];
        totPos = totPos + length(goodPos{iCD});
        
        % MTFFT For each electrode separately 
        mtmParams.trialave=1;
        [rawPSDStimSingleElec(:,iCD)] = mtspectrumc(dataMT(:,tStim)',mtmParams);
        [rawPSDBLSingleElec(:,iCD)] = mtspectrumc(dataMT(:,tBL)',mtmParams);  
    end
    
    % MTFFT for data pooled across all electrodes
    clear rawPSDStimElec rawPSDBLElec fAxisStim fAxisBL
    mtmParams.trialave=1;
    [rawPSDStimPoolElec,fAxisStim] = mtspectrumc(dataMTAllElec(:,tStim)',mtmParams);
    [rawPSDBLPoolElec,fAxisBL] = mtspectrumc(dataMTAllElec(:,tBL)',mtmParams);
    
    clear fAxis;
    if (fAxisStim ~= fAxisBL); error('frequency axes in BL and stim period different'); else fAxis = fAxisStim; end;
end