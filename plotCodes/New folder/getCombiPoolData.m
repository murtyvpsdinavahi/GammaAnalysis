function [xData,xPos] = getCombiPoolData(Data,goodPos,xPoolList,xValsUnique)

    for ixPool = 1:length(xPoolList)
        clear xForPool
        xForPool = xPoolList{ixPool};
        oldPos = 0;
        for iNumXPool = 1:length(xForPool)
            clear xVal
            xVal = find(xValsUnique == xForPool(iNumXPool));
            if ~exist('xData','var')
                xData = cell(size(Data,1),length(xPoolList));
            end
            clear tempData
            tempData = Data{1,xVal};
            xData(1,ixPool) = {cat(2,xData{1,ixPool},tempData)};
            for iElec = 1:size(tempData,1)
                clear tempXPos
                tempXPos = goodPos{1,xVal}{1,iElec} + oldPos;
                if ~exist('xPos','var')
                    [xPos{1,1:length(xPoolList)}] = deal(cell(1,size(tempData,1)));
                end
                xPos{1,ixPool}{1,iElec} = (cat(2,xPos{1,ixPool}{1,iElec},tempXPos));
            end
            oldPos = oldPos + size(tempData,2);
        end
    end
    
end