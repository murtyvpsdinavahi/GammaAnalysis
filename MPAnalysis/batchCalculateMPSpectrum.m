function batchCalculateMPSpectrum(extractTheseIndices,refChan,Max_iterations,freqRange,timeRange,wrap)

% Define defaults
if ~exist('refChan','var') || isempty(refChan); refChan = 'Bipolar'; end
if ~exist('Max_iterations','var') || isempty(Max_iterations); Max_iterations = 100; end    
if ~exist('freqRange','var') || isempty(freqRange); freqRange = [0 250]; end
if ~exist('timeRange','var') || isempty(timeRange); timeRange = [-0.5 1.5]; end
if ~exist('wrap','var') || isempty(wrap); wrap = 1; end
    
[~,subjectNames,expDates,protocolNames,~,gridType,folderSourceString] = allDataLogsForAnalysisHumanEEG;

totIndex = length(extractTheseIndices);
disp(['Starting batch extraction of band power per protocol. Total indices: ' num2str(totIndex)]);
for iV = 1:totIndex
    
    clear iIndex
    iIndex = extractTheseIndices(iV);

    clear subjectName expDate protocolName dataLog folderName folderExtract folderLFP
    subjectName = subjectNames{iIndex};
    expDate = expDates{iIndex};
    protocolName = protocolNames{iIndex};

    dataL{1,2} = subjectName;
    dataL{2,2} = gridType;
    dataL{3,2} = expDate;
    dataL{4,2} = protocolName;
    dataL{14,2} = folderSourceString;

    [~,folderName]=getFolderDetails(dataL);
    clear dataLog
    load(fullfile(folderName,'dataLog.mat'));
    
    if ~exist('EEGChannels','var')||isempty(EEGChannels); EEGChannels = dataLog{7, 2}; end;
    if ~exist('Fs','var')||isempty(Fs); Fs = dataLog{9, 2}; end;
    
    disp([char(10) 'Analysing index ' num2str(iV) ' of ' num2str(totIndex)]);
    disp(['Index no.: ' num2str(iIndex)]);
    disp([subjectName expDate protocolName]);
    
    disp([refChan ' Referencing...']);
    calculateMPSpectrumPerProtocol(dataLog,refChan,Max_iterations,freqRange,timeRange,wrap)
end