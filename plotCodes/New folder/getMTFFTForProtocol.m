function [rawPSDStimSingleElec,rawPSDBLSingleElec,fAxis] = getMTFFTForProtocol(dataMTForProtocol,goodPosForProtocol,mtmParams,timeVals,BLPeriod,STPeriod)
    
    xLen = size(dataMTForProtocol,2);    
    for x=1:xLen
        clear Data goodPos dSSingleElec
        Data = dataMTForProtocol{1,x};
        goodPos = goodPosForProtocol{1,x};
        if x == 1
            if (diff(int16(STPeriod*100)) ~= diff(int16(BLPeriod*100))); error('STim and BL periods must be the same'); end;
            tStim =  (timeVals>STPeriod(1)) & (timeVals<=STPeriod(2));
            [~,fAxis] = mtspectrumc(ones(1,length(find(tStim==1)))',mtmParams);
            rawPSDStimSingleElec = zeros(length(fAxis),size(Data,1),xLen);
            rawPSDBLSingleElec = zeros(length(fAxis),size(Data,1),xLen);
        end
        [rawPSDStimSingleElec(:,:,x),rawPSDBLSingleElec(:,:,x)] = getMTSpectrumForData(Data,timeVals,goodPos,mtmParams,BLPeriod,STPeriod);
    end
end