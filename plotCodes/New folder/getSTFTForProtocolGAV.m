function [dSForProtocol,tAxis,fAxis] = getSTFTForProtocolGAV(dataTFForProtocol,goodPosForProtocol,movingWin,mtmParams,timeVals,BLMin,BLMax)
    
    xLen = size(dataTFForProtocol,2);    
    for x=1:xLen
        clear Data goodPos dSSingleElec
        Data = dataTFForProtocol{1,x};
        goodPos = goodPosForProtocol{1,x};
        for iCD=1:size(Data,1)
            clear dataTF
            dataTF=squeeze(Data(iCD,goodPos{iCD},:));
            if iCD == 1
                 [~,~,tAxis,fAxis] = getSTFT(dataTF,movingWin,mtmParams,timeVals,BLMin,BLMax);
                 dSSingleElec = zeros(length(tAxis),length(fAxis),size(Data,1));
            end
            [~,dSSingleElec(:,:,iCD)] = getSTFT(dataTF,movingWin,mtmParams,timeVals,BLMin,BLMax);
        end
        if x == 1
            dSForProtocol = zeros(size(dSSingleElec,1),size(dSSingleElec,2),xLen);
        end
        dSForProtocol(:,:,x) = mean(dSSingleElec,3);
    end
end