function subjectDataset = getSubjectDataset(presets, dataset, varargin)

subjects = fieldnames(dataset);
blocks = presets.setup.blocks;
conditions = presets.setup.conditions;
morphSets = presets.setup.morphSets;

[subjectGrid, blockGrid, conditionGrid, morphSetGrid] = ...
    ndgrid(subjects, blocks, conditions, morphSets);

conditionMatrix = ...
    [subjectGrid(:), blockGrid(:), conditionGrid(:), morphSetGrid(:)];

for i = 1:length(conditionMatrix)
    subject = subjectGrid{i};
    block = blockGrid{i};

    if strcmp(varargin, 'fufa')
        condition = conditions;
        conditionID = strjoin(condition, '_');
    else
        condition = conditionGrid{i};
        conditionID = condition;
    end

    morphSet = morphSetGrid{i};
    morphNums = num2str(morphSet);
    morphSetID = ['morphs_', strrep(morphNums, '  ', '_')];

    fprintf(...
        ['\n\n', ...
        'Getting trials and ERPs for %s - %s - %s - %s', ...
        '\n\n'], ...
        subject, block, conditionID, morphSetID)

    data = dataset.(subject);

    trialData = extractTrials(presets, data, block, condition, morphSet);

    if isempty(trialData.trial)
        fprintf(...
            ['\n\n', ...
            'No trial data for %s - %s - %s - %s found. \n' ...
            'Skipping...', ...
            '\n\n'], ...
            subject, block, conditionID, morphSetID ...
            )
        continue
    else

        % Reapply baseline correction following artifact rejection
        % THIS IS NOW REDUNDANT WITH DEMEANDATASET() CALL NOW IN MAIN.
        cfg = [];
        cfg.preproc.demean = 'yes';
        cfg.preproc.baselinewindow = [-0.2, 0];
        cfg.preproc.detrend = 'yes';
        trialData = ft_preprocessing(cfg, trialData);

        % Store trials
        subjectDataset.(subject).(block).(conditionID).(morphSetID).trials = trialData;

        % Average trials to compute ERP
        cfg = presets.erp.subject.computation;
        erp = ft_timelockanalysis(cfg, trialData);
        subjectDataset.(subject).(block).(conditionID).(morphSetID).erp = erp;

    end
end

% Write dataset to file if specified
if isfield(presets.paths.output.erp.subject, 'data') && ...
        isfield(presets.paths.output.erp.subject.fufa, 'data')

    if strcmp(varargin, 'fufa')
        subjectFufaDataset = subjectDataset;
        save( ...
            [presets.paths.output.erp.subject.fufa.data, ...
            'subjectFufaDataset'], ...
            'subjectFufaDataset', ...
            '-nocompression', ...
            '-v7.3' ...
            ) 
    elseif nargin < 3
        save( ...
            [presets.paths.output.erp.subject.data, ...
            'subjectDataset'], ...
            'subjectDataset', ...
            '-nocompression', ...
            '-v7.3' ...
            ) 
    end

end

end