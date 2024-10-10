%% Extract trial data
function trialData = extractTrials(presets, data, blocks, conditions, morphs)

trialMarkers = presets.setup.trialMarkers;

relevantTrials = ...
    (ismember(trialMarkers.block, blocks)) & ...
    (ismember(trialMarkers.condition, conditions)) & ...
    (ismember(trialMarkers.morph, morphs));

relevantMarkers = trialMarkers.marker(relevantTrials);

trialsIdx = find(ismember(data.trialinfo, relevantMarkers));

cfg = [];
cfg.trials = trialsIdx;
trialData = ft_selectdata(cfg, data);

end