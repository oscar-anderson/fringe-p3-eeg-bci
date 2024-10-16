function postIcaDataset = rejectBadComponents(presets, dataset)

% Set random number generator seed for reproducability
rng(1)

subjects = fieldnames(dataset);
numSubjects = numel(subjects);
for iSubject = 1:numSubjects
    subject = subjects{iSubject};
    data = dataset.(subject);
    
    % Decompose data
    cfg = presets.ica.analysis;
    comp = ft_componentanalysis(cfg, data);
    
    % Count components to inspect
    numComponents = numel(comp.label);
    
    % Plot component time series
    figure;
    cfg = presets.ica.topography;
    cfg.component = 1:numComponents;
    ft_topoplotIC(cfg, comp);
    
    % Plot component topographies
    timeSeries = figure;
    cfg = presets.ica.timeSeries;
    cfg.component = 1:numComponents;
    ft_databrowser(cfg, comp)
    
    % Log components to remove
    waitfor(timeSeries); % Wait for time series figure to be closed
    prompt = ...
        sprintf('Input an array of components to remove from %s:', subject);
    badComponents = input(prompt);
    
    % Remove bad components
    cfg = presets.ica.rejection;
    cfg.component = badComponents;
    postIcaDataset.(subject) = ft_rejectcomponent(cfg, comp, data);

end

% Write dataset to file if specified
if isfield(presets.paths.output, 'postICA')
    save( ...
        [presets.paths.output.postICA, ...
        'postIcaDataset'], ...
        'postIcaDataset', ...
        '-nocompression', ...
        '-v7.3' ...
        ) 
end

% Save output component plots?

% Error handling?

end