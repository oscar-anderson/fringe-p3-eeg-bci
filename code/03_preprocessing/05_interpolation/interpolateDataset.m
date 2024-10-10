function interpolatedDataset = interpolateDataset(presets, dataset)

% Initialise channel neighbours
cfg = presets.neighbours;
neighbours = ft_prepare_neighbours(cfg);
    
subjects = fieldnames(dataset);
numSubjects = numel(subjects);
for iSubject = 1:numSubjects
    subject = subjects{iSubject};
    data = dataset.(subject);

    % Identify missing channels
    channels = {neighbours(:).label};
    isMissing = ~ismember(channels, data.label);
    missingChannels = channels(isMissing);
    
    % Interpolate
    cfg = presets.interpolation;
    cfg.neighbours = neighbours;
    cfg.missingchannel = missingChannels;
    interpolatedDataset.(subject) = ft_channelrepair(cfg, data);
end

% Write dataset to file if specified
if isfield(presets.paths.output, 'interpolated')
    save( ...
        [presets.paths.output.interpolated, ...
        'interpolatedDataset'], ...
        'interpolatedDataset', ...
        '-nocompression', ...
        '-v7.3' ...
        ) 
end