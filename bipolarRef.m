function [Data,goodPos] = bipolarRef(plotData,refChanIndex,gridMontage,trialNums,allBadTrials)
        
%         [~,hemBipolarLocs] = loadChanLocs(gridMontage);
        Data = zeros(size(plotData,1),size(plotData,2),size(plotData,3));
        
        if ischar(refChanIndex)
            if strcmp(refChanIndex,'SingleWire')
                for iBP = 1:size(allBadTrials,2)
                    goodTrials = setdiff(trialNums,allBadTrials{iBP});
                    goodPos{iBP} = find(ismember(trialNums,goodTrials));
                end
                Data = plotData;
                chanlocs = loadChanLocs(gridMontage,refChanIndex);
            elseif strcmp(refChanIndex,'Hemisphere')
                [chanlocs,hemBipolarLocs] = loadChanLocs(gridMontage,refChanIndex);
                for iBP = 1:size(allBadTrials,2)
                    badTrials1 = allBadTrials{hemBipolarLocs(iBP,1)};
                    badTrials2 = allBadTrials{hemBipolarLocs(iBP,2)};
                    badTrialsCommon = union(badTrials1,badTrials2);
                    goodTrials = setdiff(trialNums,badTrialsCommon);
                    goodPos{iBP} = find(ismember(trialNums,goodTrials));
                end
                hWD = waitbar(0,['Creating hem_bipolar data for electrode 1 of ' num2str(size(plotData,1)) ' electrodes...']);
                for iH = 1:size(plotData,1)
                    waitbar((iH/size(plotData,1)),hWD,['Creating bipolar data for electrode ' num2str(iH) ' of ' num2str(size(plotData,1)) ' electrodes...']);
%                     badPos{iH} = union(allBadTrials{hemBipolarLocs(iH,1)},allBadTrials{hemBipolarLocs(iH,2)});
                    Data(iH,:,:) = plotData(hemBipolarLocs(iH,1),:,:) - plotData(hemBipolarLocs(iH,2),:,:);
                end
                close(hWD);
                clear hWD;
            elseif strcmp(refChanIndex,'Average')
%                 badPos = allBadTrials;
                chanlocs = loadChanLocs(gridMontage,refChanIndex);
                for iBP = 1:size(allBadTrials,2)
                    goodTrials = setdiff(trialNums,allBadTrials{iBP});
                    goodPos{iBP} = find(ismember(trialNums,goodTrials));
                end
                hWD = waitbar(0,['Creating average referenced data for electrode 1 of ' num2str(size(plotData,1)) ' electrodes...']);
                aveData = mean(plotData,1);
                for iH = 1:size(plotData,1)
                    waitbar((iH/size(plotData,1)),hWD,['Creating average referenced data for electrode ' num2str(iH) ' of ' num2str(size(plotData,1)) ' electrodes...']);
                    Data(iH,:,:) = plotData(iH,:,:) - aveData;
                end
    %             Data((iH+1),:,:) = (-1)*aveData;
                close(hWD);
                clear hWD;
            elseif strcmp(refChanIndex,'Bipolar')
                [chanlocs,~,bipolarLocs] = loadChanLocs(gridMontage,refChanIndex);
                maxChanKnown = 96; % default set by MD while creating bipolar montage; this might be different for different montages!!!
                hWD = waitbar(0,['Creating bipolar data for electrode 1 of ' num2str(size(plotData,1)) ' electrodes...']);            

                for iH = 1:size(bipolarLocs,1)
                    waitbar((iH/size(bipolarLocs,1)),hWD,['Creating bipolar data for electrode ' num2str(iH) ' of ' num2str(size(bipolarLocs,1)) ' electrodes...']);
                    clear chan1 chan2 unipolarChan1 unipolarChan2 badTrialsChan1 badTrialsChan2 goodTrials
                    chan1 = bipolarLocs(iH,1);
                    chan2 = bipolarLocs(iH,2);                

                    if chan1<(maxChanKnown+1)
                        unipolarChan1 = plotData(chan1,:,:);
                        badPosChan1 = allBadTrials{chan1};
                        badTrialsChan1 = allBadTrials{chan1};
                    else
                        unipolarChan1 = Data(chan1,:,:);
                        badPosChan1 = badPos{chan1};
                        badTrialsChan1 = badTrialsCommon{chan1};
                    end

                    if chan2<(maxChanKnown+1)
                        unipolarChan2 = plotData(chan2,:,:);
                        badPosChan2 = allBadTrials{chan2};
                        badTrialsChan2 = allBadTrials{chan2};
                    else
                        unipolarChan2 = Data(chan2,:,:);
                        badPosChan2 = badPos{chan2};
                        badTrialsChan2 = badTrialsCommon{chan2};
                    end

                    Data(iH,:,:) = unipolarChan1 - unipolarChan2;
                    badPos{iH} = union(badPosChan1,badPosChan2);
                    badTrialsCommon{iH} = union(badTrialsChan1,badTrialsChan2);
                    goodTrials = setdiff(trialNums,badTrialsCommon{iH});
                    goodPos{iH} = find(ismember(trialNums,goodTrials));

                end
                close(hWD);
                clear hWD;
            else
                error('Please give a valid referencing scheme: SingleWire|Hemisphere|Average|Bipolar|[elec number]');
            end
        else
            chanlocs = loadChanLocs(gridMontage);
            hRD = waitbar(0,['Rereferencing data for electrode 1 of ' num2str(size(plotData,1)) ' electrodes...']);
            for iR = 1:size(plotData,1)
                waitbar((iR/size(plotData,1)),hRD,['Rereferencing data for electrode ' num2str(iR) ' of ' num2str(size(plotData,1)) ' electrodes...']);
                Data(iR,:,:) = plotData(iR,:,:) - plotData(refChanIndex,:,:);
                badPos{iR} = intersect(allBadTrials{iR},allBadTrials{refChanIndex});
            end
%             Data((iR+1),:,:) = (-1)*plotData(refChanIndex,:,:);
            close(hRD);
            clear hRD;
        end
        
end