
function plotGammaAnalysisAllSubjects
% Defaults
mtmParams.tapers=[2 3];
mtmParams.trialave=0;
mtmParams.err=0;
mtmParams.pad=-1;

movingWin = [0.4 0.01];

baseline = [-0.5 0];
stimPeriod = [0.25 0.75];
fBandWidth = 20;
numElec = 5;

gridType = 'EEG';
folderSourceString = 'D:';
gridMontage = 'actiCap64';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display main options
% fonts
fontSizeSmall = 10; fontSizeMedium = 12; fontSizeLarge = 16; fontSizeTiny = 8;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Panels
panelHeight = 0.3; panelStartHeight = 0.68;

subjectsPanelUIGap = 0.025; subjectsPanelUIWidth = 0.283; 
subjectsStartXPos = subjectsPanelUIGap; subjectsStartYPos = subjectsPanelUIGap;
subjectsListHeight = 1-2*subjectsPanelUIGap; 
subjectsPanelButtonHeight = (1-10*subjectsPanelUIGap)/5;

dynamicPanelWidth = 0.18; dynamicStartPos = 0.245; 
timingPanelWidth = 0.18; timingStartPos = dynamicStartPos+dynamicPanelWidth;
tfPanelWidth = 0.18; tfStartPos = timingStartPos+timingPanelWidth;
plotOptionsPanelWidth = 0.18; plotOptionsStartPos = tfStartPos+tfPanelWidth;
backgroundColor = 'w';

timingHeight = 0.1; timingTextWidth = 0.5; timingBoxWidth = 0.20;

figure;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Subjects Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[dataLogList.folderEEG,dataLogList.subjectNames,dataLogList.expDates,dataLogList.protocolNames,dataLogList.protocolTypes,dataLogList.gridType,dataLogList.folderSourceString] = allDataLogsForAnalysisHumanEEG;
subjectString = unique(dataLogList.subjectNames);
protocolString = unique(dataLogList.protocolTypes);

hSubjectsPanel = uipanel('Title','Subjects','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[subjectsStartXPos panelStartHeight subjectsPanelUIWidth panelHeight]);

hSubjectList = uicontrol('Parent',hSubjectsPanel,'Unit','Normalized', 'Position',[subjectsStartXPos subjectsStartYPos subjectsPanelUIWidth subjectsListHeight], ...
    'Style','listbox','String',subjectString,'FontSize',fontSizeSmall);

uicontrol('Parent',hSubjectsPanel,'Unit','Normalized', 'Position',...
    [subjectsStartXPos+subjectsPanelUIWidth+2*subjectsPanelUIGap 1-subjectsPanelUIGap-subjectsPanelButtonHeight subjectsPanelUIWidth subjectsPanelButtonHeight], ...
    'Style','pushbutton','String','>>','FontSize',fontSizeSmall,'Callback',{@add_Callback});

uicontrol('Parent',hSubjectsPanel,'Unit','Normalized', 'Position',...
    [subjectsStartXPos+subjectsPanelUIWidth+2*subjectsPanelUIGap 1-3*subjectsPanelUIGap-2*subjectsPanelButtonHeight subjectsPanelUIWidth subjectsPanelButtonHeight], ...
    'Style','pushbutton','String','<<','FontSize',fontSizeSmall,'Callback',{@remove_Callback});

uicontrol('Parent',hSubjectsPanel,'Unit','Normalized', 'Position',...
    [subjectsStartXPos+subjectsPanelUIWidth+2*subjectsPanelUIGap 1-5*subjectsPanelUIGap-3*subjectsPanelButtonHeight subjectsPanelUIWidth subjectsPanelButtonHeight], ...
    'Style','pushbutton','String','Plot 1 subject','FontSize',fontSizeSmall,'Callback',{@plotOneSubject_Callback});

uicontrol('Parent',hSubjectsPanel,'Unit','Normalized', 'Position',...
    [subjectsStartXPos+subjectsPanelUIWidth+2*subjectsPanelUIGap 1-7*subjectsPanelUIGap-(7/2)*subjectsPanelButtonHeight subjectsPanelUIWidth subjectsPanelButtonHeight/2], ...
    'Style','text','String','Protocol for pooling','FontSize',fontSizeSmall);

hProtocolType = uicontrol('Parent',hSubjectsPanel,'Unit','Normalized', 'Position',...
    [subjectsStartXPos+subjectsPanelUIWidth+2*subjectsPanelUIGap 1-7*subjectsPanelUIGap-4*subjectsPanelButtonHeight subjectsPanelUIWidth subjectsPanelButtonHeight/2], ...
    'Style','popup','String',protocolString,'FontSize',fontSizeSmall);

uicontrol('Parent',hSubjectsPanel,'Unit','Normalized', 'Position',...
    [subjectsStartXPos+subjectsPanelUIWidth+2*subjectsPanelUIGap 1-9*subjectsPanelUIGap-5*subjectsPanelButtonHeight subjectsPanelUIWidth subjectsPanelButtonHeight], ...
    'Style','pushbutton','String','Pool all subjects','FontSize',fontSizeSmall);

hPoolList = uicontrol('Parent',hSubjectsPanel,'Unit','Normalized', 'Position',...
    [subjectsStartXPos+2*subjectsPanelUIWidth+4*subjectsPanelUIGap subjectsStartYPos subjectsPanelUIWidth subjectsListHeight], ...
    'Style','listbox','FontSize',fontSizeSmall);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Options panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hTFParamPanel = uipanel('Title','Options','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[tfStartPos panelStartHeight tfPanelWidth panelHeight]);

% Tapers TW
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','TW','FontSize',fontSizeSmall);
hMTMTapersTW = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [timingTextWidth 1-timingHeight timingBoxWidth*2 timingHeight], ...
    'Style','edit','String',mtmParams.tapers(1),'FontSize',fontSizeSmall,'Callback',{@resetMTMParams_Callback}); 

% Tapers 'k'
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-2*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','k','FontSize',fontSizeSmall);
hMTMTapersK = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [timingTextWidth 1-2*timingHeight timingBoxWidth*2 timingHeight], ...
    'Style','edit','String',mtmParams.tapers(2),'FontSize',fontSizeSmall,'Callback',{@resetMTMParams_Callback});

% Window length
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-3*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','wLen','FontSize',fontSizeSmall);
hMTMwLen = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [timingTextWidth 1-3*timingHeight timingBoxWidth*2 timingHeight], ...
    'Style','edit','String',movingWin(1),'FontSize',fontSizeSmall,'Callback',{@resetMTMParams_Callback}); 

% Window translation step
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-4*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','wStep','FontSize',fontSizeSmall);
hMTMwStep = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [timingTextWidth 1-4*timingHeight timingBoxWidth*2 timingHeight], ...
    'Style','edit','String',movingWin(2),'FontSize',fontSizeSmall,'Callback',{@resetMTMParams_Callback}); 

% Baseline
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-5*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Basline (s)','FontSize',fontSizeSmall);
hBaselineMin = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-5*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(baseline(1)),'FontSize',fontSizeSmall,'Callback',{@resetMTMParams_Callback});
hBaselineMax = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-5*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(baseline(2)),'FontSize',fontSizeSmall,'Callback',{@resetMTMParams_Callback});

% Stim Period
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-6*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Stim period (s)','FontSize',fontSizeSmall);
hStimPeriodMin = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-6*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(stimPeriod(1)),'FontSize',fontSizeSmall); 
hStimPeriodMax = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-6*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(stimPeriod(2)),'FontSize',fontSizeSmall); 

% Frequency Band
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-7*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','freqBand range','FontSize',fontSizeSmall);
hfBand = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-7*timingHeight timingBoxWidth*2 timingHeight], ...
    'Style','popup','String','Low Gamma|High Gamma','FontSize',fontSizeSmall);

% Desired Bandwidth
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-8*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Bandwidth','FontSize',fontSizeSmall);
hfBandWidth = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-8*timingHeight timingBoxWidth*2 timingHeight], ...
    'Style','edit','String',num2str(fBandWidth),'FontSize',fontSizeSmall);

% Reference
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-9*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Reference','FontSize',fontSizeSmall);
hRefChan = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-9*timingHeight timingBoxWidth*2 timingHeight], ...
    'Style','popup','String','Bipolar|Hemisphere','FontSize',fontSizeSmall); 

% Number of elecs to pool
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-10*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Num. elecs to pool','FontSize',fontSizeSmall);
hnumElec = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-10*timingHeight timingBoxWidth*2 timingHeight], ...
    'Style','edit','String',num2str(numElec),'FontSize',fontSizeSmall);

    function plotOneSubject_Callback(~,~)
        
        % Initialise with variables
        subjectNameIndex = get(hSubjectList,'value');
        subjectName = subjectString{subjectNameIndex};
        refChanIndex = get(hRefChan,'val');
        switch refChanIndex
            case 1; refChan = 'Bipolar';
            case 2; refChan = 'Hemisphere';
        end
        numElec = str2num(get(hnumElec,'string'));
        gammaBandIndex = get(hfBand,'val');
        switch gammaBandIndex
            case 1; gammaBand = 'Low Gamma';
            case 2; gammaBand = 'High Gamma';
        end
        desiredBandWidth = str2num(get(hfBandWidth,'string'));
        
        mtmParams.tapers(1) = str2double(get(hMTMTapersTW,'String'));
        mtmParams.tapers(2) = str2double(get(hMTMTapersK,'String'));
        movingWin(1) = str2double(get(hMTMwLen,'String'));
        movingWin(2) = str2double(get(hMTMwStep,'String'));

        BLMin = str2double(get(hBaselineMin,'string'));
        BLMax = str2double(get(hBaselineMax,'string'));
        STMin = str2double(get(hStimPeriodMin,'string'));
        STMax = str2double(get(hStimPeriodMax,'string'));

        subjectIndices = find(strcmp(subjectName,dataLogList.subjectNames));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  figure  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        figure('numbertitle', 'off','name',subjectName);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Display main options
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Panels
        figPanelHeight = 0.16; panelGap = 0.02;
        capPanelWidth = 0.14; capStartPos = panelGap;
        plotPanelWidth = 0.14; plotStartPos = 1-panelGap-plotPanelWidth;
        gridStartPos = panelGap*3 + capPanelWidth; gridWidth = 1-(gridStartPos+plotPanelWidth+3*panelGap);

        % Topoplot panels
        electrodeCapPosSF = [capStartPos 1-1*panelGap-1*figPanelHeight capPanelWidth figPanelHeight];
        capSFHandle = subplot('Position',electrodeCapPosSF); axis off;

        electrodeCapPosOri = [capStartPos 1-3*panelGap-2*figPanelHeight capPanelWidth figPanelHeight];
        capOriHandle = subplot('Position',electrodeCapPosOri); axis off;

        electrodeCapPosCon = [capStartPos 1-5*panelGap-3*figPanelHeight capPanelWidth figPanelHeight];
        capConHandle = subplot('Position',electrodeCapPosCon); axis off;

        electrodeCapPosSize = [capStartPos 1-7*panelGap-4*figPanelHeight capPanelWidth figPanelHeight];
        capSizeHandle = subplot('Position',electrodeCapPosSize); axis off;

        electrodeCapPosTF = [capStartPos 1-9*panelGap-5*figPanelHeight capPanelWidth figPanelHeight];
        capTFHandle = subplot('Position',electrodeCapPosTF); axis off;

        % Grid panels
        gridPosSF = [gridStartPos 1-1*panelGap-1*figPanelHeight gridWidth figPanelHeight];
        gridPosOri = [gridStartPos 1-3*panelGap-2*figPanelHeight gridWidth figPanelHeight];
        gridPosCon = [gridStartPos 1-5*panelGap-3*figPanelHeight gridWidth figPanelHeight];
        gridPosSize = [gridStartPos 1-7*panelGap-4*figPanelHeight gridWidth figPanelHeight];
        gridPosTF = [gridStartPos 1-9*panelGap-5*figPanelHeight gridWidth figPanelHeight];

        % Plot panels
        plotPosSF = [plotStartPos 1-1*panelGap-1*figPanelHeight plotPanelWidth figPanelHeight];
        plotSFHandle = subplot('Position',plotPosSF); axis off;

        plotPosOri = [plotStartPos 1-3*panelGap-2*figPanelHeight plotPanelWidth figPanelHeight];
        plotOriHandle = subplot('Position',plotPosOri); axis off;

        plotPosCon = [plotStartPos 1-5*panelGap-3*figPanelHeight plotPanelWidth figPanelHeight];
        plotConHandle = subplot('Position',plotPosCon); axis off;

        plotPosSize = [plotStartPos 1-7*panelGap-4*figPanelHeight plotPanelWidth figPanelHeight];
        plotSizeHandle = subplot('Position',plotPosSize); axis off;

        plotPosTF = [plotStartPos 1-9*panelGap-5*figPanelHeight plotPanelWidth figPanelHeight];
        plotTFHandle = subplot('Position',plotPosTF); axis off;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % SF Plot
        plotHandles.topo = capSFHandle;
        plotHandles.gridPos = gridPosSF;
        plotHandles.plot = plotSFHandle;
        protocolType = 'SF';
        plotProtocolResults(dataLogList,subjectIndices,protocolType,'Ori',plotHandles,gridMontage,refChan,numElec,gammaBand,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ORI Plot
        plotHandles.topo = capOriHandle;
        plotHandles.gridPos = gridPosOri;
        plotHandles.plot = plotOriHandle;
        protocolType = 'Ori';
        plotProtocolResults(dataLogList,subjectIndices,protocolType,'none',plotHandles,gridMontage,refChan,numElec,gammaBand,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % CON Plot
        plotHandles.topo = capConHandle;
        plotHandles.gridPos = gridPosCon;
        plotHandles.plot = plotConHandle;
        protocolType = 'Con';
        plotProtocolResults(dataLogList,subjectIndices,protocolType,'none',plotHandles,gridMontage,refChan,numElec,gammaBand,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % SIZE Plot
        plotHandles.topo = capSizeHandle;
        plotHandles.gridPos = gridPosSize;
        plotHandles.plot = plotSizeHandle;
        protocolType = 'Size';
        plotProtocolResults(dataLogList,subjectIndices,protocolType,'none',plotHandles,gridMontage,refChan,numElec,gammaBand,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % TF Plot
        plotHandles.topo = capTFHandle;
        plotHandles.gridPos = gridPosTF;
        plotHandles.plot = plotTFHandle;
        protocolType = 'TFDF'; % For Drifting gratings
        plotProtocolResults(dataLogList,subjectIndices,protocolType,'none',plotHandles,gridMontage,refChan,numElec,gammaBand,movingWin,mtmParams,BLMin,BLMax,STMin,STMax,desiredBandWidth)

    end

    function add_Callback(~,~)
        subjectNameIndex = get(hSubjectList,'value');
        subjectName = subjectString(subjectNameIndex);
        subjectPoolString = get(hPoolList,'string');
        subjectPoolString = union(subjectPoolString,subjectName);
        subjectPoolString(strcmp('',subjectPoolString)) = [];
        set(hPoolList,'string',subjectPoolString);
    end

    function remove_Callback(~,~)
        subjectIndex = get(hPoolList,'value');        
        subjectPoolString = get(hPoolList,'string');
        subjectName = subjectPoolString(subjectIndex);
        subjectPoolString(strcmp(subjectName,subjectPoolString)) = '';
        set(hPoolList,'string',subjectPoolString);
    end
end