function roi = findROI(fufa, searchParameters)

window = searchParameters.window;
% Handle invalid fields/field values

volume = searchParameters.volume;
% Handle invalid fields/field values

fufaTrials = fufa.trials;
fufaERP = fufa.erp;

samplingRate = fufaTrials.fsample;
window.samples = round(window.time * samplingRate);

volume.samples = ...
    find(fufaERP.time >= volume.time(1) & fufaERP.time <= volume.time(2));
numVolSamples = numel(volume.samples);
numWindowPositions = numVolSamples - window.samples + 1;

fufaChannels = fufaERP.label;
if strcmp(volume.space, 'all')
    volume.space = fufaChannels;
end
volChannelsIdx = find(ismember(fufaChannels, volume.space));
volChannels = fufaChannels(volChannelsIdx);
numVolChannels = numel(volChannels);

roi = struct('meanAmplitude', []);

for iWindow = 1:numWindowPositions
    startSample = volume.samples(iWindow);
    endSample = (startSample + window.samples) - 1;
    startTime = fufaERP.time(startSample);
    endTime = fufaERP.time(endSample);

    for iChannel = 1:numVolChannels
        startChannelIdx = volChannelsIdx(iChannel);
        endChannelIdx = (startChannelIdx + window.space) - 1;

        newWindow = ...
            fufaERP.avg(startChannelIdx:endChannelIdx, startSample:endSample);

        meanAmplitude = mean(newWindow(:));

        if iWindow == 1 && iChannel == 1 || meanAmplitude > roi.meanAmplitude
            roi.meanAmplitude = meanAmplitude;
            roi.time.start = startTime;
            roi.time.end = endTime;
            roi.samples.start = startSample;
            roi.samples.end = endSample;
            roi.channels = {volChannels{startChannelIdx:endChannelIdx}};
        end
    end
end
