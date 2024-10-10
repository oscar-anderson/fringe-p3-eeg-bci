function roiDataset = getRoiDataset(presets, fufaDataset)

% searchParameters = struct with fields:
    % window
        % time (timespan in secs)
        % space (number of channels)
    % volume
        % time ([start, end] in secs)
        % space (channels to search through)

subjects = fieldnames(fufaDataset);
blocks = presets.setup.blocks;
morphSets = presets.setup.morphSets;

[subjectGrid, blockGrid, morphSetGrid] = ...
    ndgrid(subjects, blocks, morphSets);

conditionMatrix = ...
    [subjectGrid(:), blockGrid(:), morphSetGrid(:)];

searchParameters = presets.roi.searchParameters;

for i = 1:length(conditionMatrix)
    subject = subjectGrid{i};

    block = blockGrid{i};

    morphSet = morphSetGrid{i};
    morphNums = num2str(morphSet);
    morphSetID = ['morphs_', strrep(morphNums, '  ', '_')];

    fprintf('\n Finding ROI for %s - %s - %s... \n', subject, block, morphSetID)

    if ~isfield(fufaDataset.(subject).(block).probe_irrelevant, morphSetID)
        fprintf(...
            '\n No FuFA data for %s - %s - %s. Skipping ROI... \n', ...
            subject, block, morphSetID ...
            )
        continue    
    else
        fufa = ...
            fufaDataset.(subject).(block).probe_irrelevant.(morphSetID);
    end

    roi = findROI(fufa, searchParameters);

    roiDataset.(subject).(block).probe_irrelevant.(morphSetID) = roi;

end

if isfield(presets.paths.output.results.subject.roi, 'data')
    save(...
        [presets.paths.output.results.subject.roi.data, ...
        'roiDataset'], ...
        'roiDataset', ...
        '-nocompression', ...
        '-v7.3' ...
        ) 
end

end
