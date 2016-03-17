%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% displayGammaTuningOriEEG

clear; clc;

% Defaults
LGamma = [25 35]; TGamma = [40 70];
protocolType = 'Ori'; poolOriFlag = 1; 
oriPoolList = {0,45,90,135}; oValsPooledUnique = [0 45 90 135];
refChan = 'Bipolar';
LGammaPowerCutOff = 1; % in dB
HGammaPowerCutOff = 1; % in dB
g1Color = 'b'; g2Color = 'r';

tapers = [2 3]; mtFFTTapers = [1 1];
movingWin = [0.4 0.01];
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

subjectsToAnayse = {'SB','AD','GR','AV','NC','PM','VV'};%,'AB','RS','PJ'};
sidesToAnalyse = [1,2,2,2,2,2,1];%,1,2,2];
colorVals = zeros(length(subjectsToAnayse),3);

figH = figure(randi(100000)); 
tfPlotsGrid = [0.05 0.05 0.9 0.9];
[~,~,tfPlotsGridPosPerSubject] = getPlotHandles(length(subjectsToAnayse),1,tfPlotsGrid,0.02);
    for subjectNum = 1:length(subjectsToAnayse)
    %     subjectNum = 17;    

        clear subjectName
        subjectName = subjectsToAnayse{subjectNum};

        % Get dataLog file for given subject and protocol
        clear dataLog
        dataLog = getDataLog(dataLogList,subjectName,protocolType);

        % Get data for best stimulus
        clear Data goodPos timeVals commonBipolarEEGChannels
        commonBipolarEEGChannels = sides{sidesToAnalyse(subjectNum)};
        [Data,goodPos,timeVals,oValsUnique] = getDataForProtocolGAV(dataLog,protocolType,refChan,commonBipolarEEGChannels);
        
%         % Pool across orientations
%         if poolOriFlag
%             oriPoolList = {[0],[22.5,45,67.5],[90],[112.5,135,157.5]};
%             oriPoolList = {0,45,90,135};
%             [Data,goodPos] = getCombiPoolData(Data,goodPos,oriPoolList,oValsUnique);
%             oValsUnique = oValsPooledUnique;
%         end 

        % Get STFT for given Data
        mtmParams.tapers = tapers;
        mtmParams.err=0;
        mtmParams.pad=-1;
        mtmParams.Fs = dataLog{9, 2};
        
        clear dSForProtocol tAxis fAxis tfPlotsGridPosForProtocol
        [dSForProtocol,tAxis,fAxis] = getSTFTForProtocolGAV(Data,goodPos,movingWin,mtmParams,timeVals,BLPeriod(1),BLPeriod(2));
        tfPlotsGridPosForProtocol = getPlotHandles(1,size(dSForProtocol,3),tfPlotsGridPosPerSubject{subjectNum});
        
%         tWindow = (tAxis>STPeriod(1)) & (tAxis<=STPeriod(2));
%         fWindowLGamma = (fAxis>LGamma(1)) & (fAxis<=LGamma(2));
%         fWindowTGamma = (fAxis>TGamma(1)) & (fAxis<=TGamma(2));
%         
%         changeInPowerAveElecLGammaSTFT(subjectNum,:) = squeeze(mean(mean(dSForProtocol(tWindow,fWindowLGamma,:),1),2));
%         changeInPowerAveElecTGammaSTFT(subjectNum,:) = squeeze(mean(mean(dSForProtocol(tWindow,fWindowTGamma,:),1),2));
        
        % Pool across orientations
        if poolOriFlag
%             oriPoolList = {[0],[22.5,45,67.5],[90],[112.5,135,157.5]};            
            [Data,goodPos] = getCombiPoolData(Data,goodPos,oriPoolList,oValsUnique);
            oValsUnique = oValsPooledUnique;
        end        
        
        % Get stSpectrum for calculating orientation selectivity
        clear rawPSDStimSingleElec rawPSDBLSingleElec fAxisMT
        mtmParams.tapers = mtFFTTapers;
        [rawPSDStimSingleElec,rawPSDBLSingleElec,fAxisMT] = getMTFFTForProtocol(Data,goodPos,mtmParams,timeVals,BLPeriod,STPeriod);
        
        % get frequencies
        clear badFreqPos LGammaPos TGammaPos
        badFreqPos = getBadFreqPos(noisePeak,noiseBandwidth,fAxisMT); % remove noise peaks
        LGammaPos = setdiff(intersect(find(fAxisMT>=LGamma(1)),find(fAxisMT<=LGamma(2))),badFreqPos);
        TGammaPos = setdiff(intersect(find(fAxisMT>=TGamma(1)),find(fAxisMT<=TGamma(2))),badFreqPos);
        
        clear rawPSDStimSingleElecLGamma rawPowerBLSingleElecLGamma rawPSDStimSingleElecTGamma rawPowerBLSingleElecTGamma 
        rawPowerStimSingleElecLGamma = squeeze(sum(rawPSDStimSingleElec(LGammaPos,:,:),1));
        rawPowerBLSingleElecLGamma = squeeze(sum(rawPSDBLSingleElec(LGammaPos,:,:),1));
        
        rawPowerStimSingleElecTGamma = squeeze(sum(rawPSDStimSingleElec(TGammaPos,:,:),1));
        rawPowerBLSingleElecTGamma = squeeze(sum(rawPSDBLSingleElec(TGammaPos,:,:),1));
        
        clear changeInPowerSingleElecLGamma changeInPowerSingleElecTGamma
        changeInPowerSingleElecLGamma = 10*conv2Log(rawPowerStimSingleElecLGamma./rawPowerBLSingleElecLGamma);
        changeInPowerSingleElecTGamma = 10*conv2Log(rawPowerStimSingleElecTGamma./rawPowerBLSingleElecTGamma);
        
        changeInPowerAveElecLGamma(subjectNum,:) = squeeze(mean(changeInPowerSingleElecLGamma,1));
        changeInPowerAveElecTGamma(subjectNum,:) = squeeze(mean(changeInPowerSingleElecTGamma,1));
        
%         clear rawPSDStimAveElecLGamma rawPSDStimAveElecTGamma
%         rawPSDStimAveElecLGamma = squeeze(mean(rawPowerStimSingleElecLGamma,1));
%         rawPSDStimAveElecTGamma = squeeze(mean(rawPowerStimSingleElecTGamma,1));
        
        [po1(subjectNum,1),os1(subjectNum,1)] = getPOandOS(changeInPowerAveElecLGamma(subjectNum,:),oValsUnique);
        [po1(subjectNum,2),os1(subjectNum,2)] = getPOandOS(changeInPowerAveElecTGamma(subjectNum,:),oValsUnique);
        
        % Plot TFs for protocol
        clear cLimsAllProtocols
        for iProt = 1:size(dSForProtocol,3)
            subplot(tfPlotsGridPosForProtocol(iProt)); pcolor(tAxis,fAxis,dSForProtocol(:,:,iProt)'); shading interp;
            cLimsAllProtocols(iProt,:) = caxis;
        end
        
        % Set Clims
        for iProt = 1:size(dSForProtocol,3)
            subplot(tfPlotsGridPosForProtocol(iProt)); caxis([min(cLimsAllProtocols(:)) max(cLimsAllProtocols(:))]);
            xlim([-0.2 1.2]); ylim([0 120]);
        end
        
        drawnow;
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% changeInPowerAveElecLGammaSTFTNormalised = changeInPowerAveElecLGammaSTFT./repmat(max(changeInPowerAveElecLGammaSTFT,[],2),1,size(changeInPowerAveElecLGammaSTFT,2));
% changeInPowerAveElecTGammaSTFTNormalised = changeInPowerAveElecTGammaSTFT./repmat(max(changeInPowerAveElecTGammaSTFT,[],2),1,size(changeInPowerAveElecTGammaSTFT,2));
% 
% numSubjectsToAnalyse = length(subjectsToAnayse);
% figI = figure(randi(10000)); errorbar(1:length(oValsUnique),mean(changeInPowerAveElecLGammaSTFTNormalised,1),std(changeInPowerAveElecLGammaSTFTNormalised,[],1)./sqrt((numSubjectsToAnalyse)),'color',g1Color,'linewidth',2); hold on;
% errorbar(1:length(oValsUnique),mean(changeInPowerAveElecTGammaSTFTNormalised,1),std(changeInPowerAveElecTGammaSTFTNormalised,[],1)./sqrt((numSubjectsToAnalyse)),'color',g2Color,'linewidth',2); hold on;
% legend('Low Gamma','Traditional Gamma');
% 
% % figure
% for iJK = 1:numSubjectsToAnalyse
% %     iJK = 1;
%     clear gammaVals
%     gammaVals(1,:) = changeInPowerAveElecLGammaSTFTNormalised(iJK,:);
%     gammaVals(2,:) = changeInPowerAveElecTGammaSTFTNormalised(iJK,:);
%     [~,prefOrientationIndex] = (max(gammaVals(1,:)));
%     
%     gammaValsShift = gammaVals(:,1:prefOrientationIndex-1);
%     gammaVals(:,1:prefOrientationIndex-1) = [];
%     gammaVals = [gammaVals gammaValsShift];
% %     plot(1:length(oValsUnique),gammaVals)
% %     pause
%     gammaValsAllSubjects(:,:,iJK) = gammaVals;
% end
% 
% figJ = figure(randi(10000)); errorbar(1:length(oValsUnique),mean(gammaValsAllSubjects(1,:,:),3),std(gammaValsAllSubjects(1,:,:),[],3)./sqrt((numSubjectsToAnalyse)),'color',g1Color,'linewidth',2); hold on;
% errorbar(1:length(oValsUnique),mean(gammaValsAllSubjects(2,:,:),3),std(gammaValsAllSubjects(2,:,:),[],3)./sqrt((numSubjectsToAnalyse)),'color',g2Color,'linewidth',2); hold on;
% legend('Low Gamma','Traditional Gamma');
% title('Change in Power realligned to each subject"s best orientation (orientation that shows maximum gamma power)');
% % xlabel('Orientations: 0; data polled across 22.5,45,67.5; 90; Data pooled across 112.5,135,157.5');
% 
% savefig(figH,'tfPlots.fig');
% savefig(figI,'unallignedPlot.fig');
% savefig(figJ,'allignedPlots.fig');
% close all;
% save('OriTuningSelectSubjects.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
histPos = 0:5:180;
hOR1 =hist(squeeze(po1(:,1)),histPos);
hOR2 =hist(squeeze(po1(:,2)),histPos);
bar(histPos,hOR1,'FaceColor',g1Color); 
hold on;
bar(histPos,hOR2,'FaceColor',g2Color); 
    
changeInPowerAveElecLGammaNormalised = changeInPowerAveElecLGamma./repmat(max(changeInPowerAveElecLGamma,[],2),1,size(changeInPowerAveElecLGamma,2));
changeInPowerAveElecTGammaNormalised = changeInPowerAveElecTGamma./repmat(max(changeInPowerAveElecTGamma,[],2),1,size(changeInPowerAveElecTGamma,2));

figure; errorbar(1:length(oValsUnique),mean(changeInPowerAveElecLGammaNormalised,1),std(changeInPowerAveElecLGammaNormalised,[],1)./sqrt((numSubjectsToAnalyse)),'color',g1Color,'linewidth',2); hold on;
errorbar(1:length(oValsUnique),mean(changeInPowerAveElecTGammaNormalised,1),std(changeInPowerAveElecTGammaNormalised,[],1)./sqrt((numSubjectsToAnalyse)),'color',g2Color,'linewidth',2); hold on;
legend('Low Gamma','Traditional Gamma');
% title('Change in Power realligned to each subject"s best orientation (orientation that shows maximum gamma power)');
% xlabel('Orientations: 0; data polled across 22.5,45,67.5; 90; Data pooled across 112.5,135,157.5');


% figure
numSubjectsToAnalyse = length(subjectsToAnayse);
for iJK = 1:numSubjectsToAnalyse
%     iJK = 1;
    clear gammaVals
    gammaVals(1,:) = changeInPowerAveElecLGammaNormalised(iJK,:);
    gammaVals(2,:) = changeInPowerAveElecTGammaNormalised(iJK,:);
    [~,prefOrientationIndex] = (max(gammaVals(1,:)));
    
    gammaValsShift = gammaVals(:,1:prefOrientationIndex-1);
    gammaVals(:,1:prefOrientationIndex-1) = [];
    gammaVals = [gammaVals gammaValsShift];
%     plot(1:length(oValsUnique),gammaVals)
%     pause
    gammaValsAllSubjects(:,:,iJK) = gammaVals;
end

figure; errorbar(1:length(oValsUnique),mean(gammaValsAllSubjects(1,:,:),3),std(gammaValsAllSubjects(1,:,:),[],3)./sqrt((numSubjectsToAnalyse)),'color',g1Color,'linewidth',2); hold on;
errorbar(1:length(oValsUnique),mean(gammaValsAllSubjects(2,:,:),3),std(gammaValsAllSubjects(2,:,:),[],3)./sqrt((numSubjectsToAnalyse)),'color',g2Color,'linewidth',2); hold on;
legend('Low Gamma','Traditional Gamma');
title('Change in Power realligned to each subject"s best orientation (orientation that shows maximum gamma power)');
% xlabel('Orientations: 0; data polled across 22.5,45,67.5; 90; Data pooled across 112.5,135,157.5');



% % figure
% numSubjectsToAnalyse = length(subjectsToAnayse);
% for iJK = 1:numSubjectsToAnalyse
% %     iJK = 1;
%     clear gammaVals
%     gammaVals(1,:) = changeInPowerAveElecLGammaNormalised(iJK,:);
%     gammaVals(2,:) = changeInPowerAveElecTGammaNormalised(iJK,:);
%     [~,prefOrientationIndex] = (max(gammaVals(2,:)));
%     
%     gammaValsShift = gammaVals(:,1:prefOrientationIndex-1);
%     gammaVals(:,1:prefOrientationIndex-1) = [];
%     gammaVals = [gammaVals gammaValsShift];
% %     plot(1:length(oValsUnique),gammaVals)
% %     pause
%     gammaValsAllSubjects(:,:,iJK) = gammaVals;
% end
% 
% figure; errorbar(1:length(oValsUnique),mean(gammaValsAllSubjects(1,:,:),3),std(gammaValsAllSubjects(1,:,:),[],3)./sqrt((numSubjectsToAnalyse)),'color',g1Color,'linewidth',2); hold on;
% errorbar(1:length(oValsUnique),mean(gammaValsAllSubjects(2,:,:),3),std(gammaValsAllSubjects(2,:,:),[],3)./sqrt((numSubjectsToAnalyse)),'color',g2Color,'linewidth',2); hold on;
% legend('Low Gamma','Traditional Gamma');
% 
% % figure; plot(1:9,squeeze(gammaValsAllSubjects(1,:,:)));