function plotGroupERPs(presets, groupDataset, varargin)

% TO DO:
    % Error handling
    % Combine with plotSubjectERPs()?

% Allow caller to optionally specify data to plot
if nargin > 2
    plotParameters = varargin{1};
else
    plotParameters = presets.plots.erp.group;
end

blocks = plotParameters.blocks;
numBlocks = numel(blocks);

conditions = plotParameters.conditions;
numConditions = numel(conditions);

morphSets = plotParameters.morphSets;
numMorphSets = numel(morphSets);

channel = plotParameters.channel;

visibility = plotParameters.visibility;

baselineWindow = presets.preprocessing.baselinewindow;

for iBlock = 1:numBlocks
    block = blocks{iBlock};

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

            erpData = ...
                groupDataset.(block).(condition).(morphSetField).groupERP;

            channelNumber = find(ismember(erpData.label, channel));

            titleText = sprintf( ...
                'Group-level ERPs \n %s block - %s condition \n (%s)', ...
                block, condition, channel ...
                );

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
            ylim([-5, 7]);
            ylabel('Amplitude (\muV)', 'FontSize', 12);
            yticks(-20:1:20);
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
    hold off
    if isfield(presets.paths.output.erp.group, 'plots')
        plotSaveFolder = presets.paths.output.erp.group.plots;
        plotSaveFilename = sprintf('%s_groupERPs.png', block);
        saveas(erpPlot, [plotSaveFolder, plotSaveFilename])
    end
end
end
