function averageValues = averageAlphaAndTau(threshLogVal...
                                            ,threshAt99PercentLogVal...
                                            ,threshType ...
                                            ,numberOfSimulations)


    averageValues = struct();

    averageValues.avgAlpha = 0;
    averageValues.avgAlphaPlusOne = 0;
    averageValues.avgAlphaNegOne = 0;

    averageValues.avgTau = 0;

    averageValues.avgAlpha99 = 0;
    averageValues.avgAlpha99PlusOne = 0;
    averageValues.avgAlpha99NegOne = 0;

    averageValues.avgTau99 = 0;


    numberOfGeneratedSamples = numberOfSimulations;

    b10 = importdata("..\..\..\..\20181213_BatseLgrbRedshift\git\___SyntheticSample___\winx64\intel\release\static\serial\bin\out\kfacOneThird\syntheticSampleB10.csv");
    
    if strcmpi(threshType,"flux")
        icol.logyint = 1; % logliso
        icol.logyobs = 5; % logpbol
    elseif strcmpi(threshType,"fluence")
        icol.logyint = 3; % logeiso
        icol.logyobs = 7; % logsbol
    end

    icol.z = 9; % redshift
    skip = 100;
    icol.detProb = 10; % column index of detection probability
    
    
    for i = 1:numberOfGeneratedSamples

        Mask = b10.data(1:1:end,icol.detProb) > unifrnd(0,1,length(b10.data(1:1:end,icol.detProb)),1);


        syntheticSample.zone = b10.data(Mask,icol.z) + 1; syntheticSample.zone = syntheticSample.zone(1:skip:end);
        syntheticSample.logZone = log(syntheticSample.zone);

        syntheticSample.logyint = b10.data(Mask,icol.logyint); syntheticSample.logyint = syntheticSample.logyint(1:skip:end);

        %syntheticSample = genSynSam(threshType);

        syntheticSample.estat = EfronStat( syntheticSample.logZone ... logx
                                    , syntheticSample.logyint ... logy
                                    , threshLogVal ... observerLogThresh
                                    , threshType ... threshType
                                    );
        syntheticSample.estat99 = EfronStat( syntheticSample.logZone ... logx
                                    , syntheticSample.logyint ... logy
                                    , threshAt99PercentLogVal ... observerLogThresh
                                    , threshType ... threshType
                                    );

        averageValues.avgTau = averageValues.avgTau + syntheticSample.estat.logxMax.tau;


        averageValues.avgAlpha = averageValues.avgAlpha + syntheticSample.estat.logxMax.alpha.tau.zero;
        averageValues.avgAlphaPlusOne = averageValues.avgAlphaPlusOne + syntheticSample.estat.logxMax.alpha.tau.posOne * syntheticSample.estat.logxMax.alpha.tau.posOne;
        averageValues.avgAlphaNegOne = averageValues.avgAlphaNegOne + syntheticSample.estat.logxMax.alpha.tau.negOne * syntheticSample.estat.logxMax.alpha.tau.negOne;

        averageValues.avgTau99 = averageValues.avgTau99 + syntheticSample.estat99.logxMax.tau;

        averageValues.avgAlpha99 = averageValues.avgAlpha99 + syntheticSample.estat99.logxMax.alpha.tau.zero;
        averageValues.avgAlpha99PlusOne = averageValues.avgAlpha99PlusOne + syntheticSample.estat99.logxMax.alpha.tau.posOne * syntheticSample.estat99.logxMax.alpha.tau.posOne;
        averageValues.avgAlpha99NegOne = averageValues.avgAlpha99NegOne + syntheticSample.estat99.logxMax.alpha.tau.negOne * syntheticSample.estat99.logxMax.alpha.tau.negOne;
    end

    averageValues.avgAlpha = averageValues.avgAlpha/numberOfGeneratedSamples;
    averageValues.avgAlphaPlusOne = sqrt(averageValues.avgAlphaPlusOne/numberOfGeneratedSamples);
    averageValues.avgAlphaNegOne = sqrt(averageValues.avgAlphaNegOne/numberOfGeneratedSamples);

    averageValues.avgTau = averageValues.avgTau/numberOfGeneratedSamples;

    averageValues.avgAlpha99 = averageValues.avgAlpha99/numberOfGeneratedSamples;
    averageValues.avgAlpha99PlusOne = sqrt(averageValues.avgAlpha99PlusOne/numberOfGeneratedSamples);
    averageValues.avgAlpha99NegOne = sqrt(averageValues.avgAlpha99NegOne/numberOfGeneratedSamples);

    averageValues.avgTau99 = averageValues.avgTau99/numberOfGeneratedSamples;
end