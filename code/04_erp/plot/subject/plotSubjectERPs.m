function plotSubjectERPs(presets, subjectDataset, varargin)

% TO DO:
    % Add error handling
    % Add file output option

% Allow caller to optionally specify data to plot
if nargin > 2
    plotParameters = varargin{1};
else
    plotParameters = presets.plots.erp.subject;
end

subjects = plotParameters.subjects;

blocks = plotParameters.blocks;

conditions = presets.setup.conditions;
numConditions = numel(conditions);

channel = plotParameters.channel;
visibility = plotParameters.visibility;

morphSets = presets.setup.morphSets;
numMorphSets = numel(morphSets);

baselineWindow = presets.preprocessing.baselinewindow;

[subjectGrid, blockGrid] = ndgrid(subjects, blocks);
comboMatrix = [subjectGrid(:), blockGrid(:)];

for iCombo = 1:length(comboMatrix)
    subject = subjectGrid{iCombo};
    subjectField = sprintf('sub%02d', subject);

    block = blockGrid{iCombo};
    
    figurePosition = [0, -90];
    figureWidth = 1600;
    figureHeight = 1400;
    erpPlot = figure('Visible', visibility);
    set(erpPlot, 'Position', [figurePosition, figureWidth, figureHeight]);

    for iCondition = 1:numConditions
        condition = conditions{iCondition};
        subplot(numConditions, 1, iCondition)

        for iMorphSet = 1:numMorphSets
            morphSet = morphSets{iMorphSet};
            morphSetField = ['morphs', num2str(morphSet, '_%d')];
            morphSetLabel = ['Morphs ', strrep(num2str(morphSet), '  ', ' & ')];
    
            fprintf('\n Plotting subject ERP: %s - %s - %s - %s \n\n', subjectField, block, condition, morphSetLabel)

            conditionData = subjectDataset.(subjectField).(block).(condition);

            if ~isfield(conditionData, morphSetField)
                fprintf('\n No ERP found for %s - %s - %s - %s. \n Skipping plot... \n\n ', subjectField, block, condition, morphSetLabel)
                continue
            else
                erpData = conditionData.(morphSetField).erp;
    
                channelNumber = find(ismember(erpData.label, channel));
        
                titleText = sprintf([ ...
                    'Subject-level ERPs \n' ...
                    'subject %d - %s block - %s condition \n' ...
                    '(%s)'], ...
                    subject, ...
                    block, ...
                    condition, ...
                    channel);
        
                plot( ...
                    erpData.time, ...
                    erpData.avg(channelNumber, :), ...
                    'LineWidth', 1.5, ...
                    'DisplayName', morphSetLabel ...
                    );
        
                title(titleText, 'FontSize', 13)
                xlim([-0.5, 1.5]);
                xlabel('Time (seconds)', 'FontSize', 12);
                xticks(-0.5:0.1:1.5);
                ylim([-20, 20]);
                ylabel('Amplitude (\muV)', 'FontSize', 12);
                yticks(-20:5:20);
                xline(0, '--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
                yline(0, '--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
                xline(...
                    baselineWindow(1), ...
                    '--', ...
                    'LineWidth', 1.5, ...
                    'Color', [0.5, 0.5, 0.5], ...
                    'HandleVisibility', 'off' ...
                    );
                grid on
                box off
                legend
                hold on
            end
        end
    end
    hold off
    if isfield(presets.paths.output.erp.subject, 'plots')
    plotSaveFolder = presets.paths.output.erp.subject.plots;
    plotSaveFilename = ...
        sprintf('%s_%s_subjectERPs.png', subjectField, block);
    saveas(erpPlot, [plotSaveFolder, plotSaveFilename])
    end
end

