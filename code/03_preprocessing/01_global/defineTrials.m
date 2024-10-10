function trl = defineTrials(presets, rawData)

blocks = presets.setup.blocks;
conditions = presets.setup.conditions;
morphSets = cell2mat(presets.setup.morphSets);
trialMarkers = presets.setup.trialMarkers;

relevantTrials = ...
    (ismember(trialMarkers.block, blocks)) & ...
    (ismember(trialMarkers.condition, conditions)) & ...
    (ismember(trialMarkers.morph, morphSets));

relevantMarkers = trialMarkers.marker(relevantTrials);

cfg.trialdef = presets.segmentation;
cfg.trialdef.eventvalue = relevantMarkers;
cfg.dataset = rawData;

cfg = ft_definetrial(cfg);

trl = cfg.trl;

end
