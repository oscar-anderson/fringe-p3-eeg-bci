function stats = getClusterStats(results, probeVars, irrelevantVars)

if ~isfield(results, 'posclusters')
    fprintf('\n No positive clusters found. \n')

    stats.cluster1 = struct(...
        'cluster', NaN, ...
        'pValue', NaN, ...
        'startTime', NaN, ...
        'endTime', NaN, ...
        'channels', NaN, ...
        'sumSampleT', NaN, ...
        'maxSampleT', NaN, ...
        'nProbe', NaN, ...
        'nIrrelevant', NaN, ...
        'df', NaN, ...
        'cohensD', NaN ...
        );

else
    pValues = [results.posclusters(:).prob];
    isSignificantCluster = find(pValues < 0.05);
    numSignificantClusters = numel(isSignificantCluster);
    fprintf( ...
        '\n %d significant positive clusters found \n', ...
        numSignificantClusters ...
        )
    if numSignificantClusters == 0
        % Report stats for cluster closest to significance
        numClustersToReport = 1;

    elseif numSignificantClusters > 0
        % Report stats for all significant clusters
        numClustersToReport = numSignificantClusters;

    end

    for iCluster = 1:numClustersToReport
        cluster = sprintf('cluster%d', iCluster);
        pValue = results.posclusters(iCluster).prob;
    
        [clusterChannelNumbers, clusterSamples] = ...
            find(results.posclusterslabelmat == iCluster);
        
        startSample = min(clusterSamples);
        endSample = max(clusterSamples);
        startTime = results.time(startSample);
        endTime = results.time(endSample);
        
        channels = ...
            strjoin(unique(results.label(clusterChannelNumbers), 'stable'), ', ');
        
        isClusterSampleStat = ...
            find(results.posclusterslabelmat(:) == iCluster);
        clusterSampleStat = results.stat(isClusterSampleStat);
        sumSampleT = sum(clusterSampleStat);
        maxSampleT = max(clusterSampleStat);
        
        nProbe = numel(fieldnames(probeVars));
        nIrrelevant = numel(fieldnames(irrelevantVars));
        df = nProbe + nIrrelevant - 2;
        cohensD = maxSampleT / sqrt(df);
    
        stats.(cluster) = struct(...
            'cluster', iCluster, ...
            'pValue', pValue, ...
            'startTime', startTime, ...
            'endTime', endTime, ...
            'channels', channels, ...
            'sumSampleT', sumSampleT, ...
            'maxSampleT', maxSampleT, ...
            'nProbe', nProbe, ...
            'nIrrelevant', nIrrelevant, ...
            'df', df, ...
            'cohensD', cohensD ...
            );
    end

end
