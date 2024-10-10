%% Main pipeline script

% Clear workspace
clear
close all
restoredefaultpath
clear RESTOREDEFAULTPATH_EXECUTED

% File I/O
paths.input.sourceData = 'sourcedata/';
paths.input.rawData = 'rawdata/';
paths.input.code = 'code/';
paths.input.derivatives = 'derivatives/';
structfun(@(folderPath) addpath(genpath(folderPath)), paths.input);
paths.input.fieldTrip = 'fieldtrip-20240515/';
addpath(paths.input.fieldTrip);
ft_defaults
paths.output.preprocessed = ...
    'derivatives/01_preprocessing/01_global/preprocessedData/';
paths.output.refiltered = ...
    'derivatives/01_preprocessing/02_refiltering/refilteredData/';
paths.output.postICA = ...
    'derivatives/01_preprocessing/03_ica/postIcaData/';
paths.output.postExclusion = ...
    'derivatives/01_preprocessing/04_exclusion/postExclusionData/';
paths.output.interpolated = ...
    'derivatives/01_preprocessing/05_interpolation/interpolatedData/';
paths.output.rebaselined = ...
    'derivatives/01_preprocessing/06_rebaselining/rebaselinedData/';
paths.output.erp.group.data = 'derivatives/02_erp/group/';
paths.output.erp.group.plots = 'derivatives/02_erp/group/plots/';
paths.output.erp.subject.data = 'derivatives/02_erp/subject/';
paths.output.erp.subject.plots = 'derivatives/02_erp/subject/plots/';
paths.output.results.group.data = 'derivatives/03_results/group/';
paths.output.results.group.plots = 'derivatives/03_results/group/plots/';
paths.output.results.subject.data = 'derivatives/03_results/subject/';
paths.output.results.subject.plots = 'derivatives/03_results/subject/plots/';
paths.output.erp.subject.fufa.data = 'derivatives/02_erp/subject/fufa/';
paths.output.results.subject.roi.data = 'derivatives/03_results/subject/roi/';
paths.output.results.subject.roi.plots = 'derivatives/03_results/subject/roi/plots/';
presets.paths = paths;
clear paths

% Study setup
setup.subjects = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14};
setup.blocks = {'trump', 'markle', 'incidental'};
setup.conditions = {'probe', 'irrelevant'};
setup.morphSets = {[1, 2], [3, 4], [5, 6], [7, 8], [9, 10]};
load('trialMarkers.mat');
setup.trialMarkers = trialMarkers;
clear trialMarkers
presets.setup = setup;
clear setup

% Trial segmentation
segmentation.prestim = 0.5; % Pre-event trial start
segmentation.poststim = 1.5; % Post-event trial end
segmentation.eventtype = 'STATUS'; % Trial event type.
presets.segmentation = segmentation;
clear segmentation;

% Preprocessing
preprocessing.channel = {'all', '-status'}; % Channel(s) to include
preprocessing.demean = 'yes'; % Baseline correction
preprocessing.baselinewindow = [-0.2, 0];
preprocessing.detrend = 'yes'; % Remove linear trend
preprocessing.padding = 2; % Filter padding
preprocessing.bpfilter = 'yes'; % Band-pass filter
preprocessing.bpfreq = [0.3, 30]; % Hz
preprocessing.bpfilttype = 'fir';
preprocessing.bsfilter = 'yes'; % Band-stop filter
preprocessing.bsfreq = [7, 8]; % Hz
preprocessing.bsfilttype = 'fir';
preprocessing.reref = 'yes'; % Re-referencing
preprocessing.refchannel = {'T7', 'T8'}; % Reference channel(s)
preprocessing.refmethod = 'avg';
presets.preprocessing = preprocessing;
clear preprocessing;

% Amplitude thresholding
thresholding.artfctdef.threshold.channel = {'all', '-status'};
thresholding.artfctdef.threshold.bpfilter = 'no';
thresholding.artfctdef.threshold.min = -100;
thresholding.artfctdef.threshold.max = 100;
presets.thresholding = thresholding;
clear thresholding

% Refiltering
refilter.subjects = {'sub08', 'sub09'};
refilter.bpFreq = [0.5, 30];
presets.refilter = refilter;
clear refilter

% Independent Component Analysis
ica.analysis.method = 'fastica';
ica.analysis.channel = {'all', '-status'};
ica.analysis.split = 'no';
ica.analysis.trials = 'all';
ica.analysis.numcomponent = 'all';
ica.analysis.demean = 'yes';
ica.analysis.updatesens = 'yes';
ica.analysis.feedback = 'text';
ica.timeSeries.layout = 'biosemi32.lay';
ica.timeSeries.viewmode = 'component';
ica.topography.layout = 'biosemi32.lay';
ica.topography.zlim = 'maxmin';
ica.topography.marker = 'labels';
ica.topography.comment = 'no';
ica.rejection.demean = 'yes';
ica.rejection.updatesens = 'yes';
presets.ica = ica;
clear ica

% Trial/channel exclusion
exclusion.channel = {'all', '-T7', '-T8'}; % Exclude 
exclusion.trials = 'all';
exclusion.viewmode = 'remove';
exclusion.box = 'yes';
exclusion.ylim = 'maxmin';
presets.exclusion = exclusion;
clear exclusion

% Channel neighbours definition
neighbours.method = 'template';
neighbours.template = 'biosemi32_neighb.mat';
presets.neighbours = neighbours;
clear neighbours

% Interpolation
interpolation.method = 'spline';
interpolation.lambda = 1e-5;
interpolation.order = 4;
interpolation.trials = 'all';
interpolation.senstype = 'eeg';
load('elec_realigned.mat');
interpolation.elec = elec_realigned;
clear elec_realigned;
presets.interpolation = interpolation;
clear interpolation

% Event-Related Potentials
erp.subject.computation.channel = 'all';
erp.subject.computation.trials = 'all';
erp.subject.computation.latency = 'all';
erp.subject.computation.keeptrials = 'no';
erp.subject.computation.nanmean = 'yes';
erp.subject.computation.normalizevar = 'N-1';
erp.subject.computation.covariance = 'no';
erp.subject.computation.covariancewindow = 'all';
erp.subject.computation.removemean = 'yes';

erp.group.computation.method = 'across';
erp.group.computation.parameter = 'avg';
erp.group.computation.channel = 'all';
erp.group.computation.latency = 'all';
erp.group.computation.keepindividual = 'no';
erp.group.computation.nanmean = 'yes';
erp.group.computation.normalizevar = 'N-1';

presets.erp = erp;
clear erp

% Statistical analysis
% Need to amend use of setup.conditions field
analysis.group.setup.blocks = presets.setup.blocks;
analysis.group.setup.conditions = presets.setup.conditions;
analysis.group.setup.morphSets = presets.setup.morphSets;

analysis.group.test.parameter = 'avg';
analysis.group.test.method = 'montecarlo';
analysis.group.test.statistic = 'depsamplesT';
analysis.group.test.correctm = 'cluster';
analysis.group.test.clusterstatistic = 'maxsum';
analysis.group.test.clusteralpha = 0.025;
analysis.group.test.minnbchan = 0;
analysis.group.test.tail = 1;
analysis.group.test.clustertail = 1;
analysis.group.test.alpha = 0.05;
analysis.group.test.numrandomization = 1000;
analysis.group.test.ivar = 1;
analysis.group.test.uvar = 2;
analysis.group.test.channel = {'all', '-T7', '-T8'};
analysis.group.test.latency = [0.25, 1];

analysis.subject.setup.subjects = presets.setup.subjects;
analysis.subject.setup.blocks = presets.setup.blocks;
analysis.subject.setup.conditions = presets.setup.conditions;
analysis.subject.setup.morphSets = presets.setup.morphSets;

analysis.subject.test.parameter = 'trial';
analysis.subject.test.method = 'montecarlo';
analysis.subject.test.statistic = 'indepsamplesT';
analysis.subject.test.correctm = 'cluster';
analysis.subject.test.clusterstatistic = 'maxsum';
analysis.subject.test.clusteralpha = 0.025;
analysis.subject.test.minnbchan = 0;
analysis.subject.test.tail = 1;
analysis.subject.test.clustertail = 1;
analysis.subject.test.alpha = 0.05;
analysis.subject.test.numrandomization = 1000;
analysis.subject.test.ivar = 1;
analysis.subject.test.channel = {'all', '-T7', '-T8'};
analysis.subject.test.latency = [0.25, 1];

presets.analysis = analysis;
clear analysis

% Region-of-Interest analysis
roi.searchParameters.volume.time = [0.25, 1];
roi.searchParameters.volume.space = 'all';
roi.searchParameters.window.time = 0.1;
roi.searchParameters.window.space = 1;
presets.roi = roi;
clear roi

% Visualisation
plots.erp.subject.subjects = presets.setup.subjects;
plots.erp.subject.blocks = presets.setup.blocks;
plots.erp.subject.conditions = presets.setup.conditions;
plots.erp.subject.morphSets = presets.setup.morphSets;
plots.erp.subject.channel = 'Pz';
plots.erp.subject.visibility = 'off';

plots.erp.group.blocks = presets.setup.blocks;
plots.erp.group.conditions = presets.setup.conditions;
plots.erp.group.morphSets = presets.setup.morphSets;
plots.erp.group.channel = 'Pz';
plots.erp.group.visibility = 'off';

plots.clusters.alpha = 0.05;
plots.clusters.highlightseries = {'labels', 'labels', 'off', 'off', 'off'};
plots.clusters.subplotsize = [3, 3];
plots.clusters.layout = 'biosemi32.lay';
plots.clusters.visible = 'on';
plots.clusters.toi = ...
    linspace(0.2, 1, plots.clusters.subplotsize(1) * plots.clusters.subplotsize(2));
plots.clusters.colorbar = 'EastOutside';
plots.clusters.zlim = 'maxmin';

plots.roi.visibility = 'off';

presets.plots = plots;
clear plots

%% Run full pipeline

% Ensure raw files are BIDS formatted
bidsFormatFiles(presets)

% Load raw dataset
rawDataset = getRawDataset(presets);

% Preprocess dataset
preprocessedDataset = preprocessDataset(presets, rawDataset);

% Refilter select subjects
refilteredDataset = refilterData(presets, preprocessedDataset);

% Remove noise components
postIcaDataset = rejectBadComponents(presets, refilteredDataset);

% Exclude bad data
postExclusionDataset = rejectBadData(presets, postIcaDataset);

% Interpolate data
interpolatedDataset = interpolateDataset(presets, postExclusionDataset);

% Reapply baseline correction
rebaselinedDataset = rebaselineDataset(presets, interpolatedDataset);

% Get individual-level data (individual-level trials)
subjectDataset = getSubjectDataset(presets, rebaselinedDataset);

% Get group-level data (individual-level ERPs)
groupDataset = getGroupDataset(presets, subjectDataset);

% Visualise group-level ERPs
plotGroupERPs(presets, groupDataset)

% Run group-level analysis
[groupResultsDataset, groupResultsTable] = ...
    runGroupAnalyses(presets, groupDataset);

% Visualise individual-level ERPs
plotSubjectERPs(presets, subjectDataset)

% Run individual-level analysis
[subjectResultsDataset, subjectResultsTable] = ...
    runSubjectAnalyses(presets, subjectDataset);

% Compute individual-level FuFAs
fufaDataset = getSubjectDataset(presets, rebaselinedDataset, 'fufa');

% Find individual-level ROIs
roiDataset = getRoiDataset(presets, fufaDataset);

% Visualise individual-level ROIs
% plotROIs(presets, subjectDataset, fufaDataset, roiDataset)

% Run within-ROI individual-level analysis
[subjectRoiResultsDataset, subjectRoiResultsTable] = ...
    runSubjectAnalyses(presets, subjectDataset, roiDataset);

% Visualise within-ROI individual-level results
% plotClusters(presets, subjectRoiResultsDataset)







