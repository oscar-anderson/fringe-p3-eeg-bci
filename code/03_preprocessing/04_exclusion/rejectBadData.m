function postExclusionDataset = rejectBadData(presets, dataset)

subjects = fieldnames(dataset);
numSubjects = numel(subjects);
for iSubject = 1:numSubjects
    subject = subjects{iSubject};
    data = dataset.(subject);

    % Inspect trials and channels
    cfg = [];
    cfg.viewmode = 'butterfly';
    cfg.ylim = [-100, 100];
    timeSeries = ft_databrowser(cfg, data);
    
    % Reject trials
    waitfor(timeSeries)
    cfg = presets.exclusion;
    cfg.method = 'channel';
    data = ft_rejectvisual(cfg, data);
    
    % Reject channels
    cfg = presets.exclusion;
    cfg.method = 'trial';
    cleanData = ft_rejectvisual(cfg, data);

    postExclusionDataset.(subject) = cleanData;
end

% Write dataset to file if specified
if isfield(presets.paths.output, 'postExclusion')
    save( ...
        [presets.paths.output.postExclusion, ...
        'postExclusionDataset'], ...
        'postExclusionDataset', ...
        '-nocompression', ...
        '-v7.3' ...
        ) 
end