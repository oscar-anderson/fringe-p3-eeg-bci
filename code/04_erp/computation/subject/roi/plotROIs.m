function plotROIs(presets, subjectDataset, fufaDataset, roiDataset)

visibility = presets.plots.roi.visibility;

subjects = fieldnames(roiDataset);
blocks = presets.setup.blocks;

conditions = presets.setup.conditions;
numConditions = numel(conditions);

morphSets = presets.setup.morphSets;
numMorphSets = numel(morphSets);

[subjectGrid, blockGrid] = ndgrid(subjects, blocks);

comboMatrix = [subjectGrid(:), blockGrid(:)];

for iCombo = 1:length(comboMatrix)
    subject = subjectGrid{iCombo};
    block = blockGrid{iCombo};

    subjectData = subjectDataset.(subject).(block);

    for iMorphSet = 1:numMorphSets
        morphSet = morphSets{iMorphSet};
        morphSetID = ['morphs_', strrep(num2str(morphSet), '  ', '_')];
        morphSetString = ['morphs ', strrep(num2str(morphSet), '  ', ' & ')];

        fufaData = fufaDataset.(subject).(block).probe_irrelevant;

        if isfield(fufaData, morphSetID)

            fufaData = fufaData.(morphSetID);
            roi = roiDataset.(subject).(block).probe_irrelevant.(morphSetID);

            channels = roi.channels;

            % Prepare ERP-ROI figure
            figurePosition = [0, -90];
            figureWidth = 1600;
            figureHeight = 1400;
            erpRoiPlot = figure('Visible', visibility);
            set(...
                erpRoiPlot, ...
                'Position', [figurePosition, figureWidth, figureHeight] ...
                );
            mainTitleText = sprintf('ERPs, FuFA & ROI \n %s - %s - %s \n\n ', subject, block, morphSetString);
            sgtitle(mainTitleText, 'FontSize', 17, 'FontWeight', 'bold');

            % Plot FuFA and ROI
            subplot(2, numConditions, [3, 4])
            plotROI(presets, fufaData, roi)

            % Plot probe and irrelevant ERPs
            for iCondition = 1:numConditions
                condition = conditions{iCondition};

                % Check for ERP data
                if isfield(subjectData.(condition), morphSetID)
                    subjectERP = subjectData.(condition).(morphSetID).erp;

                    erpChannelNumbers = find(ismember(subjectERP.label, channels));
                    channelNames = strjoin(channels, ', ');

                    % Plot all ERPs of given condition
                    subplot(2, numConditions, iCondition)
                    plot(...
                        subjectERP.time, ...
                        subjectERP.avg(erpChannelNumbers, :), ...
                        'LineWidth', 1.5, ...
                        'DisplayName', morphSetString)
                    titleText = sprintf(...
                        'Event-related potential (ERP) \n %s \n (%s)', ...
                        condition, channelNames);
                    title(titleText)
                    xlabel('Time (seconds)', 'FontSize', 12);
                    ylabel('Amplitude (\muV)', 'FontSize', 12);
                    xlim([-0.5, 1.5]);
                    ylim([-35, 35]);
                    xticks(-0.5:0.1:1.5);
                    yticks(-35:5:35);
                    xline(0, '--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
                    yline(0, '--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
                    xline(-0.2, '--', 'LineWidth', 1.5, 'Color', [0.7, 0.7, 0.7], 'HandleVisibility', 'off');           
                    box off
                    grid on

                    % Highlight ROI time window
                    xline(roi.time.start, 'LineWidth', 1.5, 'LineStyle', '--', 'Color', 'r');
                    xline(roi.time.end, 'LineWidth', 1.5, 'LineStyle', '--', 'Color', 'r');

                else
                    fprintf('\n No data found for %s - %s - %s - %s. \n Skipping ERP plot for this condition... \n', subject, block, condition, morphSetID)
                    continue
                end
            end
        end
        if isfield(presets.paths.output.results.subject.roi, 'plots')
            plotSaveFolder = presets.paths.output.results.subject.roi.plots;
            plotSaveFilename = ...
                sprintf('%s_%s_%s_subjectROI.png', subject, block, morphSetID);
            saveas(erpRoiPlot, [plotSaveFolder, plotSaveFilename])
        end
    end
end








    
