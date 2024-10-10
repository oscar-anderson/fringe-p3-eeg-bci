%% Preprocess
function preprocessedDataset = preprocessDataset(presets, rawDataset)

subjects = fieldnames(rawDataset);
numSubjects = numel(subjects);

for iSubject = 1:numSubjects
    subject = subjects{iSubject};
    rawData = rawDataset.(subject);

    % Define trials
    trl = defineTrials(presets, rawData);

    % Preprocess raw data
    cfg = presets.preprocessing;
    cfg.dataset = rawData;
    cfg.trl = trl;
    data = ft_preprocessing(cfg);

    % Threshold raw data
    cfg = presets.thresholding;
    cfg = ft_artifact_threshold(cfg, data);
    data = ft_rejectartifact(cfg, data);

    % Store in dataset
    preprocessedDataset.(subject) = data;
end

% Write dataset to file if specified
if isfield(presets.paths.output, 'preprocessed')
    save( ...
        presets.paths.output.preprocessed, ...
        'preprocessedDataset', ...
        '-nocompression', ...
        '-v7.3' ...
        ) 
end
end