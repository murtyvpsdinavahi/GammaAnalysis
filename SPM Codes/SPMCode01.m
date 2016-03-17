

clear plotData Data
[~,folderName]=getFolderDetails(dataLog);
folderSegment = fullfile(folderName,'segmentedData');
folderLFP = fullfile(folderSegment,'LFP');
[~,timeVals] = loadlfpInfo(folderLFP);

a = 1; e = 1; s = 7; f = 1; o = 1; c = 1; t = 1; aa = 1; ae = 1; as = 1; ao = 1; av = 1; at = 1; 

[plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,[1:64]);                                                        
[Data,goodPos] = bipolarRef(plotData,'Bipolar','actiCap64',trialNums,allBadTrials);
            
for iTrial = 1:size(Data,2)
    eegData.trial{iTrial} = squeeze(Data(:,iTrial,:));
    eegData.time{iTrial} = timeVals;
end

for iChannel = 1:size(Data,1)
    eegData.label{iChannel} = num2str(iChannel);
end

spm_eeg_ft2spm(eegData,'Hello');