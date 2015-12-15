function rawEnergy = loadMPSpectrum(folderMP,elecNumber,conversionFactor)
    load(fullfile(folderMP,['elec' num2str(elecNumber) '.mat']));
    rawEnergy = double(rawEnergy)/conversionFactor;
end