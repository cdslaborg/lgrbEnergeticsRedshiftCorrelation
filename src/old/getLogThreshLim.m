function logThresh = getLogThreshLim(logZone,threshLim)

    MPC2CM = 3.086e24;   % 1 Mega Parsec = MPC2CM centimeters.
    LOGMPC2CMSQ4PI = log(4.0*pi) + 2.0*log(MPC2CM);     % log(cm^2)
    LOG_THRESH_LIM = log(threshLim);                    % log(erg s^-1 cm^-2)
    zone = exp(logZone);
    logThresh = LOGMPC2CMSQ4PI ...                      % log(cm^2)
              + 2*getLogLumDisWicMPC(zone) ...          % log(MPC^2)
              + LOG_THRESH_LIM ...                      % log(erg s^-1 cm^-2)
              ... - 1.197344248356904e+02 ... 52*log(10)
              ... - logZone ... % comment out this line for detector threshold based on Liso/flux
              + log(getZoneCorrection(zone)) ...
              ;

end
