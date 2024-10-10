function results = runSubjectAnalysis(presets, probeTrials, irrelevantTrials, varargin)

% Add varargin for ROI option

% Initialise channel neighbours
cfg = presets.neighbours;
neighbours = ft_prepare_neighbours(cfg);

% Initialise design matrix
numProbeTrials = numel(probeTrials.trial);
numIrrelevantTrials = numel(irrelevantTrials.trial);
design = [...
    ones(1, numProbeTrials), ...
    2*ones(1, numIrrelevantTrials); ...
    1:numProbeTrials, ...
    1:numIrrelevantTrials ...
    ];

% Run cluster-based independent-samples permutation test
cfg = presets.analysis.subject.test;
cfg.neighbours = neighbours;
cfg.design = design;

% Use ROI if given
if nargin > 3
    roi = varargin{1};
    cfg.latency = [roi.time.start, roi.time.end];
    cfg.channel = roi.channels;
end

results = ft_timelockstatistics(cfg, probeTrials, irrelevantTrials);

% Update cfg.channel and cfg.latency if ROI specified

end