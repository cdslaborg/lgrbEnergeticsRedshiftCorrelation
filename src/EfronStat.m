classdef EfronStat < dynamicprops

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties
        thresh
        ndata
        logx
        logy
        logxMax
        logxMaxValues
        %logyMin
        logxDistanceFromLogThresh
        logyDistanceFromLogThresh
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods(Access=public)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function self = EfronStat(logx, logy, observerLogThresh, threshType)
            %
            % Given observational data logx and logy and a threshold cutoff value 
            % for logy (as a function of logx) and the threshold type, this class
            % computes the Efron-Petrosian statistic and returns an object containing
            % all of the necessary information about the analysis.
            %
            self.ndata = length(logx);
            if self.ndata~=length(logy)
                error("ndata~=length(y): " + string(logx) + " " + string(logy) );
            end
            if nargin~=4
                error   ( "Incorrect number of input arguments. Usage:" ...
                        + newline ...
                        + "    EfronStat(xdata, ydata, observerLogThresh, threshType)" ...
                        );
            end

            self.logx = logx;
            self.logy = logy;
            self.thresh = Thresh(observerLogThresh, threshType);

            % compute the logxMax values

            self.logxMaxValues = self.getLogxMaxAtThresh();

            % compute Efron stat

            disp("computing the Efron Petrosian Statistics for the log-detection threshold limit of " + string(observerLogThresh) + " ...");

            % LogxMax indicates the box that is formed by finding the maximum x value 
            % at which the horizontal lower line of the Efron box for each observationa
            % reaches the detection threshold.
            self.logxMax = self.getLogxMaxTau();

            % compute the regression alpha and its 1-sigma uncertainty

            self.logxMax.alpha.tau.zero = self.getLogxMaxAlphaGivenTau(0);
            self.logxMax.alpha.tau.posOne = self.getLogxMaxAlphaGivenTau(1);
            self.logxMax.alpha.tau.negOne = self.getLogxMaxAlphaGivenTau(-1);

            % compute distances of data from the detector threshold

            self.getLogxDistanceFromLogThresh();
            self.getLogyDistanceFromLogThresh();

        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function logxMaxAtThresh = getLogxMaxAtThresh(self)
            %
            %   Return the maximum logx at which the logxbox of the observational 
            %   data points meet the detection threshold for all data points.
            %   This function calls the getLogValInt() method of the Thresh() class.
            %   
            %   NOTE
            %
            %   This function needs to be called only once since the boxes and their members
            %   do not change for different values of alpha decorrelation.
            %   However, they do change for different values of redshift.
            %
            logxMaxAtThresh = zeros(self.ndata,1);
            for i = 1:self.ndata
                getLogThreshInt = @(logxDum) abs(self.thresh.getLogValInt(logxDum) - self.logy(i));
                options = optimset("MaxIter", 10000, "MaxFunEvals", 10000);
                [x, funcVal, exitflag, output] = fminsearch(getLogThreshInt, self.logx(i), options);
                if exitflag==1
                    logxMaxAtThresh(i) = x;
                else
                    disp( "failed at iteration " + string(i) + " with logx(i) = " + string(self.logx(i)) + ...
                        + ", logy(i) = " + string(self.logy(i)) + " with fval = " + string(fval) ...
                        );
                    disp("i = " + string(i));
                    disp("self.logx(i) = " + string(self.logx(i)));
                    disp("self.logy(i) = " + string(self.logy(i)));
                    disp("funcVal = " + string(funcVal));
                    disp("output = " + string(output));
                end
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function logxMax = getLogxMaxTau(self,logyLocal)
            %
            %   Compute and return the Tau statistic via xmax-boxes for the input data.
            %   This function calls getLogxMaxAtThresh() method.
            %
            if nargin<2; logyLocal = self.logy; end

            logxMax = struct();
            logxMax.val = self.logxMaxValues; % self.getLogxMaxAtThresh(); % vector of size (ndata,1) containing maximum x value at the detection threshold
            %logxMax.val = self.getLogxMaxAtThresh();
            logxMax.box = cell(self.ndata,1);

            tauNumerator = 0.;
            tauDenominatorSq = 0.;
            for i = 1:self.ndata
                logxMax.box{i} = struct();
                logxMax.box{i}.mask = self.logx <= logxMax.val(i) & logyLocal >= logyLocal(i);
                logxMax.box{i}.count = sum( logxMax.box{i}.mask );
                logxMax.box{i}.logx = self.logx( logxMax.box{i}.mask ); % vector
                logxMax.box{i}.logy = logyLocal( logxMax.box{i}.mask ); % vector
                logxMax.box{i}.rank.val = sum( logxMax.box{i}.logx < self.logx(i) ); % scalar
                logxMax.box{i}.rank.avg = ( logxMax.box{i}.count + 1 ) * 0.5; % scalar
                logxMax.box{i}.rank.var = ( logxMax.box{i}.count ^ 2 - 1 ) / 12.; % scalar
                tauNumerator = tauNumerator + logxMax.box{i}.rank.val - logxMax.box{i}.rank.avg;
                tauDenominatorSq = tauDenominatorSq + logxMax.box{i}.rank.var;
            end

            logxMax.tau = tauNumerator / sqrt( tauDenominatorSq );

        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function tauGivenAlpha = getLogxMaxTauGivenAlpha(self,alpha)
            %
            %   Return the Tau corresponding to an input alpha value. 
            %   This is done by first decorrelating the observational 
            %   data and then computing the Tau statistic for the new
            %   decorrelated dataset for the given alpha.
            %   This also requires the decorrelation of the detection 
            %   threshold.
            %   This function calls getLogxMaxTau() method.
            %
            logyLocal = self.logy - alpha*self.logx;
            logxMax = self.getLogxMaxTau(logyLocal);
            tauGivenAlpha = logxMax.tau;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function logxMaxAlphaGivenTau = getLogxMaxAlphaGivenTau(self,tau)
            %
            % compute the negative linear regression slope of the logx-logy relationship
            %
            getLogxMaxAlphaGivenTauHandle = @(alpha) abs(self.getLogxMaxTauGivenAlpha(alpha) - tau);
            options = optimset("MaxIter", 10000, "MaxFunEvals", 10000, "TolX", 5.e-3, "TolFun", 1.e-2);
            % WARNING: DO NOT SET THE STARTING POINT OF THE SEARCH TO ZERO. 2 IS GOOD STARTING POINT FOR THE SEARCH.
            [logxMaxAlphaGivenTau, funcVal, exitflag, output] = fminsearch(getLogxMaxAlphaGivenTauHandle, 2, options);
            if exitflag~=1
                disp("failed to converge " + " with fval = " + string(fval));
                disp("i = " + string(i));
                disp("self.logx(i) = " + string(self.logx(i)));
                disp("self.logy(i) = " + string(self.logy(i)));
                disp("funcVal = " + string(funcVal));
                disp("output = " + string(output));
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function logyMinAtThresh = getLogyMinAtThresh(self)
            logyMinAtThresh = self.thresh.getLogValInt(self.logx);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function getLogyDistanceFromLogThresh(self)
            self.logyDistanceFromLogThresh = self.logy - self.getLogyMinAtThresh();
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function getLogxDistanceFromLogThresh(self)
            self.logxDistanceFromLogThresh = self.getLogxMaxAtThresh() - self.logx;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods(Hidden)
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end