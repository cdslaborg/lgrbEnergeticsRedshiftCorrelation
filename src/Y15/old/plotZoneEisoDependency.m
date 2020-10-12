global alpha; alpha = 0.0;
threshMask = liso > exp( getLogThreshLim( log(zone),threshLim ) );

refinedZone = zone(threshMask); % select only those events above the threshold line
refinedLiso = liso(threshMask);

logRefinedZone = log(zone);
logRefinedLiso = log(liso);

logRefinedZoneMax = getMaxRedshift ( logRefinedZone ... xvec
                            , logRefinedLiso ... yvec
                            , threshLim ...
                            , @getLogThreshLim ... getThreshLim
                            );

stat = getZoneEisoDependency(logRefinedZone, logRefinedLiso, logRefinedZoneMax);
statCount = length(stat);
alphaValues = zeros(statCount,1);
tauValues = zeros(statCount,1);
for i = 1:statCount
    alphaValues(i) = -stat{i}.alpha;
    tauValues(i) = -stat{i}.epstat.tau;
end


% the inferred alpha / tau

minTau = struct();
[minTau.value, minTau.index] = min(abs(tauValues)); minTau.value = tauValues(minTau.index);
minTau.alpha = alphaValues(minTau.index);
minAlpha.value = alphaValues(alphaValues==0);
minAlpha.tau = tauValues(alphaValues==0);

fontSize = 13; 

figure; hold on; box on;
    plot( alphaValues ...
        , tauValues ...
        , '.-' ...
        , 'linewidth', 2 ...
        , 'color', 'black' ...
        , 'markersize', 20 ...
        );

     scatter( minAlpha.value ...
            , minAlpha.tau ...
            , 1000 ...
            , 'red' ...
            , '.' ...
            );
     scatter( minTau.alpha ...
            , minTau.value ...
            , 1000 ...
            , 'blue' ...
            , '.' ...
            );
    
    xlabel("\alpha in L_{iso} / (z + 1)^\alpha", "interpreter", "tex", "fontsize", fontSize);
    ylabel("Efron - Petrosian Statistic", "interpreter", "tex", "fontsize", fontSize);
    export_fig("../../../out/Y15/Y15taualpha.png", "-m2 -transparent")
    
hold off;


