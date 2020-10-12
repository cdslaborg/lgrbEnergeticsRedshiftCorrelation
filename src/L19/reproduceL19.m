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

    L19 = struct();
    L19.thresh.val = 1.6e-7; % to match threshold line
    %L19.thresh.val = 2e-6; % value in paper
    %L19.thresh.val = 7e-10; % to get alpha = 2.30
    L19.thresh.logVal = log(L19.thresh.val);

    L19.input.file.path = "../../in/L19figure1.xlsx";
    L19.input.file.contents = importdata(L19.input.file.path);
    L19.input.file.contents.sorted = sortrows(L19.input.file.contents.data,1);
    L19.output.path = "../../out/L19"; if ~isfolder(L19.output.path); mkdir(L19.output.path); end
    L19.zone = L19.input.file.contents.sorted(:,1) + 1;
    L19.eiso = L19.input.file.contents.sorted(:,3)*1.e52;
    L19.logZone = log(L19.zone);
    L19.logEiso = log(L19.eiso);

    L19.estat = EfronStat   ( L19.logZone ... logx
                            , L19.logEiso ... logy
                            , L19.thresh.logVal ... observerLogThresh
                            , "fluence" ... threshType
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
    L19.thresh.logEiso = L19.thresh.logVal + getLogEisoLumDisTerm(L19.thresh.zone);
    L19.thresh.eiso = exp(L19.thresh.logEiso);
    figure("color", figureColor); hold on; box on;
    plot( L19.zone ...
        , L19.eiso ...
        , "." ...
        , "markersize", 15 ...
        , "linewidth", lineWidth ...
        );
    plot( L19.thresh.zone ...
        , L19.thresh.eiso ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    hold off;
    return
    %}
    for i = 1:L19.thresh.logRangeLen
        L19.estatList{i} = EfronStat( L19.logZone ... logx
                                    , L19.logEiso ... logy
                                    , L19.thresh.logRange(i) ... observerLogThresh
                                    , "fluence" ... threshType
                                    );
    end

    save(L19.output.path + "/L19.mat","L19");

else
    
    L19.output.path = "../../out/L19";
    load(L19.output.path + "/L19.mat"); % loads L19 object
    
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
    yline(0,"linewidth", 2, "linestyle", "--", "color", [0, 0.4470, 0.7410]);
    scatter(L19.thresh.val,L19.estat.logxMax.tau,100,'black')
    scatter(1.1e-6, 0, 100, [0, 0.4470, 0.7410]);
    annotation('textarrow',[.48,.53],[.75,.75],'String','L19 detection threshold','fontsize',11);
    annotation('textarrow',[.48,.53],[.25,.25],'String','\tau = -6.15','fontsize',11);
    annotation('textarrow',[.755,.725],[.33,.415],'String','flux = 1.1 \times 10^{-6}','interpreter', 'tex','fontsize',11);
    xlabel("Detection Threshold Fluence [ ergs / cm^2 ]", "interpreter", "tex", "fontsize", fontSize);
    ylabel("Efron-Petrosian Tau Statistic \tau at \alpha = 0", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'linear', "color", figureColor);
    export_fig(L19.output.path + "/L19threshTau.png", "-m4 -transparent")
hold off;

% plot alpha (tau = 0) versus threshold

figure("color", figureColor); hold on; box on;
    plot( exp( L19.thresh.logRange ) ...
        , L19.alphaAtTauZero ...
        , "color", "red" ...
        , "linewidth", lineWidth ...
        );
    xline(L19.thresh.val,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    scatter(L19.thresh.val, L19.estat.logxMax.alpha.tau.zero, 100, 'black');
    annotation('textarrow',[.48,.53],[.4,.4],'String','L19 detection threshold','fontsize',11);
    annotation('textarrow',[.48,.53],[.72,.72],'String','\alpha = 1.34','fontsize',11);
    xlabel("Detection Threshold Fluence [ ergs / cm^2 ]", "interpreter", "tex", "fontsize", fontSize);
    ylabel("\alpha at Efron-Petrosian Tau Statistic \tau = 0", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'linear', "color", figureColor);
    export_fig(L19.output.path + "/L19threshAlpha.png", "-m4 -transparent")
hold off;

% plot the original bivariate data for zone-eiso

L19.thresh.logZoneLimits = [1,12];
L19.thresh.logZone = log(L19.thresh.logZoneLimits(1)):0.02:log(L19.thresh.logZoneLimits(2)); % the range of z+1 for which the detection threshold will be drawn.
L19.thresh.zone = exp(L19.thresh.logZone);
L19.thresh.logEiso = L19.thresh.logVal + getLogEisoLumDisTerm(L19.thresh.zone);
L19.thresh.eiso = exp(L19.thresh.logEiso);

L19.getZcorrection = @(logZone) L19.estat.logxMax.alpha.tau.zero * logZone;
L19.corrected.logEiso = L19.logEiso(:) - L19.getZcorrection( L19.logZone(:) );
L19.corrected.eiso = exp(L19.corrected.logEiso);
L19.corrected.thresh.logEiso = L19.thresh.logEiso(:) - L19.getZcorrection( L19.thresh.logZone(:) );
L19.corrected.thresh.eiso = exp(L19.corrected.thresh.logEiso);

% fit the data by keeping the slope constant

L19.regression.slope  = L19.estat.logxMax.alpha.tau.zero;
L19.regression.getLogEiso = @(intercept, logZone) intercept + L19.getZcorrection(logZone);
L19.getSumDistSq = @(intercept) sum( (L19.logEiso - L19.regression.getLogEiso(intercept,L19.logZone)).^2 );
L19.regression.intercept = fminsearch( L19.getSumDistSq , 120 );
L19.regression.logZone = min(L19.logZone):0.05:max(L19.logZone);
L19.regression.logEiso = L19.regression.getLogEiso(L19.regression.intercept, L19.regression.logZone);

% fit the detection threshold

L19.thresh.regression.pointIndices = [ length(L19.thresh.logZone) - 5 , length(L19.thresh.logZone) ];
L19.thresh.regression.logZoneLimits = [ L19.thresh.logZone(L19.thresh.regression.pointIndices(1)) , L19.thresh.logZone(L19.thresh.regression.pointIndices(2)) ];
L19.thresh.regression.logEisoLimits = [ L19.thresh.logEiso(L19.thresh.regression.pointIndices(1)) , L19.thresh.logEiso(L19.thresh.regression.pointIndices(2)) ];
L19.thresh.regression.slope = ( L19.thresh.regression.logEisoLimits(2) - L19.thresh.regression.logEisoLimits(1) ) ...
                            / ( L19.thresh.regression.logZoneLimits(2) - L19.thresh.regression.logZoneLimits(1) );

% plot zone-eiso

figure("color", figureColor); hold on; box on;
    plot( L19.zone ...
        , L19.eiso ...
        , "." ...
        , "markersize", 15 ...
        , "linewidth", lineWidth ...
        );
    plot( L19.thresh.zone ...
        , L19.thresh.eiso ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    plot( exp( L19.regression.logZone ) ...
        , exp( L19.regression.logEiso ) ...
        , "--" ...
        , "color", [1,0,1] ...
        , "linewidth", 1.5 * lineWidth ...
        );
    xlim(L19.thresh.logZoneLimits);
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    ylabel("E_{iso} [ ergs ]", "interpreter", "tex", "fontsize", fontSize);
    legend(["L19 sample", "L19 detection limit","Regression line slope = \alpha"], "interpreter", "tex", "location", "southeast", "fontSize", fontSize,'color',figureColor)
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    export_fig(L19.output.path + "/L19zoneEiso.png", "-m4 -transparent")
hold off;


% Now build the decorrelated data and plot the redshift-corrected bivariate data for zone-eiso


figure("color", figureColor); hold on; box on;
    plot( L19.zone ...
        , L19.corrected.eiso ...
        , "." ...
        , "markersize", 15 ...
        ..., "color", "black" ...
        , "linewidth", lineWidth ...
        );
    plot( L19.thresh.zone ...
        , L19.corrected.thresh.eiso ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    xlim(L19.thresh.logZoneLimits);
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    ylabel("E_{0} [ ergs ]", "interpreter", "tex", "fontsize", fontSize);
    legend(["L19 sample", "L19 detection limit"], "interpreter", "tex", "location", "southeast", "fontSize", fontSize,'color',figureColor)
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    export_fig(L19.output.path + "/L19zoneEisoCorrected.png", "-m4 -transparent")
hold off;

figure("color", figureColor); hold on; box on;
    h = histogram(L19.logZone,"binwidth",0.1);
    xlabel("log10( z + 1 )", "interpreter", "tex", "fontSize", fontSize)
    ylabel("Count", "interpreter", "tex", "fontSize", fontSize)
    set(gca, "color", figureColor);
    export_fig(L19.output.path + "/L19histLogZone.png", "-m4 -transparent")
hold off;