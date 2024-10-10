function groupDataset = getGroupDataset(presets, subjectDataset)

% Clean up repetition of probe/irrelevant operations!

blocks = presets.setup.blocks;
conditions = presets.setup.conditions;
morphSets = presets.setup.morphSets;

[blockGrid, conditionGrid, morphGrid] = ...
    ndgrid(blocks, conditions, morphSets);

conditionMatrix = [blockGrid(:), conditionGrid(:), morphGrid(:)];

subjects = fieldnames(subjectDataset);
numSubjects = numel(subjects);

for i = 1:length(conditionMatrix)
    block = blockGrid{i};
    condition = conditionGrid{i};
    morphSet = morphGrid{i};

    morphNums = num2str(morphSet);
    morphID = ['morphs_', strrep(morphNums, '  ', '_')];

    probeERPs = cell(1, numSubjects);
    irrelevantERPs = cell(1, numSubjects);
    for iSubject = 1:numSubjects
        subject = subjects{iSubject};
        fprintf(...
            ['\n', ...
            'Retrieving probe and irrelevant ERPs for %s - %s - %s...', ...
            '\n'], ...
            subject, block, morphID)

        probeData = subjectDataset.(subject).(block).probe;
        irrelevantData = subjectDataset.(subject).(block).irrelevant;

        if isfield(probeData, morphID) && isfield(irrelevantData, morphID)
            probeERP = probeData.(morphID).erp;
            irrelevantERP = irrelevantData.(morphID).erp;

            groupDataset.(block).probe.(morphID).subjectERPs.(subject) = probeERP;
            groupDataset.(block).irrelevant.(morphID).subjectERPs.(subject) = irrelevantERP;

            probeERPs{iSubject} = probeERP;
            irrelevantERPs{iSubject} = irrelevantERP;

        else
            fprintf(...
                ['\n', ...
                'No trial or ERP data found for %s - %s - %s - %s.', ...
                '\n', ...
                'Skipping...', ...
                '\n'], ...
                subject, block, condition, morphID ...
                )
            continue
        end
        
    end

    % Remove empty cells left by excluded data
    isMissingProbe = cellfun('isempty', probeERPs);
    probeERPs = probeERPs(~isMissingProbe);
    isMissingIrrelevant = cellfun('isempty', irrelevantERPs);
    irrelevantERPs = irrelevantERPs(~isMissingIrrelevant);

    % Compute grand averages for visualisation
    fprintf(['\n', ...
        'Computing group-level ERP for %s - %s - %s', ...
        '\n\n'], ...
        block, condition, morphID)

    cfg = presets.erp.group.computation;
    groupProbeERP = ft_timelockgrandaverage(cfg, probeERPs{:});
    groupIrrelERP = ft_timelockgrandaverage(cfg, irrelevantERPs{:});

    groupDataset.(block).probe.(morphID).groupERP = groupProbeERP;
    groupDataset.(block).irrelevant.(morphID).groupERP = groupIrrelERP;

end

% Write dataset to file if specified
if isfield(presets.paths.output.erp.group, 'data')
    save( ...
        [presets.paths.output.erp.group.data, ...
        'groupDataset'], ...
        'groupDataset', ...
        '-nocompression', ...
        '-v7.3' ...
        ) 
end

end
