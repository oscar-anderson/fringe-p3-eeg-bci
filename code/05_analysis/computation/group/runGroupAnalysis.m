function results = runGroupAnalysis(presets, probeERPs, irrelevantERPs)

% Convert data for input to test
probeERPs = struct2cell(probeERPs);
irrelevantERPs = struct2cell(irrelevantERPs);

% Initialise channel neighbours
cfg = presets.neighbours;
neighbours = ft_prepare_neighbours(cfg);

% Initialise design matrix
numProbeERPs = numel(probeERPs);
numIrrelevantERPs = numel(irrelevantERPs);
design = [...
    ones(1, numProbeERPs), ...
    2*ones(1, numIrrelevantERPs); ...
    1:numProbeERPs, ...
    1:numIrrelevantERPs
    ];

% Run cluster-based paired-samples permutation test
cfg = presets.analysis.group.test;
cfg.neighbours = neighbours;
cfg.design = design;
results = ft_timelockstatistics(cfg, probeERPs{:}, irrelevantERPs{:});

end