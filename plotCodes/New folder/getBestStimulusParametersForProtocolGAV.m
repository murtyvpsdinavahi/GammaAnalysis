function [a,e,s,f,o,c,t,aa,ae,as,ao,av,at] = getBestStimulusParametersForProtocolGAV(dataLog,protocolType,bestStimulusFolder)

    a = 1; e = 1; s = 1; f = 1; o = 1; c = 1; t = 1; 
    aa = 1; ae = 1; as = 1; ao = 1; av = 1; at = 1;
    subjectName = dataLog{1,2};
    [~,folderName]=getFolderDetails(dataLog);
    folderExtract = fullfile(folderName,'extractedData');
    
    if strcmpi(protocolType,'SF') || strcmpi(protocolType,'Ori')
        if ~exist('bestStimulusFolder','var') || isempty(bestStimulusFolder); error('Folder containing the best stimulus has not been specified...'); end;
        load(fullfile(bestStimulusFolder,'bestStimulus.mat'));
        bestStimIndex = find(strcmpi({bestStimulus.subjectName},subjectName));
        subjectSF = bestStimulus(bestStimIndex).SF;
        subjectOri = bestStimulus(bestStimIndex).Orientation;
        [~,~,~,~,fValsUnique,oValsUnique] = loadParameterCombinations(folderExtract);
        f = find(int8(fValsUnique*10) == int8(subjectSF*10));
        o = find(int16(oValsUnique*10) == int16(subjectOri*10));
    else
        [~,~,~,sValsUnique,~,~,cValsUnique,tValsUnique] = loadParameterCombinations(folderExtract);
        switch protocolType
            case 'SIZE';        s = length(sValsUnique);
            case 'CON';         c = length(cValsUnique);
            case 'TFDF';        t = length(tValsUnique); % For Drifting gratings
            case 'TFCP';        t = length(tValsUnique); % For Counterphasing gratings
        end
    end
end