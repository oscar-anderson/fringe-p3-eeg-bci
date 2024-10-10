function rawDataset = getRawDataset(presets)

rawDataPath = presets.paths.rawData;
subjects = presets.setup.subjects;

for iSubject = 1:numel(subjects)
    subject = subjects{iSubject};
    subjectID = sprintf('sub%02d', subject);
    subjectFolderID = sprintf('sub-%02d', subject);
    subjectDataPath = [rawDataPath, subjectFolderID, '/eeg/'];

    subjectDirectory = dir(subjectDataPath);
    subjectFiles = {subjectDirectory.name};
    rawDataExtension = '.bdf';
    isRawData = contains(subjectFiles, rawDataExtension);
    rawDataFilename = subjectFiles{isRawData};
    
    rawData = [subjectDataPath, rawDataFilename];
    rawDataset.(subjectID) = rawData;
end
