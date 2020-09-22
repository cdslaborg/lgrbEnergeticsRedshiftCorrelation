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
lineWidth = 1.5;
figureColor = "white";
freshRunEnabled = false; % this must be set to true for first ever simulation. Thereafter, it can be set to false to save time.

if freshRunEnabled

    p16 = struct();
    p16.thresh.val = 1.e-07;
    %p16.thresh.val = 2.0704e-07; % for Ep = 140
    %p16.thresh.val = 2.2878e-07; % for Ep = 362
    %p16.thresh.val = 2.3433e-07; % for Ep = 574
    p16.thresh.logVal = log(p16.thresh.val);

    p16.input.file.path = "../../in/P16tableB1.xlsx";
    p16.input.file.contents = importdata(p16.input.file.path);
    p16.input.file.contents.sorted = sortrows(p16.input.file.contents.data,2);
    p16.output.path = "../../out/P16"; if ~isfolder(p16.output.path); mkdir(p16.output.path); end
    p16.zone = p16.input.file.contents.sorted(:,2) + 1;
    p16.liso = p16.input.file.contents.sorted(:,4);
    p16.logZone = log(p16.zone);
    p16.logLiso = log(p16.liso);

    p16.estat = EfronStat   ( p16.logZone ... logx
                            , p16.logLiso ... logy
                            , p16.thresh.logVal ... observerLogThresh
                            , "flux" ... threshType
                            );

    p16.logPbol = p16.estat.logyDistanceFromLogThresh + p16.thresh.logVal;
    p16.thresh.logMin = log(1.e-9);
    p16.thresh.logMax = log(1.e-5);
    p16.thresh.logRange = p16.thresh.logMin:0.2:p16.thresh.logMax;
    p16.thresh.logRangeLen = length(p16.thresh.logRange);
    p16.estatList = cell(p16.thresh.logRangeLen,1);
    %return
    for i = 1:p16.thresh.logRangeLen
        p16.estatList{i} = EfronStat( p16.logZone ... logx
                                    , p16.logLiso ... logy
                                    , p16.thresh.logRange(i) ... observerLogThresh
                                    , "flux" ... threshType
                                    );
    end

    save(p16.output.path + "/p16.mat","p16");

else
    
    p16.output.path = "../../out/P16";
    load(p16.output.path + "/p16.mat"); % loads p16 object
    
end

% plot tau(alpha = 0) versus threshold

p16.tauAtAlphaZero = zeros(p16.thresh.logRangeLen,1);
p16.alphaAtTauZero = zeros(p16.thresh.logRangeLen,1);
p16.alphaAtTauPosOne = zeros(p16.thresh.logRangeLen,1);
p16.alphaAtTauNegOne = zeros(p16.thresh.logRangeLen,1);
for i = 1:p16.thresh.logRangeLen
    p16.tauAtAlphaZero(i) = p16.estatList{i}.logxMax.tau;
    p16.alphaAtTauZero(i) = p16.estatList{i}.logxMax.alpha.tau.zero;
    p16.alphaAtTauPosOne(i) = p16.estatList{i}.logxMax.alpha.tau.posOne;
    p16.alphaAtTauNegOne(i) = p16.estatList{i}.logxMax.alpha.tau.negOne;
end

figure("color", figureColor); hold on; box on;
    plot( exp( p16.thresh.logRange ) ...
        , p16.tauAtAlphaZero ...
        , "color", "red" ...
        , "linewidth", lineWidth ...
        );
    xline(p16.thresh.val,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    scatter(p16.thresh.val,-5,100,'black')
    annotation('textarrow',[.45,.5],[.75,.75],'String','p16 detection threshold','fontsize',11);
    annotation('textarrow',[.45,.5],[.3,.3],'String','\tau = -5.0','fontsize',11);
    xlabel("Detection Threshold Flux [ ergs / s / cm^2 ]", "interpreter", "tex", "fontsize", fontSize);
    ylabel("Efron-Petrosian Tau Statistic \tau at \alpha = 0", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'linear', "color", figureColor);
    export_fig(p16.output.path + "/P16threshTau.png", "-m4 -transparent")
hold off;

% plot alpha (tau = 0) versus threshold

figure("color", figureColor); hold on; box on;
    plot( exp( p16.thresh.logRange ) ...
        , p16.alphaAtTauZero ...
        , "color", "red" ...
        , "linewidth", lineWidth ...
        );
    xline(p16.thresh.val,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    scatter(p16.thresh.val, p16.estat.logxMax.alpha.tau.zero, 100, 'black');
    annotation('textarrow',[.59,.54],[.85,.85],'String','p16 detection threshold','fontsize',11);
    annotation('textarrow',[.59,.54],[.728,.728],'String','\alpha = 2.53','fontsize',11);
    xlabel("Detection Threshold Flux [ ergs / s / cm^2 ]", "interpreter", "tex", "fontsize", fontSize);
    ylabel("\alpha at Efron-Petrosian Tau Statistic \tau = 0", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'linear', "color", figureColor);
    export_fig(p16.output.path + "/P16threshAlpha.png", "-m4 -transparent")
hold off;


% plot the original bivariate data for zone-liso


p16.thresh.logZoneLimits = [1,12];
p16.thresh.logZone = log(p16.thresh.logZoneLimits(1)):0.02:log(p16.thresh.logZoneLimits(2)); % the range of z+1 for which the detection threshold will be drawn.
p16.thresh.zone = exp(p16.thresh.logZone);
p16.thresh.logLiso = p16.thresh.logVal + getLogLisoLumDisTerm(p16.thresh.zone);
p16.thresh.liso = exp(p16.thresh.logLiso);

p16.getZcorrection = @(logZone) p16.estat.logxMax.alpha.tau.zero * logZone;
p16.corrected.logLiso = p16.logLiso(:) - p16.getZcorrection( p16.logZone(:) );
p16.corrected.liso = exp(p16.corrected.logLiso);
p16.corrected.thresh.logLiso = p16.thresh.logLiso(:) - p16.getZcorrection( p16.thresh.logZone(:) );
p16.corrected.thresh.liso = exp(p16.corrected.thresh.logLiso);

% fit the data by keeping the slope constant

p16.regression.slope  = p16.estat.logxMax.alpha.tau.zero;
p16.regression.getLogLiso = @(intercept, logZone) intercept + p16.getZcorrection(logZone);
p16.getSumDistSq = @(intercept) sum( (p16.logLiso - p16.regression.getLogLiso(intercept,p16.logZone)).^2 );
p16.regression.intercept = fminsearch( p16.getSumDistSq , 120 );
p16.regression.logZone = min(p16.logZone):0.05:max(p16.logZone);
p16.regression.logLiso = p16.regression.getLogLiso(p16.regression.intercept, p16.regression.logZone);

% fit the detection threshold

p16.thresh.regression.pointIndices = [ length(p16.thresh.logZone) - 5 , length(p16.thresh.logZone) ];
p16.thresh.regression.logZoneLimits = [ p16.thresh.logZone(p16.thresh.regression.pointIndices(1)) , p16.thresh.logZone(p16.thresh.regression.pointIndices(2)) ];
p16.thresh.regression.logLisoLimits = [ p16.thresh.logLiso(p16.thresh.regression.pointIndices(1)) , p16.thresh.logLiso(p16.thresh.regression.pointIndices(2)) ];
p16.thresh.regression.slope = ( p16.thresh.regression.logLisoLimits(2) - p16.thresh.regression.logLisoLimits(1) ) ...
                            / ( p16.thresh.regression.logZoneLimits(2) - p16.thresh.regression.logZoneLimits(1) );

% plot zone-liso

figure("color", figureColor); hold on; box on;
    plot( p16.zone ...
        , p16.liso ...
        , "." ...
        , "markersize", 15 ...
        , "linewidth", lineWidth ...
        );
    plot( p16.thresh.zone ...
        , p16.thresh.liso ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    plot( exp( p16.regression.logZone ) ...
        , exp( p16.regression.logLiso ) ...
        , "--" ...
        , "color", [0,1,0] ...
        , "linewidth", 1.5 * lineWidth ...
        );
    xlim(p16.thresh.logZoneLimits);
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    ylabel("L_{iso} [ ergs / s ]", "interpreter", "tex", "fontsize", fontSize);
    legend(["p16 sample", "p16 detection limit","Regression line slope = \alpha"], "interpreter", "tex", "location", "southeast", "fontSize", fontSize,'color',figureColor)
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    export_fig(p16.output.path + "/P16zoneLiso.png", "-m4 -transparent")
hold off;


% Now build the decorrelated data and plot the redshift-corrected bivariate data for zone-liso


figure("color", figureColor); hold on; box on;
    plot( p16.zone ...
        , p16.corrected.liso ...
        , "." ...
        , "markersize", 15 ...
        ..., "color", "black" ...
        , "linewidth", lineWidth ...
        );
    plot( p16.thresh.zone ...
        , p16.corrected.thresh.liso ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    xlim(p16.thresh.logZoneLimits);
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    ylabel("L_{0} [ ergs / s ]", "interpreter", "tex", "fontsize", fontSize);
    legend(["p16 sample", "p16 detection limit"], "interpreter", "tex", "location", "southeast", "fontSize", fontSize,'color',figureColor)
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    export_fig(p16.output.path + "/P16zoneLisoCorrected.png", "-m4 -transparent")
hold off;
%{
figure("color", figureColor); hold on; box on;
    histogram(p16.estat.logyDistanceFromLogThresh,"BinWidth",0.5);
hold off;
%}