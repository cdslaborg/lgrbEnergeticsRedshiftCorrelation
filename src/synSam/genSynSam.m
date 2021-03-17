function synSam = genSynSam(threshType)

    b10 = importdata("..\..\in\syntheticSampleB10.csv");

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

    % By default, thresh.val is the threshold at 50% detection probability
    synSam.thresh.logVal = mean( b10.data( b10.data(:,icol.detProb)>0.48 & b10.data(:,icol.detProb)<0.52 , icol.logyobs) );
    synSam.thresh.logVal99 = mean( b10.data( b10.data(:,icol.detProb)>0.0 & b10.data(:,icol.detProb)<0.02 , icol.logyobs) );
    synSam.thresh.val = exp( synSam.thresh.logVal );
    synSam.thresh.val99 = exp(synSam.thresh.logVal99);

    Mask = b10.data(1:1:end,icol.detProb) > unifrnd(0,1,length(b10.data(1:1:end,icol.detProb)),1);

    synSam.detProb = b10.data(Mask,icol.detProb); synSam.detProb = synSam.detProb(1:skip:end);

    synSam.z = b10.data(Mask,icol.z); synSam.z = synSam.z(1:skip:end);
    synSam.logz = log(synSam.z);
    synSam.zone = synSam.z + 1;
    synSam.logZone = log(synSam.zone);

    synSam.logyint = b10.data(Mask,icol.logyint); synSam.logyint = synSam.logyint(1:skip:end);
    synSam.logyobs = b10.data(Mask,icol.logyobs); synSam.logyobs = synSam.logyobs(1:skip:end);

    synSam.yint = exp( synSam.logyint );
    synSam.yobs = exp( synSam.logyobs );

    synSam.ndata = length(synSam.z);

end