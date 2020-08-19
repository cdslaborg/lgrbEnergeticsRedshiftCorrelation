%clc;
clear all;
close all;
%clear classes;
%format compact; format long;
filePath = mfilename('fullpath');
[currentDir,fileName,fileExt] = fileparts(filePath); cd(currentDir);
cd(fileparts(mfilename('fullpath'))); % Change working directory to source code directory.
addpath(genpath("../../../../libmatlab"),"-begin");
addpath(genpath("../"),"-begin");

fontSize = 13;
figureColor = "white";
freshRunEnabled = false; % this must be set to true for first ever simulation. Thereafter, it can be set to false to save time.

if freshRunEnabled

    y15 = struct();
    y15.thresh.val = 2.e-8;
    y15.thresh.logVal = log(y15.thresh.val);

    y15.input.file.path = "../../in/Y15table1.xlsx";
    y15.input.file.contents = importdata(y15.input.file.path);
    y15.input.file.contents.sorted = sortrows(y15.input.file.contents.data,2);
    y15.output.path = "../../out/Y15"; if ~isfolder(y15.output.path); mkdir(y15.output.path); end
    y15.zone = y15.input.file.contents.sorted(:,2) + 1;
    y15.liso = y15.input.file.contents.sorted(:,4);
    y15.logZone = log(y15.zone);
    y15.logLiso = log(y15.liso);

    y15.estat = EfronStat   ( y15.logZone ... logx
                            , y15.logLiso ... logy
                            , y15.thresh.logVal ... observerLogThresh
                            , "flux" ... threshType
                            );

    y15.logPbol = y15.estat.logyDistanceFromLogThresh + y15.thresh.logVal;
    y15.thresh.logMin = log(1.e-9);
    y15.thresh.logMax = log(1.e-5);
    y15.thresh.logRange = y15.thresh.logMin:0.2:y15.thresh.logMax;
    y15.thresh.logRangeLen = length(y15.thresh.logRange);
    y15.estatList = cell(y15.thresh.logRangeLen,1);
    for i = 1:y15.thresh.logRangeLen
        y15.estatList{i} = EfronStat( y15.logZone ... logx
                                    , y15.logLiso ... logy
                                    , y15.thresh.logRange(i) ... observerLogThresh
                                    , "flux" ... threshType
                                    );
    end

    save(y15.output.path + "/y15.mat","y15");

else
    
    y15.output.path = "../../out/Y15";
    load(y15.output.path + "/y15.mat"); % loads y15 object
    
end

% plot tau(alpha = 0) versus threshold
% Chris: add a text to the vertical line in the plot denoting that this is
% Yu's detection threshold, something like "Y15 Detection Threshold". Once done, remove this note.

y15.tauAtAlphaZero = zeros(y15.thresh.logRangeLen,1);
y15.alphaAtTauZero = zeros(y15.thresh.logRangeLen,1);
y15.alphaAtTauPosOne = zeros(y15.thresh.logRangeLen,1);
y15.alphaAtTauNegOne = zeros(y15.thresh.logRangeLen,1);
for i = 1:y15.thresh.logRangeLen
    y15.tauAtAlphaZero(i) = y15.estatList{i}.logxMax.tau;
    y15.alphaAtTauZero(i) = y15.estatList{i}.logxMax.alpha.tau.zero;
    y15.alphaAtTauPosOne(i) = y15.estatList{i}.logxMax.alpha.tau.posOne;
    y15.alphaAtTauNegOne(i) = y15.estatList{i}.logxMax.alpha.tau.negOne;
end

figure("color", figureColor); hold on; box on;
    plot( exp( y15.thresh.logRange ) ...
        , y15.tauAtAlphaZero ...
        , "color", "red" ...
        , "linewidth", 1 ...
        );
    xline(y15.thresh.val,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    xlabel("Detection Threshold Flux [ergs / s / cm^2]", "interpreter", "tex", "fontsize", fontSize);
    ylabel("Efron-Petrosian Tau Statistic \tau at \alpha = 0", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'linear', "color", figureColor);
    export_fig(y15.output.path + "threshTau.png", "-m4 -transparent")
hold off;

% plot alpha (tau = 0) versus threshold
% Chris: add a text to the vertical line in the plot denoting that this is
% Yu's detection threshold, something like "Y15 Detection Threshold". Once done, remove this note.

figure("color", figureColor); hold on; box on;
    plot( exp( y15.thresh.logRange ) ...
        , y15.alphaAtTauZero ...
        , "color", "red" ...
        , "linewidth", 1 ...
        );
    xline(y15.thresh.val,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    xlabel("Detection Threshold Flux [ergs / s / cm^2]", "interpreter", "tex", "fontsize", fontSize);
    ylabel("\alpha at Efron-Petrosian Tau Statistic \tau = 0", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'linear', "color", figureColor);
    export_fig(y15.output.path + "threshAlpha.png", "-m4 -transparent")
hold off;

% plot the original bivariate data for zone-liso

y15.thresh.logZone = log(1.05):0.02:log(21); % the range of z+1 for which the detection threshold will be drawn.
y15.thresh.zone = exp(y15.thresh.logZone);
y15.thresh.logLiso = y15.thresh.logVal + getLogLisoLumDisTerm(y15.thresh.zone);
y15.thresh.liso = exp(y15.thresh.logLiso);

figure("color", figureColor); hold on; box on;
    plot( y15.zone ...
        , y15.liso ...
        , "." ...
        , "markersize", 15 ...
        , "linewidth", 1 ...
        );
    plot( y15.thresh.zone ...
        , y15.thresh.liso ...
        , "color", "black" ...
        , "linewidth", 1 ...
        );
    slope = (y15.thresh.liso(150) - y15.thresh.liso(145))/(y15.thresh.zone(150) - y15.thresh.zone(145));
    plot( y15.thresh.zone ...
        , slope*y15.thresh.zone + 10^47 ...
        , "--" ...
        , "color", "green" ...
        );
    xlim([0, 12]);
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    ylabel("L_{iso} [ ergs / s ]", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    export_fig(y15.output.path + "zoneLiso.png", "-m4 -transparent")
hold off;

% Now build the decorrelated data and plot the the redshift-corrected bivariate data for zone-liso

y15.getZcorrection = @(logZone) y15.estat.logxMax.alpha.tau.zero * logZone;
y15.corrected.logLiso = y15.logLiso(:) - y15.getZcorrection( y15.logZone(:) );
y15.corrected.liso = exp(y15.corrected.logLiso);
y15.corrected.thresh.logLiso = y15.thresh.logLiso(:) - y15.getZcorrection( y15.thresh.logZone(:) );
y15.corrected.thresh.liso = exp(y15.corrected.thresh.logLiso);

figure("color", figureColor); hold on; box on;
    plot( y15.zone ...
        , y15.corrected.liso ...
        , "." ...
        , "markersize", 15 ...
        ..., "color", "black" ...
        , "linewidth", 1 ...
        );
    plot( y15.thresh.zone ...
        , y15.corrected.thresh.liso ...
        , "color", "black" ...
        , "linewidth", 1 ...
        );
    xlim([1.05, 12]);
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    ylabel("L_{0} [ ergs / s ]", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    export_fig(y15.output.path + "zoneLisoCorrected.png", "-m4 -transparent")
hold off;

