function folderMP = parCalculateAndSaveMPSpectrumPerCombination(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,dataLog,refChanIndex,Max_iterations,wrap,freqRange,timeRange)

% This is for conversion of double to int16 (one decimal point precision is
% lost). Do not change this unless necessary, as that would lead to
% truncation of data or further loss of precision. 
conversionFactor = 1000; 

    % Define defaults
    if ~exist('refChanIndex','var') || isempty(refChanIndex); refChanIndex = 'Bipolar'; end
    if ~exist('Max_iterations','var') || isempty(Max_iterations); Max_iterations = 100; end    
    if ~exist('freqRange','var') || isempty(freqRange); freqRange = [0 250]; end
    if ~exist('timeRange','var') || isempty(timeRange); timeRange = [-0.5 1.5]; end
    if ~exist('wrap','var') || isempty(wrap); wrap = 1; end
    if ~exist('clusterName','var') || isempty(clusterName); clusterName = 'local'; end
    
    [~,folderName]=getFolderDetails(dataLog);
    gridMontage = dataLog{15,2};
    electrodesToAnalyse = dataLog{7,2}; % Take all electrodes

    % make folders
    folderComb = [num2str(a) num2str(e) num2str(s) num2str(f) num2str(o) num2str(c) num2str(t) num2str(aa) num2str(ae) num2str(as) num2str(ao) num2str(av) num2str(at)];
    folderMP = (fullfile(folderName,'MPData',refChanIndex,num2str(Max_iterations),folderComb)); % folder for storing MPData for a given dataLog for a given reference system      
    folderTemp = 'MPData/'; % code places intermediate data in this folder.
    tag = 'temp';
    
    diary(fullfile(folderMP,'MPReport'))
    
    makeDirectory(folderMP);
    makeDirectory(folderTemp);
    
    % Load Data
    folderLFP = fullfile(folderName,'segmentedData','LFP');

    [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,electrodesToAnalyse);
    [Data,goodPos] = bipolarRef(plotData,refChanIndex,gridMontage,trialNums,allBadTrials);
    [~,timeVals] = loadlfpInfo(folderLFP);

    Fs=1/(timeVals(2)-timeVals(1));       % Sampling Frequency    
    
    combinationDetails.a = a;
    combinationDetails.e = e;
    combinationDetails.s = s;
    combinationDetails.f = f;
    combinationDetails.o = o;
    combinationDetails.c = c;
    combinationDetails.t = t;
    combinationDetails.aa = aa;
    combinationDetails.ae = ae;
    combinationDetails.as = as;
    combinationDetails.ao = ao;
    combinationDetails.av = av;
    combinationDetails.at = at;
    save(fullfile(folderMP,'combinationDetails.mat'),'combinationDetails');
    
    %%%%%%%%%%%%%%%%%%% Perform MP for each electrode %%%%%%%%%%%%%%%%%%%%%
    [totElecs,~,L] = size(Data);
    freqAxis = 0:Fs/L:Fs/2;              % frequency axis
    timeL = (timeVals>=timeRange(1)) & (timeVals<timeRange(2));
    freqL = (freqAxis>=freqRange(1)) & (freqAxis<freqRange(2));
%     hWE = waitbar(0,['Analysing for electrode 1 of ' num2str(totElecs) ' electrode...'],'position',[465.0000  409.7500  270.0000   56.2500]);

%     poolObj = parpool(clusterName);

    parfor electrodeNum = 1:totElecs
        disp(['electrode: ' num2str(electrodeNum)])
        tic;
        
%         waitbar((electrodeNum-1)/totElecs,hWE,['Analysing for electrode ' num2str(electrodeNum) ' of ' num2str(totElecs) ' electrode...']);
%         clearvars -except folderMP folderTemp tag totElecs hWE Data electrodeNum goodPos timeVals Fs baselineS Max_iterations wrap timeRange freqRange conversionFactor numberOfTrials
        
        data = squeeze(Data(electrodeNum,goodPos{electrodeNum},:));
        numTrials = length(goodPos{electrodeNum});             % length of signal

        %Import data
        X=data';
        signalRange = [1 L];                  % full range
        importData(X,folderTemp,tag,signalRange,Fs);

        % Perform Gabor decomposition
        Numb_points = L;                      % length of the signal
        runGabor(folderTemp,tag,Numb_points,Max_iterations);

        % Retrieve information
        gaborInfo = getGaborData(folderTemp,tag,1);

        % Reconstruct energy        
        recEnAll=zeros(length(freqAxis),L);  % initialising energy matrix

%         atomListIndex = intersect(find(freqAxis>freqRange(1)),find(freqAxis<freqRange(2)));
%         disp('Reconstructing energy...');
%         hWT = waitbar(0,['Reconstructing energy for trial 1 of ' num2str(numTrials) ' trials...']);
        for i=1:numTrials
            try
%             waitbar((i-1)/numTrials,hWT,['Reconstructing energy for trial ' num2str(i) ' of ' num2str(numTrials) ' trials...']);
%             atomList = find(ismember(gaborInfo{1, i}.gaborData(2,:),atomListIndex));
                atomList = []; % all atoms
                recEn=reconstructEnergyFromAtomsMPP(gaborInfo{i}.gaborData,L,wrap,atomList);
            catch err
                disp(['electrode: ' num2str(electrodeNum) ' trial: ' num2str(i)])
                disp(err);
                recEn = zeros(size(recEnAll,1),size(recEnAll,2));
            end
            recEnAll =recEnAll + recEn;
        end
%         close(hWT);

        logMeanEn=conv2Log(recEnAll/numTrials);      % log mean TF energy matrix for all trials
                        
        rawEnergyAllElec{electrodeNum} = int16(logMeanEn(freqL,timeL)*conversionFactor);
        numberOfTrials(electrodeNum) = numTrials;
%         save(fullfile(folderMP,['elec' num2str(electrodeNum) '.mat']),'rawEnergy');      
        toc;
    end
%     delete(poolObj);
%     close(hWE);

timeVals = timeVals(timeL);
freqAxis = freqAxis(freqL);

MPExtractionInfo{1,1} = 'freqAxis';
MPExtractionInfo{1,2} = freqAxis;
MPExtractionInfo{2,1} = 'timeVals';
MPExtractionInfo{2,2} = timeVals;
MPExtractionInfo{3,1} = 'freqRange';
MPExtractionInfo{3,2} = freqRange;
MPExtractionInfo{4,1} = 'timeRange';
MPExtractionInfo{4,2} = timeRange;
MPExtractionInfo{5,1} = 'MaxIterations';
MPExtractionInfo{5,2} = Max_iterations;
MPExtractionInfo{6,1} = 'conversionFactor';
MPExtractionInfo{6,2} = conversionFactor;

clear electrodeNum
    for electrodeNum = 1:totElecs
        clear rawEnergy;
        rawEnergy = rawEnergyAllElec{electrodeNum};
        save(fullfile(folderMP,['elec' num2str(electrodeNum) '.mat']),'rawEnergy');
    end
    
save(fullfile(folderMP,'MPExtractionInfo.mat'),'MPExtractionInfo');
save(fullfile(folderMP,'numberOfTrials.mat'),'numberOfTrials');
    
diary off;
end