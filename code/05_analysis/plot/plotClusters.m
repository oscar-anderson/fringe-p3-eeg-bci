function plotClusters(presets, results, varargin)

cfg = presets.plots.clusters;

if nargin > 2
    fileSavePath = varargin{1};
    cfg.saveaspng = fileSavePath;
end

figurePosition = [0, -90];
figureWidth = 1500;
figureHeight = 600;
clusterPlot = figure;
set(clusterPlot, 'Position', [figurePosition, figureWidth, figureHeight]);
ft_clusterplot(cfg, results)

end

