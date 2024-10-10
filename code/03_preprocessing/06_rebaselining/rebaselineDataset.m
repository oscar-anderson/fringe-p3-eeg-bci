function rebaselinedDataset = rebaselineDataset(presets, dataset)

cfg = [];
cfg.demean = presets.preprocessing.demean;
cfg.baselinewindow = presets.preprocessing.baselinewindow;

subjects = fieldnames(dataset);
numSubjects = numel(subjects);
for iSubject = 1:numSubjects
    subject = subjects{iSubject};
    data = dataset.(subject);

    rebaselinedDataset.(subject) = ft_preprocessing(cfg, data);
end

% Write dataset to file if specified
if isfield(presets.paths.output, 'rebaselined')
    save( ...
        [presets.paths.output.rebaselined, ...
        'rebaselinedDataset'], ...
        'rebaselinedDataset', ...
        '-nocompression', ...
        '-v7.3' ...
        ) 
end
