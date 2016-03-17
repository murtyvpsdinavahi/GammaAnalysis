% plotAllSubjectsGammaPower

clear; clc;

% Defaults
LGamma = [25 35]; TGamma = [40 70];
subjectsToIgnore = {'AR','GM','MP','SR','VB'};
protocolType = 'Ori';
refChan = 'Bipolar';
LGammaPowerCutOff = 1; % in dB
HGammaPowerCutOff = 1; % in dB

% tapers = [2 3];
tapers = [1 1];
BLPeriod = [-0.5 0]; STPeriod = [0.25 0.75];

commonBipolarEEGChannelsBothHem = [83 84 92 86 87 94];
commonBipolarEEGChannelsLeft = [83 84 92];
commonBipolarEEGChannelsRight = [86 87 94];
sides = {commonBipolarEEGChannelsLeft,commonBipolarEEGChannelsRight,commonBipolarEEGChannelsBothHem};

bestStimulusFolder = fullfile('D:','Plots');

noisePeak = 50; noiseBandwidth = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[dataLogList.folderEEG,dataLogList.subjectNames,dataLogList.expDates,dataLogList.protocolNames,dataLogList.protocolTypes,...
    dataLogList.gridType,dataLogList.folderSourceString,dataLogList.capMontage] = allDataLogsForAnalysisVisualGammaEEG;
subjectNamesUnique = unique(dataLogList.subjectNames);

colorVals = zeros(length(sides),length(subjectNamesUnique),3);
subjectNumToIgnore = [];
for iSide = 1:length(sides)
    commonBipolarEEGChannels = sides{iSide};
    for subjectNum = 1:length(subjectNamesUnique)
    %     subjectNum = 17;    

        subjectName = subjectNamesUnique{subjectNum};
        if ismember(subjectName,subjectsToIgnore); subjectNumToIgnore = [subjectNumToIgnore,subjectNum]; continue; end;

        % Get dataLog file for given subject and protocol
        dataLog = getDataLog(dataLogList,subjectName,protocolType);

        % Get data for best stimulus
        clear Data goodPos timeVals
        [Data,goodPos,timeVals] = getDataForBestStimulusGAV(dataLog,protocolType,refChan,commonBipolarEEGChannels,bestStimulusFolder);

        % Get MTFFT for given Data
        mtmParams.tapers = tapers;
        mtmParams.err=0;
        mtmParams.pad=-1;
        mtmParams.Fs = dataLog{9, 2};
        [rawPSDStimSingleElec,rawPSDBLSingleElec,~,~,fAxis] = getMTSpectrumForData(Data,timeVals,goodPos,mtmParams,BLPeriod,STPeriod);

        % get frequencies
        badFreqPos = getBadFreqPos(noisePeak,noiseBandwidth,fAxis); % remove noise peaks
        LGammaPos = setdiff(intersect(find(fAxis>=LGamma(1)),find(fAxis<=LGamma(2))),badFreqPos);
        TGammaPos = setdiff(intersect(find(fAxis>=TGamma(1)),find(fAxis<=TGamma(2))),badFreqPos);

        % Calculate change in power across gamma bands
        for iBand=1:2
            clear rawPowStim rawPowBL
            switch iBand
                case 1
                    rawPowStim = (sum(rawPSDStimSingleElec(LGammaPos,:),1));
                    rawPowBL = (sum(rawPSDBLSingleElec(LGammaPos,:),1));
                    changeInPower(iSide,iBand,subjectNum) = mean(10*conv2Log(rawPowStim./rawPowBL));
                    if changeInPower(iSide,iBand,subjectNum)>=LGammaPowerCutOff; colorVals(iSide,subjectNum,1) = 1; end;                    
                case 2
                    rawPowStim = (sum(rawPSDStimSingleElec(TGammaPos,:),1));
                    rawPowBL = (sum(rawPSDBLSingleElec(TGammaPos,:),1));
                    changeInPower(iSide,iBand,subjectNum) = mean(10*conv2Log(rawPowStim./rawPowBL));
                    if changeInPower(iSide,iBand,subjectNum)>=HGammaPowerCutOff; colorVals(iSide,subjectNum,3) = 1; end;
            end
        end
        scatterLabels{subjectNum} = subjectName;
    end
end
changeInPower(:,:,subjectNumToIgnore) = [];
scatterLabels(subjectNumToIgnore) = [];
colorVals(:,subjectNumToIgnore,:) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(randi(10000)); 
subplot(221); scatter(changeInPower(1,1,:),changeInPower(1,2,:),50,squeeze(colorVals(1,:,:)),'fill'); hold on;
set(gca,'fontsize',15);
xlabel('Change in Low Gamma Power (dB)','fontsize',15);
ylabel('Change in Traditional Gamma Power (dB)','fontsize',15);
title('Change in Power of Low vs Traditional Gamma: Left','fontsize',15); 
text(changeInPower(1,1,:)+0.1,changeInPower(1,2,:),scatterLabels,'fontsize',12);
xLimits = xlim; yLimits = ylim;
line(LGammaPowerCutOff*ones(100,1),linspace(yLimits(1),yLimits(2),100),'color','k');
line(linspace(xLimits(1),xLimits(2),100),HGammaPowerCutOff*ones(100,1),'color','k'); hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(222); scatter(changeInPower(2,1,:),changeInPower(2,2,:),50,squeeze(colorVals(2,:,:)),'fill'); hold on;
set(gca,'fontsize',15);
xlabel('Change in Low Gamma Power (dB)','fontsize',15);
ylabel('Change in Traditional Gamma Power (dB)','fontsize',15);
title('Change in Power of Low vs Traditional Gamma: Right','fontsize',15); 
text(changeInPower(2,1,:)+0.1,changeInPower(2,2,:),scatterLabels,'fontsize',12);
xLimits = xlim; yLimits = ylim;
line(LGammaPowerCutOff*ones(100,1),linspace(yLimits(1),yLimits(2),100),'color','k');
line(linspace(xLimits(1),xLimits(2),100),HGammaPowerCutOff*ones(100,1),'color','k'); hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(223); scatter(changeInPower(3,1,:),changeInPower(3,2,:),50,squeeze(colorVals(3,:,:)),'fill'); hold on;
set(gca,'fontsize',15);
xlabel('Change in Low Gamma Power (dB)','fontsize',15);
ylabel('Change in Traditional Gamma Power (dB)','fontsize',15);
title('Change in Power of Low vs Traditional Gamma: Both','fontsize',15); 
text(changeInPower(3,1,:)+0.1,changeInPower(3,2,:),scatterLabels,'fontsize',12);
xLimits = xlim; yLimits = ylim;
line(LGammaPowerCutOff*ones(100,1),linspace(yLimits(1),yLimits(2),100),'color','k');
line(linspace(xLimits(1),xLimits(2),100),HGammaPowerCutOff*ones(100,1),'color','k'); hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find out which side has higher gamma
clear colorVals
colorVals = zeros(size(changeInPower,3),3);
textColor = zeros(size(changeInPower,3),3);
latChangeInPower = zeros(2,size(changeInPower,3));
leftTextColor = [0.5 0.2 0];
rightTextColor = [0.2 0 0.5];
for subNum = 1:size(changeInPower,3)
    
    leftPower = squeeze(changeInPower(1,:,subNum));
    leftDist = sqrt(leftPower(1)^2+leftPower(2)^2);


    rightPower = squeeze(changeInPower(2,:,subNum));
    rightDist = sqrt(rightPower(1)^2+rightPower(2)^2);

    if leftDist>rightDist
        latChangeInPower(:,subNum) = leftPower;
        textColor(subNum,:) = leftTextColor;
    else
        latChangeInPower(:,subNum) = rightPower;
        textColor(subNum,:) = rightTextColor;
    end
    
    for iBand = 1:2
        switch iBand
            case 1
                if latChangeInPower(iBand,subNum)>=LGammaPowerCutOff; colorVals(subNum,1) = 1; end;                
            case 2
                if latChangeInPower(iBand,subNum)>=HGammaPowerCutOff; colorVals(subNum,3) = 1; end;                
        end
    end
end

% Plot
subplot(224); scatter(latChangeInPower(1,:),latChangeInPower(2,:),50,colorVals,'fill'); hold on;
set(gca,'fontsize',15);
xlabel('Change in Low Gamma Power (dB)','fontsize',15);
ylabel('Change in Traditional Gamma Power (dB)','fontsize',15);
title('Change in Power of Low vs Traditional Gamma: Max','fontsize',15); 
textHandle = text(latChangeInPower(1,:)+0.1,latChangeInPower(2,:),scatterLabels,'fontsize',12);
clear subNum
for subNum = 1:size(changeInPower,3)
    set(textHandle(subNum),'color',textColor(subNum,:));
end
text(0.1,0.9,'Left','color',leftTextColor,'fontsize',15,'unit','normalized');
text(0.1,0.8,'Right','color',rightTextColor,'fontsize',15,'unit','normalized');
xLimits = xlim; yLimits = ylim;
line(LGammaPowerCutOff*ones(100,1),linspace(yLimits(1),yLimits(2),100),'color','k');
line(linspace(xLimits(1),xLimits(2),100),HGammaPowerCutOff*ones(100,1),'color','k'); hold off
