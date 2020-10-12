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
freshRunEnabled = true; % this must be set to true for first ever simulation. Thereafter, it can be set to false to save time.

if freshRunEnabled

    L19 = struct();
    %L19.thresh.val = 1.6e-07; % 
    L19.thresh.val = 1.e-10; % 
    %L19.thresh.val = 7.e-7; % value in paper
    L19.thresh.logVal = log(L19.thresh.val);

    L19.input.file.path = "../../in/L19figure1.xlsx";
    L19.input.file.contents = importdata(L19.input.file.path);
    L19.input.file.contents.sorted = sortrows(L19.input.file.contents.data,1);
    L19.output.path = "../../out/L19"; if ~isfolder(L19.output.path); mkdir(L19.output.path); end
    L19.zone = L19.input.file.contents.sorted(:,1) + 1;
    L19.liso = 1.e52*L19.input.file.contents.sorted(:,3).*L19.zone./L19.input.file.contents.sorted(:,2);
    L19.logZone = log(L19.zone);
    L19.logLiso = log(L19.liso);

    L19.estat = EfronStat   ( L19.logZone ... logx
                            , L19.logLiso ... logy
                            , L19.thresh.logVal ... observerLogThresh
                            , "flux" ... threshType
                            );

    L19.logPbol = L19.estat.logyDistanceFromLogThresh + L19.thresh.logVal;
    L19.thresh.logMin = log(1.e-9);
    L19.thresh.logMax = log(1.e-5);
    L19.thresh.logRange = L19.thresh.logMin:0.2:L19.thresh.logMax;
    L19.thresh.logRangeLen = length(L19.thresh.logRange);
    L19.estatList = cell(L19.thresh.logRangeLen,1);
    %new
    %{
    L19.estat.logxMax.alpha.tau.zero
    L19.thresh.logZoneLimits = [1,12];
    L19.thresh.logZone = log(L19.thresh.logZoneLimits(1)):0.02:log(L19.thresh.logZoneLimits(2)); % the range of z+1 for which the detection threshold will be drawn.
    L19.thresh.zone = exp(L19.thresh.logZone);
    L19.thresh.logLiso = L19.thresh.logVal + getLogLisoLumDisTerm(L19.thresh.zone);
    L19.thresh.liso = exp(L19.thresh.logLiso);
    figure("color", figureColor); hold on; box on;
    plot( L19.zone ...
        , L19.liso ...
        , "." ...
        , "markersize", 15 ...
        , "linewidth", lineWidth ...
        );
    plot( L19.thresh.zone ...
        , L19.thresh.liso ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    hold off;
    return
    %}
    for i = 1:L19.thresh.logRangeLen
        L19.estatList{i} = EfronStat( L19.logZone ... logx
                                    , L19.logLiso ... logy
                                    , L19.thresh.logRange(i) ... observerLogThresh
                                    , "flux" ... threshType
                                    );
    end

    save(L19.output.path + "/L19liso.mat","L19");

else
    
    L19.output.path = "../../out/L19";
    load(L19.output.path + "/L19liso.mat"); % loads L19 object
    
end

% plot tau(alpha = 0) versus threshold

L19.tauAtAlphaZero = zeros(L19.thresh.logRangeLen,1);
L19.alphaAtTauZero = zeros(L19.thresh.logRangeLen,1);
L19.alphaAtTauPosOne = zeros(L19.thresh.logRangeLen,1);
L19.alphaAtTauNegOne = zeros(L19.thresh.logRangeLen,1);
for i = 1:L19.thresh.logRangeLen
    L19.tauAtAlphaZero(i) = L19.estatList{i}.logxMax.tau;
    L19.alphaAtTauZero(i) = L19.estatList{i}.logxMax.alpha.tau.zero;
    L19.alphaAtTauPosOne(i) = L19.estatList{i}.logxMax.alpha.tau.posOne;
    L19.alphaAtTauNegOne(i) = L19.estatList{i}.logxMax.alpha.tau.negOne;
end

figure("color", figureColor); hold on; box on;
    plot( exp( L19.thresh.logRange ) ...
        , L19.tauAtAlphaZero ...
        , "color", "red" ...
        , "linewidth", lineWidth ...
        );
    xline(L19.thresh.val,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    scatter(L19.thresh.val,L19.estat.logxMax.tau,100,'black')
    %annotation('textarrow',[.48,.53],[.75,.75],'String','L19 detection threshold','fontsize',11);
    %annotation('textarrow',[.48,.53],[.25,.25],'String','\tau = -6.15','fontsize',11);
    xlabel("Detection Threshold Flux [ergs / s / cm^2]", "interpreter", "tex", "fontsize", fontSize);
    ylabel("Efron-Petrosian Tau Statistic \tau at \alpha = 0", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'linear', "color", figureColor);
    %export_fig(L19.output.path + "/L19threshTauLiso.png", "-m4 -transparent")
hold off;

% plot alpha (tau = 0) versus threshold

figure("color", figureColor); hold on; box on;
    plot( exp( L19.thresh.logRange ) ...
        , L19.alphaAtTauZero ...
        , "color", "red" ...
        , "linewidth", lineWidth ...
        );
    xline(L19.thresh.val,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    %yline(0,"linewidth", 2, "linestyle", "--", "color", [1,0,1]);
    scatter(L19.thresh.val, L19.estat.logxMax.alpha.tau.zero, 100, 'black');
    %annotation('textarrow',[.48,.53],[.4,.4],'String','L19 detection threshold','fontsize',11);
    %annotation('textarrow',[.48,.53],[.72,.72],'String','\alpha = 1.34','fontsize',11);
    %annotation('textarrow',[.7,.65],[.515,.465],'String','flux = 2.214e-7','fontsize',11);
    xlabel("Detection Threshold Flux [ergs / s / cm^2]", "interpreter", "tex", "fontsize", fontSize);
    ylabel("\alpha at Efron-Petrosian Tau Statistic \tau = 0", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'linear', "color", figureColor);
    %export_fig(L19.output.path + "/L19threshAlphaLiso.png", "-m4 -transparent")
hold off;

% plot the original bivariate data for zone-liso

L19.thresh.logZoneLimits = [1,12];
L19.thresh.logZone = log(L19.thresh.logZoneLimits(1)):0.02:log(L19.thresh.logZoneLimits(2)); % the range of z+1 for which the detection threshold will be drawn.
L19.thresh.zone = exp(L19.thresh.logZone);
L19.thresh.logLiso = L19.thresh.logVal + getLogLisoLumDisTerm(L19.thresh.zone);
L19.thresh.liso = exp(L19.thresh.logLiso);

L19.getZcorrection = @(logZone) L19.estat.logxMax.alpha.tau.zero * logZone;
L19.corrected.logLiso = L19.logLiso(:) - L19.getZcorrection( L19.logZone(:) );
L19.corrected.liso = exp(L19.corrected.logLiso);
L19.corrected.thresh.logLiso = L19.thresh.logLiso(:) - L19.getZcorrection( L19.thresh.logZone(:) );
L19.corrected.thresh.liso = exp(L19.corrected.thresh.logLiso);

% fit the data by keeping the slope constant

L19.regression.slope  = L19.estat.logxMax.alpha.tau.zero;
L19.regression.getLogLiso = @(intercept, logZone) intercept + L19.getZcorrection(logZone);
L19.getSumDistSq = @(intercept) sum( (L19.logLiso - L19.regression.getLogLiso(intercept,L19.logZone)).^2 );
L19.regression.intercept = fminsearch( L19.getSumDistSq , 120 );
L19.regression.logZone = min(L19.logZone):0.05:max(L19.logZone);
L19.regression.logLiso = L19.regression.getLogLiso(L19.regression.intercept, L19.regression.logZone);

% fit the detection threshold

L19.thresh.regression.pointIndices = [ length(L19.thresh.logZone) - 5 , length(L19.thresh.logZone) ];
L19.thresh.regression.logZoneLimits = [ L19.thresh.logZone(L19.thresh.regression.pointIndices(1)) , L19.thresh.logZone(L19.thresh.regression.pointIndices(2)) ];
L19.thresh.regression.logLisoLimits = [ L19.thresh.logLiso(L19.thresh.regression.pointIndices(1)) , L19.thresh.logLiso(L19.thresh.regression.pointIndices(2)) ];
L19.thresh.regression.slope = ( L19.thresh.regression.logLisoLimits(2) - L19.thresh.regression.logLisoLimits(1) ) ...
                            / ( L19.thresh.regression.logZoneLimits(2) - L19.thresh.regression.logZoneLimits(1) );

% plot zone-liso

figure("color", figureColor); hold on; box on;
    plot( L19.zone ...
        , L19.liso ...
        , "." ...
        , "markersize", 15 ...
        , "linewidth", lineWidth ...
        );
    plot( L19.thresh.zone ...
        , L19.thresh.liso ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    plot( exp( L19.regression.logZone ) ...
        , exp( L19.regression.logLiso ) ...
        , "--" ...
        , "color", [1,0,1] ...
        , "linewidth", 1.5 * lineWidth ...
        );
    %line([L19.thresh.logZoneLimits(1),4.86],[2.9e+51,2.9e+51],'color','black','linewidth',1,'linestyle','--')
    %line([4.86,4.86],[2.9e+51,1.e56],'color','black','linewidth',1,'linestyle','--')
    %scatter(2.77,2.9e51,75,'black')
    %text(2,1.e55,'N_{i}','fontsize',13);
    %annotation('textarrow',[.5,.453],[.45,.545],'String','point i','fontsize',12);
    %yline(4.5e54,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    xlim(L19.thresh.logZoneLimits);
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    ylabel("L_{iso} [ ergs / s ]", "interpreter", "tex", "fontsize", fontSize);
    legend(["L19 sample", "L19 detection limit","Regression line slope = \alpha"], "interpreter", "tex", "location", "southeast", "fontSize", fontSize,'color',figureColor)
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    %export_fig(L19.output.path + "/L19zoneLiso.png", "-m4 -transparent")
hold off;


% Now build the decorrelated data and plot the redshift-corrected bivariate data for zone-liso


figure("color", figureColor); hold on; box on;
    plot( L19.zone ...
        , L19.corrected.liso ...
        , "." ...
        , "markersize", 15 ...
        ..., "color", "black" ...
        , "linewidth", lineWidth ...
        );
    plot( L19.thresh.zone ...
        , L19.corrected.thresh.liso ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    xlim(L19.thresh.logZoneLimits);
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    ylabel("L_{0} [ ergs / s ]", "interpreter", "tex", "fontsize", fontSize);
    legend(["L19 sample", "L19 detection limit"], "interpreter", "tex", "location", "southeast", "fontSize", fontSize,'color',figureColor)
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    %export_fig(L19.output.path + "/L19zoneLisoCorrected.png", "-m4 -transparent")
hold off;