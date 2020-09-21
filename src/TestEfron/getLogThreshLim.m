function logThresh = getLogThreshLim(logZone,varargin)

    if nargin>1
        THRESH_LIM = varargin{1};
    else
        THRESH_LIM = 2.e-7; % ergs / cm^2 
        %THRESH_LIM = 5.e-6; % ergs / cm^2 
    end

    MPC2CM = 3.086e24;   % 1 Mega Parsec = MPC2CM centimeters.
    LOGMPC2CMSQ4PI = log(4.0*pi) + 2.0*log(MPC2CM);     % log(MegaParsec2centimeters).
    LOG_THRESH_LIM = log(THRESH_LIM);% + 3;
    zone = exp(logZone);
    logThresh = LOGMPC2CMSQ4PI ...
              + 2*getLogLumDisWicMPC(zone) ...
              + LOG_THRESH_LIM ...
              ... - 1.197344248356904e+02 ... 52*log(10)
              - logZone ... % comment out this line for detector threshold based on Liso/flux
              + log(getZoneCorrection(zone)) ...
              ;
    %disp(log(getZoneCorrection(zone)))
end
