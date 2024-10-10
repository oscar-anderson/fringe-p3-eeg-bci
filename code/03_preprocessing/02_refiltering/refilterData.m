function refilteredDataset = refilterData(presets, dataset)

% Add condition where if presets.refilter is empty, refilteredDataset is
% simply returned as dataset unchanged?

refilteredDataset = dataset;

subjects = presets.refilter.subjects;
bpFreq = presets.refilter.bpFreq;

numSubjects = numel(subjects);
for iSubject = 1:numSubjects
    subject = subjects{iSubject};
    data = dataset.(subject);

    cfg.bpfilter = 'yes';
    cfg.bpfreq = bpFreq;
    cfg.bpfilttype = 'fir';
    
    refilteredDataset.(subject) = ft_preprocessing(cfg, data);
end

% Write dataset to file if specified
if isfield(presets.paths.output, 'refiltered')
    save( ...
        [presets.paths.output.refiltered, ...
        'refilteredDataset'], ...
        'refilteredDataset', ...
        '-nocompression', ...
        '-v7.3' ...
        ) 
end

end