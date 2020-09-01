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

    t17 = struct();
    t17.thresh.val = 8.6e-07;
    t17.thresh.logVal = log(t17.thresh.val);

    t17.input.file.path = "../../in/T17table4_2.txt";
    t17.input.file.contents = importdata(t17.input.file.path,' ',47);
    t17.input.file.contents.sorted = sortrows(t17.input.file.contents.data,1);
    t17.output.path = "../../out/T17"; if ~isfolder(t17.output.path); mkdir(t17.output.path); end
    t17.zone = t17.input.file.contents.sorted(:,1) + 1;
    t17.liso = t17.input.file.contents.sorted(:,20)*1.e51;
    t17.logZone = log(t17.zone);
    t17.logLiso = log(t17.liso);

    t17.estat = EfronStat   ( t17.logZone ... logx
                            , t17.logLiso ... logy
                            , t17.thresh.logVal ... observerLogThresh
                            , "flux" ... threshType
                            );

    t17.logPbol = t17.estat.logyDistanceFromLogThresh + t17.thresh.logVal;
    t17.thresh.logMin = log(1.e-9);
    t17.thresh.logMax = log(1.e-5);
    t17.thresh.logRange = t17.thresh.logMin:0.2:t17.thresh.logMax;
    t17.thresh.logRangeLen = length(t17.thresh.logRange);
    t17.estatList = cell(t17.thresh.logRangeLen,1);
    %new
    %{
    t17.estat.logxMax.alpha.tau.zero
    t17.thresh.logZoneLimits = [1,12];
    t17.thresh.logZone = log(t17.thresh.logZoneLimits(1)):0.02:log(t17.thresh.logZoneLimits(2)); % the range of z+1 for which the detection threshold will be drawn.
    t17.thresh.zone = exp(t17.thresh.logZone);
    t17.thresh.logLiso = t17.thresh.logVal + getLogLisoLumDisTerm(t17.thresh.zone);
    t17.thresh.liso = exp(t17.thresh.logLiso);
    figure("color", figureColor); hold on; box on;
    plot( t17.zone ...
        , t17.liso ...
        , "." ...
        , "markersize", 15 ...
        , "linewidth", lineWidth ...
        );
    plot( t17.thresh.zone ...
        , t17.thresh.liso ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    hold off;
    return
    %}
    for i = 1:t17.thresh.logRangeLen
        t17.estatList{i} = EfronStat( t17.logZone ... logx
                                    , t17.logLiso ... logy
                                    , t17.thresh.logRange(i) ... observerLogThresh
                                    , "flux" ... threshType
                                    );
    end

    save(t17.output.path + "/t17_8.6e-7.mat","t17");

else
    
    t17.output.path = "../../out/t17";
    load(t17.output.path + "/t17_8.6e-7.mat"); % loads t17 object
    
end

% plot tau(alpha = 0) versus threshold

t17.tauAtAlphaZero = zeros(t17.thresh.logRangeLen,1);
t17.alphaAtTauZero = zeros(t17.thresh.logRangeLen,1);
t17.alphaAtTauPosOne = zeros(t17.thresh.logRangeLen,1);
t17.alphaAtTauNegOne = zeros(t17.thresh.logRangeLen,1);
for i = 1:t17.thresh.logRangeLen
    t17.tauAtAlphaZero(i) = t17.estatList{i}.logxMax.tau;
    t17.alphaAtTauZero(i) = t17.estatList{i}.logxMax.alpha.tau.zero;
    t17.alphaAtTauPosOne(i) = t17.estatList{i}.logxMax.alpha.tau.posOne;
    t17.alphaAtTauNegOne(i) = t17.estatList{i}.logxMax.alpha.tau.negOne;
end

figure("color", figureColor); hold on; box on;
    plot( exp( t17.thresh.logRange ) ...
        , t17.tauAtAlphaZero ...
        , "color", "red" ...
        , "linewidth", lineWidth ...
        );
    xline(t17.thresh.val,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    scatter(t17.thresh.val,t17.estat.logxMax.tau,100,'black')
    annotation('textarrow',[.63,.68],[.75,.75],'String','t17 detection threshold','fontsize',11);
    annotation('textarrow',[.63,.68],[.375,.375],'String','\tau = -5.77','fontsize',11);
    xlabel("Detection Threshold Flux [ergs / s / cm^2]", "interpreter", "tex", "fontsize", fontSize);
    ylabel("Efron-Petrosian Tau Statistic \tau at \alpha = 0", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'linear', "color", figureColor);
    export_fig(t17.output.path + "/t17threshTau.png", "-m4 -transparent")
hold off;

% plot alpha (tau = 0) versus threshold

figure("color", figureColor); hold on; box on;
    plot( exp( t17.thresh.logRange ) ...
        , t17.alphaAtTauZero ...
        , "color", "red" ...
        , "linewidth", lineWidth ...
        );
    xline(t17.thresh.val,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    %yline(0,"linewidth", 2, "linestyle", "--", "color", [1,0,1]);
    scatter(t17.thresh.val, t17.estat.logxMax.alpha.tau.zero, 100, 'black');
    %scatter(4.5e-7, 0, 100, [1,0,1]);
    annotation('textarrow',[.625,.675],[.4,.4],'String','t17 detection threshold','fontsize',11);
    annotation('textarrow',[.625,.675],[.623,.623],'String','\alpha = 1.70','fontsize',11);
    %annotation('textarrow',[.7,.65],[.515,.465],'String','flux = 2.214e-7','fontsize',11);
    xlabel("Detection Threshold Flux [ergs / s / cm^2]", "interpreter", "tex", "fontsize", fontSize);
    ylabel("\alpha at Efron-Petrosian Tau Statistic \tau = 0", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'linear', "color", figureColor);
    export_fig(t17.output.path + "/t17threshAlpha.png", "-m4 -transparent")
hold off;

% plot the original bivariate data for zone-liso

t17.thresh.logZoneLimits = [1,12];
t17.thresh.logZone = log(t17.thresh.logZoneLimits(1)):0.02:log(t17.thresh.logZoneLimits(2)); % the range of z+1 for which the detection threshold will be drawn.
t17.thresh.zone = exp(t17.thresh.logZone);
t17.thresh.logLiso = t17.thresh.logVal + getLogLisoLumDisTerm(t17.thresh.zone);
t17.thresh.liso = exp(t17.thresh.logLiso);

t17.getZcorrection = @(logZone) t17.estat.logxMax.alpha.tau.zero * logZone;
t17.corrected.logLiso = t17.logLiso(:) - t17.getZcorrection( t17.logZone(:) );
t17.corrected.liso = exp(t17.corrected.logLiso);
t17.corrected.thresh.logLiso = t17.thresh.logLiso(:) - t17.getZcorrection( t17.thresh.logZone(:) );
t17.corrected.thresh.liso = exp(t17.corrected.thresh.logLiso);

% fit the data by keeping the slope constant

t17.regression.slope  = t17.estat.logxMax.alpha.tau.zero;
t17.regression.getLogLiso = @(intercept, logZone) intercept + t17.getZcorrection(logZone);
t17.getSumDistSq = @(intercept) sum( (t17.logLiso - t17.regression.getLogLiso(intercept,t17.logZone)).^2 );
t17.regression.intercept = fminsearch( t17.getSumDistSq , 120 );
t17.regression.logZone = min(t17.logZone):0.05:max(t17.logZone);
t17.regression.logLiso = t17.regression.getLogLiso(t17.regression.intercept, t17.regression.logZone);

% fit the detection threshold

t17.thresh.regression.pointIndices = [ length(t17.thresh.logZone) - 5 , length(t17.thresh.logZone) ];
t17.thresh.regression.logZoneLimits = [ t17.thresh.logZone(t17.thresh.regression.pointIndices(1)) , t17.thresh.logZone(t17.thresh.regression.pointIndices(2)) ];
t17.thresh.regression.logLisoLimits = [ t17.thresh.logLiso(t17.thresh.regression.pointIndices(1)) , t17.thresh.logLiso(t17.thresh.regression.pointIndices(2)) ];
t17.thresh.regression.slope = ( t17.thresh.regression.logLisoLimits(2) - t17.thresh.regression.logLisoLimits(1) ) ...
                            / ( t17.thresh.regression.logZoneLimits(2) - t17.thresh.regression.logZoneLimits(1) );

% plot zone-liso

figure("color", figureColor); hold on; box on;
    plot( t17.zone ...
        , t17.liso ...
        , "." ...
        , "markersize", 15 ...
        , "linewidth", lineWidth ...
        );
    plot( t17.thresh.zone ...
        , t17.thresh.liso ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    plot( exp( t17.regression.logZone ) ...
        , exp( t17.regression.logLiso ) ...
        , "--" ...
        , "color", [1,0,1] ...
        , "linewidth", 1.5 * lineWidth ...
        );
    %line([t17.thresh.logZoneLimits(1),4.86],[2.9e+51,2.9e+51],'color','black','linewidth',1,'linestyle','--')
    %line([4.86,4.86],[2.9e+51,1.e56],'color','black','linewidth',1,'linestyle','--')
    %scatter(2.77,2.9e51,75,'black')
    %text(2,1.e55,'N_{i}','fontsize',13);
    %annotation('textarrow',[.5,.453],[.45,.545],'String','point i','fontsize',12);
    %yline(4.5e54,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    xlim(t17.thresh.logZoneLimits);
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    ylabel("L_{iso} [ ergs / s ]", "interpreter", "tex", "fontsize", fontSize);
    legend(["t17 sample", "t17 detection limit","Regression line slope = \alpha"], "interpreter", "tex", "location", "southeast", "fontSize", fontSize,'color',figureColor)
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    export_fig(t17.output.path + "/t17zoneLiso.png", "-m4 -transparent")
hold off;


% Now build the decorrelated data and plot the redshift-corrected bivariate data for zone-liso


figure("color", figureColor); hold on; box on;
    plot( t17.zone ...
        , t17.corrected.liso ...
        , "." ...
        , "markersize", 15 ...
        ..., "color", "black" ...
        , "linewidth", lineWidth ...
        );
    plot( t17.thresh.zone ...
        , t17.corrected.thresh.liso ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    xlim(t17.thresh.logZoneLimits);
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    ylabel("L_{0} [ ergs / s ]", "interpreter", "tex", "fontsize", fontSize);
    legend(["t17 sample", "t17 detection limit"], "interpreter", "tex", "location", "southeast", "fontSize", fontSize,'color',figureColor)
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    export_fig(t17.output.path + "/t17zoneLisoCorrected.png", "-m4 -transparent")
hold off;
%{
figure("color", figureColor); hold on; box on;
    histogram(t17.estat.logyDistanceFromLogThresh,"BinWidth",0.5);
hold off;
%}