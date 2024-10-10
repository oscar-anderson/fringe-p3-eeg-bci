function significance = checkSignificance(results)

if ~isfield(results, 'posclusters')
    fprintf('No positive clusters found.')
    significance = 0;
else
    pValues = [results.posclusters(:).prob];
    isSignificant = find(pValues < 0.05);
    numSignificant = numel(isSignificant);

    if numSignificant == 0
        fprintf('No significant positive clusters found.')
        significance = 0;
        
    elseif numSignificant > 0
        fprintf('%d significant positive clusters found.', numSignificant)
        significance = 1;
    end
end
