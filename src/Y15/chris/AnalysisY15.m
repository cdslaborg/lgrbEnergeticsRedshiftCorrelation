classdef AnalysisY15 < BaseAnalysis

    properties(Access=public)
        path
        file
        data
        logdata
        epstat
    end

    methods(Access=public)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function self = AnalysisY15(fluenceThreshEnabled,observerLogThresh,varargin)

            % call the superclass constructor

            self = self@BaseAnalysis(fluenceThreshEnabled,observerLogThresh);

            % set up the IO paths for this analysis

            self.path = struct();
            self.path.root = GetFullPath('../..','lean');
            self.path.src = fullfile(self.path.root,'src','Y15');
            self.path.output = fullfile(self.path.root,'out');

            self.path.inputFile = fullfile(self.path.root,'in','Y15table1.xlsx');
            if nargin==3
                self.path.inputFile = varargin{1};
            elseif nargin>3
                error("invalid number input of arguments.");
            end

            % read the input file

            self.data = importdata(self.path.inputFile,1);
            self.logdata = log(self.data.data(:,[2,4]));

        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

<<<<<<< HEAD:src/Y15/AnalysisY15.m
        function tau = getTau(alpha)
=======
        function tau = getTau(logThresh)
>>>>>>> 47a61934264fb783c93699e9cb13d258ad8571b0:src/Y15/OOP/AnalysisY15.m
            
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end

end