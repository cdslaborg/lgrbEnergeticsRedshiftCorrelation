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
histogramTrialRun = false; % trial-run the histogram only. "freshRunEnabled" must be true.
saveNewImages = false; % export figure on or off

if freshRunEnabled

    y15 = struct();
    y15.thresh.val = 2.e-8; % original value
    %y15.thresh.val = 2.5e-7; % improved value
    y15.thresh.logVal = log(y15.thresh.val);

    y15.input.file.path = "../../in/Y15table1.xlsx";
    y15.input.file.contents = importdata(y15.input.file.path);
    y15.input.file.contents.sorted = sortrows(y15.input.file.contents.data,2);
    y15.output.path = "../../out/Y15"; if ~isfolder(y15.output.path); mkdir(y15.output.path); end
    y15.zone = y15.input.file.contents.sorted(:,2) + 1;
    y15.liso = y15.input.file.contents.sorted(:,4);
    y15.logZone = log(y15.zone);
    y15.logLiso = log(y15.liso);
    y15.logPbol = y15.logLiso - getLogLisoLumDisTerm(y15.zone);
    
    if histogramTrialRun
        % trial-run the histogram only
        figure("color", figureColor); hold on; box on;
            h = histogram(y15.logPbol/log(10),"binwidth",0.25);
            line([log(y15.thresh.val)/log(10),log(y15.thresh.val)/log(10)], [0, 30],'color','black','linewidth',2,'linestyle','--');
            xlabel("log_{10}( Flux [ ergs / s / cm^2 ] )", "interpreter", "tex", "fontSize", fontSize);
            ylabel("Count", "interpreter", "tex", "fontSize", fontSize);
            legend(["Y15 sample", "Y15 detection limit"], "interpreter", "tex", "fontSize", fontSize,'color',figureColor); 
        hold off;
        return
    end
    
    y15.estat = EfronStat   ( y15.logZone ... logx
                            , y15.logLiso ... logy
                            , y15.thresh.logVal ... observerLogThresh
                            , "flux" ... threshType
                            );

    %y15.logPbol = y15.estat.logyDistanceFromLogThresh + y15.thresh.logVal;
    
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
        , "linewidth", lineWidth ...
        );
    xline(y15.thresh.val,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    yline(0,"linewidth", 2, "linestyle", "--", "color", [0, 0.4470, 0.7410]);
    scatter(y15.thresh.val,y15.estat.logxMax.tau,100,'black');
    scatter(2.0e-7, 0, 100, [0, 0.4470, 0.7410]);
    annotation('textarrow',[.45,.4],[.85,.85],'String','Y15 detection threshold','fontsize',11);
    annotation('textarrow',[.45,.4],[.25,.25],'String','\tau = -5.18','fontsize',11);
    %annotation('textarrow',[.52,.57],[.85,.85],'String','Y15 hypothetical threshold','fontsize',11);
    %annotation('textarrow',[.67,.62],[.53,.53],'String','\tau = 1.04','fontsize',11);
    annotation('textarrow',[.64,.59],[.41,.46],'String','flux = 2.0 \times 10^{-7}','interpreter', 'tex','fontsize',11);
    xlabel("Detection Threshold Flux [ ergs / s / cm^2 ]", "interpreter", "tex", "fontsize", fontSize);
    ylabel("Efron-Petrosian Tau Statistic \tau at \alpha = 0", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'linear', "color", figureColor);
    if saveNewImages
        export_fig(y15.output.path + "/Y15threshTau.png", "-m4 -transparent");
    end
hold off;

% plot alpha (tau = 0) versus threshold

figure("color", figureColor); hold on; box on;
    plot( exp( y15.thresh.logRange ) ...
        , y15.alphaAtTauZero ...
        , "color", "red" ...
        , "linewidth", lineWidth ...
        );
    xline(y15.thresh.val,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    scatter(y15.thresh.val, y15.estat.logxMax.alpha.tau.zero, 100, 'black');
    annotation('textarrow',[.45,.4],[.85,.85],'String','Y15 detection threshold','fontsize',11);
    annotation('textarrow',[.45,.4],[.775,.775],'String','\alpha = 2.04','fontsize',11);
    %annotation('textarrow',[.52,.57],[.885,.885],'String','Y15 hypothetical threshold','fontsize',11);
    %annotation('textarrow',[.67,.62],[.397,.397],'String','\alpha = -0.30','fontsize',11);
    %yline(y15.estat.logxMax.alpha.tau.posOne,"linewidth", 2, "linestyle", "--", "color", [1,0,1]);
    %yline(y15.estat.logxMax.alpha.tau.negOne,"linewidth", 2, "linestyle", "--", "color", [1,0,1]);
    xlabel("Detection Threshold Flux [ ergs / s / cm^2 ]", "interpreter", "tex", "fontsize", fontSize);
    ylabel("\alpha at Efron-Petrosian Tau Statistic \tau = 0", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'linear', "color", figureColor);
    if saveNewImages
        export_fig(y15.output.path + "/Y15threshAlpha.png", "-m4 -transparent");
    end
hold off;


% plot the original bivariate data for zone-liso


y15.thresh.logZoneLimits = [1,12];
y15.thresh.logZone = log(y15.thresh.logZoneLimits(1)):0.02:log(y15.thresh.logZoneLimits(2)); % the range of z+1 for which the detection threshold will be drawn.
y15.thresh.zone = exp(y15.thresh.logZone);
y15.thresh.logLiso = y15.thresh.logVal + getLogLisoLumDisTerm(y15.thresh.zone);
y15.thresh.liso = exp(y15.thresh.logLiso);

y15.getZcorrection = @(logZone) y15.estat.logxMax.alpha.tau.zero * logZone;
y15.corrected.logLiso = y15.logLiso(:) - y15.getZcorrection( y15.logZone(:) );
y15.corrected.liso = exp(y15.corrected.logLiso);
y15.corrected.thresh.logLiso = y15.thresh.logLiso(:) - y15.getZcorrection( y15.thresh.logZone(:) );
y15.corrected.thresh.liso = exp(y15.corrected.thresh.logLiso);

% fit the data by keeping the slope constant

y15.regression.slope  = y15.estat.logxMax.alpha.tau.zero;
y15.regression.getLogLiso = @(intercept, logZone) intercept + y15.getZcorrection(logZone);
y15.getSumDistSq = @(intercept) sum( (y15.logLiso - y15.regression.getLogLiso(intercept,y15.logZone)).^2 );
y15.regression.intercept = fminsearch( y15.getSumDistSq , 120 );
y15.regression.logZone = min(y15.logZone):0.05:max(y15.logZone);
y15.regression.logLiso = y15.regression.getLogLiso(y15.regression.intercept, y15.regression.logZone);

% fit the detection threshold

y15.thresh.regression.pointIndices = [ length(y15.thresh.logZone) - 5 , length(y15.thresh.logZone) ];
y15.thresh.regression.logZoneLimits = [ y15.thresh.logZone(y15.thresh.regression.pointIndices(1)) , y15.thresh.logZone(y15.thresh.regression.pointIndices(2)) ];
y15.thresh.regression.logLisoLimits = [ y15.thresh.logLiso(y15.thresh.regression.pointIndices(1)) , y15.thresh.logLiso(y15.thresh.regression.pointIndices(2)) ];
y15.thresh.regression.slope = ( y15.thresh.regression.logLisoLimits(2) - y15.thresh.regression.logLisoLimits(1) ) ...
                            / ( y15.thresh.regression.logZoneLimits(2) - y15.thresh.regression.logZoneLimits(1) );

% plot zone-liso

figure("color", figureColor); hold on; box on;
    plot( y15.zone ...
        , y15.liso ...
        , "." ...
        , "markersize", 15 ...
        , "linewidth", lineWidth ...
        );
    plot( y15.thresh.zone ...
        , y15.thresh.liso ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    plot( exp( y15.regression.logZone ) ...
        , exp( y15.regression.logLiso ) ...
        , "--" ...
        , "color", [1,0,1] ...
        , "linewidth", 1.5 * lineWidth ...
        );
    line([y15.thresh.logZoneLimits(1),4.86],[2.9e+51,2.9e+51],'color','black','linewidth',1,'linestyle','--')
    line([4.86,4.86],[2.9e+51,1.e56],'color','black','linewidth',1,'linestyle','--')
    scatter(2.77,2.9e51,75,'black')
    text(2,1.e55,'N_{i}','fontsize',13);
    annotation('textarrow',[.5,.453],[.45,.545],'String','point i','fontsize',12);
    xlim(y15.thresh.logZoneLimits);
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    ylabel("L_{iso} [ ergs / s ]", "interpreter", "tex", "fontsize", fontSize);
    legend(["Y15 sample", "Y15 detection limit","Regression line slope = \alpha"], "interpreter", "tex", "location", "southeast", "fontSize", fontSize,'color',figureColor)
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    if saveNewImages
        export_fig(y15.output.path + "/Y15zoneLiso.png", "-m4 -transparent");
    end
hold off;

% Now build the decorrelated data and plot the redshift-corrected bivariate data for zone-liso

figure("color", figureColor); hold on; box on;
    plot( y15.zone ...
        , y15.corrected.liso ...
        , "." ...
        , "markersize", 15 ...
        ..., "color", "black" ...
        , "linewidth", lineWidth ...
        );
    plot( y15.thresh.zone ...
        , y15.corrected.thresh.liso ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    xlim(y15.thresh.logZoneLimits);
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    ylabel("L_{0} [ ergs / s ]", "interpreter", "tex", "fontsize", fontSize);
    legend(["Y15 sample", "Y15 detection limit"], "interpreter", "tex", "location", "southeast", "fontSize", fontSize,'color',figureColor)
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    if saveNewImages
        export_fig(y15.output.path + "/Y15zoneLisoCorrected.png", "-m4 -transparent");
    end
hold off;

% Plot the data set zone-Pbol

figure("color", figureColor); hold on; box on;
    plot( y15.zone ...
        , exp(y15.logPbol) ...
        , "." ...
        ,"markersize", 15 ...
        , "linewidth", lineWidth ...
        );
    line([y15.thresh.logZoneLimits(1),y15.thresh.logZoneLimits(2)],[y15.thresh.val,y15.thresh.val],'color','black','linewidth',1,'linestyle','--');
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    ylabel("Flux [ ergs / s / cm^2]", "interpreter", "tex", "fontsize", fontSize);
    legend(["Y15 sample", "Y15 detection limit"], "interpreter", "tex", "location", "northeast", "fontSize", fontSize,'color',figureColor);
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    if saveNewImages
        export_fig(y15.output.path + "/Y15zoneSbol_new.png", "-m4 -transparent");
    end
hold off;

% Plot a histogram of Pbol

figure("color", figureColor); hold on; box on;
    h = histogram(y15.logPbol/log(10),"binwidth",0.25);
    line([log(y15.thresh.val)/log(10),log(y15.thresh.val)/log(10)], [0, 30],'color','black','linewidth',2,'linestyle','--');
    xlabel("log_{10}( Flux [ ergs / s / cm^2 ] )", "interpreter", "tex", "fontSize", fontSize);
    ylabel("Count", "interpreter", "tex", "fontSize", fontSize);
    legend(["Y15 sample", "Y15 detection limit"], "interpreter", "tex", "fontSize", fontSize,'color',figureColor);
    if saveNewImages
        export_fig(y15.output.path + "/Y15histSbol_new.png", "-m4 -transparent");
    end
hold off;

% Plot a histogram of zone
%{
figure("color", figureColor); hold on; box on;
    h = histogram(y15.logZone,"binwidth",0.1);
    xlabel("log10( z + 1 )", "interpreter", "tex", "fontSize", fontSize)
    ylabel("Count", "interpreter", "tex", "fontSize", fontSize)
    set(gca, "color", figureColor);
    if saveNewImages
        export_fig(y15.output.path + "/Y15histLogZone.png", "-m4
        -transparent");
    end
hold off;
%}