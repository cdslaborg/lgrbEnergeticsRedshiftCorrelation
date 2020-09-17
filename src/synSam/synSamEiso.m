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

threshType = "fluence";
matFileName = "synSam" + threshType + ".mat";
if strcmpi(threshType,"flux")
    threshTypeInt = "Liso";
elseif strcmpi(threshType,"fluence")
    threshTypeInt = "Eiso";
end

if freshRunEnabled

    synSam = genSynSam(threshType);

    synSam.output.path = "../../out/synSam"; if ~isfolder(synSam.output.path); mkdir(synSam.output.path); end

    synSam.estat = EfronStat( synSam.logZone ... logx
                            , synSam.logyint ... logy
                            , synSam.thresh.logVal ... observerLogThresh
                            , threshType ... threshType
                            );

    synSam.thresh.logMin = log(1.e-9);
    synSam.thresh.logMax = log(1.e-5);
    synSam.thresh.logRange = synSam.thresh.logMin:0.2:synSam.thresh.logMax;
    synSam.thresh.logRangeLen = length(synSam.thresh.logRange);
    synSam.estatList = cell(synSam.thresh.logRangeLen,1);

    for i = 1:synSam.thresh.logRangeLen
        synSam.estatList{i} = EfronStat ( synSam.logZone ... logx
                                        , synSam.logyint ... logy
                                        , synSam.thresh.logRange(i) ... observerLogThresh
                                        , threshType ... threshType
                                        );
    end

    save(synSam.output.path + "/" + matFileName,"synSam");

else
    
    synSam.output.path = "../../out/synSam";
    load(synSam.output.path + "/" + matFileName); % loads synSam object
    
end

% plot tau(alpha = 0) versus threshold

synSam.tauAtAlphaZero = zeros(synSam.thresh.logRangeLen,1);
synSam.alphaAtTauZero = zeros(synSam.thresh.logRangeLen,1);
synSam.alphaAtTauPosOne = zeros(synSam.thresh.logRangeLen,1);
synSam.alphaAtTauNegOne = zeros(synSam.thresh.logRangeLen,1);
for i = 1:synSam.thresh.logRangeLen
    synSam.tauAtAlphaZero(i) = synSam.estatList{i}.logxMax.tau;
    synSam.alphaAtTauZero(i) = synSam.estatList{i}.logxMax.alpha.tau.zero;
    synSam.alphaAtTauPosOne(i) = synSam.estatList{i}.logxMax.alpha.tau.posOne;
    synSam.alphaAtTauNegOne(i) = synSam.estatList{i}.logxMax.alpha.tau.negOne;
end

figure("color", figureColor); hold on; box on;
    plot( exp( synSam.thresh.logRange ) ...
        , synSam.tauAtAlphaZero ...
        , "color", "red" ...
        , "linewidth", lineWidth ...
        );
    p = xline(synSam.thresh.val,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    p1 = scatter(synSam.thresh.val,synSam.estat.logxMax.tau,100,'black');
    %annotation('textarrow',[.63,.68],[.75,.75],'String','synSam detection threshold','fontsize',11);
    %annotation('textarrow',[.63,.68],[.33,.33],'String','\tau = -5.42','fontsize',11);
    if strcmpi(threshType,"flux")
        xlabel("Detection Threshold Flux [ergs / s / cm^2]", "interpreter", "tex", "fontsize", fontSize);
    elseif strcmpi(threshType,"fluence")
        xlabel("Detection Threshold Fluence [ergs / cm^2]", "interpreter", "tex", "fontsize", fontSize);
    end
    legend([p,p1],"detection limit at 50%-probability","\tau = " + string(synSam.estat.logxMax.tau + " at detection limit"),"location","southwest")
    ylabel("Efron-Petrosian Tau Statistic \tau at \alpha = 0", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'linear', "color", figureColor);
    export_fig(synSam.output.path + "/synSam" + threshType + "ThreshTau.png", "-m4 -transparent")
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% plot alpha (tau = 0) versus threshold
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure("color", figureColor); hold on; box on;
    plot( exp( synSam.thresh.logRange ) ...
        , synSam.alphaAtTauZero ...
        , "color", "red" ...
        , "linewidth", lineWidth ...
        );
    p2 = xline(synSam.thresh.val,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    %yline(0,"linewidth", 2, "linestyle", "--", "color", [1,0,1]);
    p3 = scatter(synSam.thresh.val, synSam.estat.logxMax.alpha.tau.zero, 100, 'black');
    %scatter(4.5e-7, 0, 100, [1,0,1]);
    %annotation('textarrow',[.625,.675],[.4,.4],'String','synSam detection threshold','fontsize',11);
    %annotation('textarrow',[.625,.675],[.623,.623],'String','\alpha = 1.70','fontsize',11);
    %annotation('textarrow',[.7,.65],[.515,.465],'String','flux = 2.214e-7','fontsize',11);
    if strcmpi(threshType,"flux")
        xlabel("Detection Threshold Flux [ergs / s / cm^2]", "interpreter", "tex", "fontsize", fontSize);
    elseif strcmpi(threshType,"fluence")
        xlabel("Detection Threshold Fluence [ergs / cm^2]", "interpreter", "tex", "fontsize", fontSize);
    end
    legend([p2,p3],"detection limit at 50%-probability" , "\alpha = " + string(synSam.estat.logxMax.alpha.tau.zero + " at detection limit"),"location","southwest")
    ylabel("\alpha at Efron-Petrosian Tau Statistic \tau = 0", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'linear', "color", figureColor);
    export_fig(synSam.output.path + "/synSam" + threshType + "ThreshAlpha.png", "-m4 -transparent")
hold off;

% plot the original bivariate data for zone-yint

synSam.thresh.logZoneLimits = [1,12];
synSam.thresh.logZone = log(synSam.thresh.logZoneLimits(1)):0.02:log(synSam.thresh.logZoneLimits(2)); % the range of z+1 for which the detection threshold will be drawn.
synSam.thresh.zone = exp(synSam.thresh.logZone);
if strcmpi(threshType,"flux")
    synSam.thresh.logyint = synSam.thresh.logVal + getLogLisoLumDisTerm(synSam.thresh.zone);
elseif strcmpi(threshType,"fluence")
    synSam.thresh.logyint = synSam.thresh.logVal + getLogEisoLumDisTerm(synSam.thresh.zone);
end
synSam.thresh.yint = exp(synSam.thresh.logyint);

synSam.getZcorrection = @(logZone) synSam.estat.logxMax.alpha.tau.zero * logZone;
synSam.corrected.logyint = synSam.logyint(:) - synSam.getZcorrection( synSam.logZone(:) );
synSam.corrected.yint = exp(synSam.corrected.logyint);
synSam.corrected.thresh.logyint = synSam.thresh.logyint(:) - synSam.getZcorrection( synSam.thresh.logZone(:) );
synSam.corrected.thresh.yint = exp(synSam.corrected.thresh.logyint);

% fit the data by keeping the slope constant

synSam.regression.slope  = synSam.estat.logxMax.alpha.tau.zero;
synSam.regression.getLogYint = @(intercept, logZone) intercept + synSam.getZcorrection(logZone);
synSam.getSumDistSq = @(intercept) sum( (synSam.logyint - synSam.regression.getLogYint(intercept,synSam.logZone)).^2 );
synSam.regression.intercept = fminsearch( synSam.getSumDistSq , 120 );
synSam.regression.logZone = min(synSam.logZone):0.05:max(synSam.logZone);
synSam.regression.logyint = synSam.regression.getLogYint(synSam.regression.intercept, synSam.regression.logZone);

% fit the detection threshold

synSam.thresh.regression.pointIndices   = [ length(synSam.thresh.logZone) - 5 , length(synSam.thresh.logZone) ];
synSam.thresh.regression.logZoneLimits  = [ synSam.thresh.logZone(synSam.thresh.regression.pointIndices(1)) , synSam.thresh.logZone(synSam.thresh.regression.pointIndices(2)) ];
synSam.thresh.regression.logLisoLimits  = [ synSam.thresh.logyint(synSam.thresh.regression.pointIndices(1)) , synSam.thresh.logyint(synSam.thresh.regression.pointIndices(2)) ];
synSam.thresh.regression.slope  = ( synSam.thresh.regression.logLisoLimits(2) - synSam.thresh.regression.logLisoLimits(1) ) ...
                                / ( synSam.thresh.regression.logZoneLimits(2) - synSam.thresh.regression.logZoneLimits(1) );

% plot zone-yint

figure("color", figureColor); hold on; box on;colormap('cool');
    scatter( synSam.zone ...
        , synSam.yint ...
        , 25.75*ones(synSam.ndata,1) ...
        , synSam.detProb ...
        , '.' ...
        );
    plot( synSam.thresh.zone ...
        , synSam.thresh.yint ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    plot( exp( synSam.regression.logZone ) ...
        , exp( synSam.regression.logyint ) ...
        , "--" ...
        , "color", [0,1,0] ...
        , "linewidth", 1.5 * lineWidth ...
        );
    
    
    CBar = colorbar;
    CBar.Label.String = 'Probability of Detection by BATSE LADs';
    CBar.Label.Interpreter = 'tex';
    CBar.Label.FontSize = fontSize;
    %line([synSam.thresh.logZoneLimits(1),4.86],[2.9e+51,2.9e+51],'color','black','linewidth',1,'linestyle','--')
    %line([4.86,4.86],[2.9e+51,1.e56],'color','black','linewidth',1,'linestyle','--')
    %scatter(2.77,2.9e51,75,'black')
    %text(2,1.e55,'N_{i}','fontsize',13);
    %annotation('textarrow',[.5,.453],[.45,.545],'String','point i','fontsize',12);
    %yline(4.5e54,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    xlim(synSam.thresh.logZoneLimits);
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    if strcmpi(threshType,"flux")
        ylabel("L_{iso} [ ergs / s ]", "interpreter", "tex", "fontsize", fontSize);
    elseif strcmpi(threshType,"fluence")
        ylabel("E_{iso} [ ergs ]", "interpreter", "tex", "fontsize", fontSize);
    end
    legend(["synSam sample", "synSam detection limit","Regression line slope = \alpha"], "interpreter", "tex", "location", "southeast", "fontSize", fontSize,'color',figureColor)
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    export_fig(synSam.output.path + "/synSam" + threshType + "Zone" + threshTypeInt + ".png", "-m4 -transparent")
hold off;


% Now build the decorrelated data and plot the redshift-corrected bivariate data for zone-yint


figure("color", figureColor); hold on; box on;colormap('cool');
    scatter( synSam.zone ...
        , synSam.corrected.yint ...
        , 25.75*ones(synSam.ndata,1) ...
        , synSam.detProb ...
        , '.' ...
        );
    plot( synSam.thresh.zone ...
        , synSam.corrected.thresh.yint ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    
    CBar = colorbar;
    CBar.Label.String = 'Probability of Detection by BATSE LADs';
    CBar.Label.Interpreter = 'tex';
    CBar.Label.FontSize = fontSize;
    
    xlim(synSam.thresh.logZoneLimits);
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    if strcmpi(threshType,"flux")
        ylabel("L_{0} [ ergs / s ]", "interpreter", "tex", "fontsize", fontSize);
    elseif strcmpi(threshType,"fluence")
        ylabel("E_{0} [ ergs ]", "interpreter", "tex", "fontsize", fontSize);
    end
    legend(["synSam sample", "synSam detection limit"], "interpreter", "tex", "location", "southeast", "fontSize", fontSize,'color',figureColor)
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    export_fig(synSam.output.path + "/synSam" + threshType + "Zone" + threshTypeInt + "Corrected.png", "-m4 -transparent")
hold off;
