%% Convert subject data to BIDS
function bidsFormatFiles(presets)

% Specify cfg.events = trl to format using correct events.tsv file 
% (automatic assignment with this function produces the incorrect 
% infomation).

rawDataPath = presets.paths.rawData;

% Handle input path format
if ~strcmp(rawDataPath(end), '/')
    rawDataPath = [rawDataPath, '/'];
end

% Identify Biosemi Data Files (BDFs)
directory = dir(rawDataPath);
directoryFilenames = {directory.name};
isBDF = contains(directoryFilenames, '.bdf');
dataFiles = directoryFilenames(isBDF);

% Define valid BDF filename format
validFormatRegex = '^sub-(?<sub>0[1-9]|1[0-4])_task-rsvp_eeg.bdf$';

% BIDS format all BDFs
numDataFiles = numel(dataFiles);
for iFile = 1:numDataFiles
    filename = dataFiles{iFile};
    pathToFile = [rawDataPath, filename];
    fileInfo = regexp(filename, validFormatRegex, 'names');

    if ~isempty(fileInfo) % If filename format is valid
        cfg = [];
        cfg.dataset = pathToFile;
        cfg.bidsroot = rawDataPath;
        cfg.method = 'copy';
        cfg.sub = fileInfo.sub; % Get subject ID from filename
        cfg.task = 'rsvp';
        cfg.suffix = 'eeg';

        % Update root files once at end
        if iFile == numDataFiles
            cfg.dataset_description.writesidecar = 'yes';
            cfg.dataset_description.Name = 'fringeP3';
            cfg.dataset_description.Authors = {
                'Oscar Anderson';
                'Emre Orun';
                'Howard Bowman';
                'Alberto Aviles';
                'Cihan Dogan'
                };
        end

        data2bids(cfg);

    else
        % Handle unformatted BDF names
        error('Filename "%s" is formatted incorrectly.', filename)
    end
end
