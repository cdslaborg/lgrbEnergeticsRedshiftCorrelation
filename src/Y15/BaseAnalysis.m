classdef BaseAnalysis

    properties
        fluenceThreshEnabled = false;
        observerLogThresh
    end

    methods(Access=public)

        function self = BaseAnalysis(fluenceThreshEnabled,observerLogThresh)
            self.fluenceThreshEnabled = fluenceThreshEnabled;
            self.observerLogThresh = observerLogThresh;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function logThresh = getLogThresh(self,logZone)
            logThresh = 0.;
            if self.fluenceThreshEnabled
                logThresh = logThresh - logZone;
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end

end