function output = getZoneEisoDependency(logZone,logLiso,logZoneMax)

    global alpha

    alphaRange = -4:0.25:4;
    alphaRangeLen = length(alphaRange);
    output = cell(alphaRangeLen,1);
    for i = 1:alphaRangeLen

        disp( string(i) + ": generating Efron statistics for alpha = " + string(alpha) );

        alpha = alphaRange(i);

        output{i} = struct();
        output{i}.alpha = alpha;
        ... output{i}.logEisoCorrected = logEiso + alpha * logZone;
        output{i}.logLisoCorrected = logLiso + alpha * logZone;

        output{i}.epstat = getEfronStat ( logZone ... xvec
        ...                                , output{i}.logEisoCorrected ... yvec
                                        , output{i}.logLisoCorrected ... yvec
                                        , logZoneMax ... getLim
                                        );

    end
    
end