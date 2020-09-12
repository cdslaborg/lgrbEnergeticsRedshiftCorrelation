classdef Thresh

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties(Constant, Hidden)
        MPC2CM = 3.086e24;                                      % 1 Mega Parsec = MPC2CM centimeters.
        LOGMPC2CMSQ4PI = log(4.0*pi) + 2.0*log(Thresh.MPC2CM);  % log(cm^2)
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties(Access=public)
        type
        logValObs
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties(Hidden)
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods(Access=public)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function self = Thresh(observerLogThresh, threshType)
            self.type = struct();
            self.type.val = "flux";
            self.type.isFlux = false;
            self.type.isFluence = false;
            if nargin==2; self.type.val = threshType; end
            if strcmpi(threshType,"fluence")
                self.type.isFluence = true;
            elseif strcmpi(threshType,"flux")
                self.type.isFlux = true;
            else
                error("threshType must be either flux or fluence.");
            end
            self.logValObs = observerLogThresh;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function logValInt = getLogValInt(self,logZone)
            % get the INTrinsic logValue of the detection threshold at the given log(redshift+1)
            zone = exp(logZone);
            logValInt = Thresh.LOGMPC2CMSQ4PI ...           % log(cm^2)
                      + 2*getLogLumDisWicMPC(zone) ...      % log(MPC^2)
                      + self.logValObs ...                  % log(erg s^-1 cm^-2)
                      ;
            if self.type.isFluence
                logValInt = logValInt - logZone;
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end

end