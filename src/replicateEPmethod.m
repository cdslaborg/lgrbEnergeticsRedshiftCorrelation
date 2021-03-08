clear all;
close all;
filePath = mfilename('fullpath');
[currentDir,fileName,fileExt] = fileparts(filePath); cd(currentDir);
cd(fileparts(mfilename('fullpath'))); % Change working directory to source code directory.
%addpath(genpath("../../../libmatlab"),"-begin");

% Figure Parameters
fontSize = 13;
lineWidth = 1.5;
figureColor = "white";

% Simulation Options
freshRunEnabled = false; % this must be set to true for first ever simulation. Thereafter, it can be set to false to save time.
histogramTrialRun = false; % trial-run the histogram only. "freshRunEnabled" must be true.
saveNewImages = false; % export figure on or off
logxMaxAlphaSearchStart = 2; % Starting alpha value for search. DO NOT set to zero. "freshRunEnabled" must be true. 2 is default. -0.5 for L19 Liso.

% Dataset Choice
dataset = "Y15"; % choose between "Y15", "P16", "T17", and "L19"
convertEisoToLiso = false; % FOR L19 ONLY to convert Eiso values to Liso via their equation

if freshRunEnabled
    sim = struct();
    if strcmpi(dataset,"Y15")
        sim.type = "flux";
        sim.thresh.val = 2.e-8; % value in sim paper
        sim.thresh.logVal = log(sim.thresh.val);
        sim.input.file.path = "../in/Y15table1.xlsx";
        sim.input.file.contents = importdata(sim.input.file.path);
        sim.output.path = "../out/" + dataset; if ~isfolder(sim.output.path); mkdir(sim.output.path); end
        sim.zone = sim.input.file.contents.data(:,2) + 1;
        sim.lisoEiso = sim.input.file.contents.data(:,4);
        sim.logZone = log(sim.zone);
        sim.logLisoEiso = log(sim.lisoEiso);
        sim.logPbolSbol = sim.logLisoEiso - getLogLisoLumDisTerm(sim.zone);
    elseif strcmpi(dataset,"P16")
        sim.type = "flux";
        sim.thresh.val = 1.e-07;
        %sim.thresh.val = 2.0704e-07; % for Ep = 140
        %sim.thresh.val = 2.2878e-07; % for Ep = 362
        %sim.thresh.val = 2.3433e-07; % for Ep = 574
        sim.thresh.logVal = log(sim.thresh.val);
        sim.input.file.path = "../in/P16tableB1.xlsx";
        sim.input.file.contents = importdata(sim.input.file.path);
        sim.output.path = "../out/" + dataset; if ~isfolder(sim.output.path); mkdir(sim.output.path); end
        sim.zone = sim.input.file.contents.data(:,2) + 1;
        sim.lisoEiso = sim.input.file.contents.data(:,4);
        sim.logZone = log(sim.zone);
        sim.logLisoEiso = log(sim.lisoEiso);
        sim.logPbolSbol = sim.logLisoEiso - getLogLisoLumDisTerm(sim.zone);
    elseif strcmpi(dataset,"T17")
        sim.type = "flux";
        %sim.thresh.val = 2e-6; % value in P16 paper
        %sim.thresh.val = 1.1e-6; % value to match P16 graph visually
        sim.thresh.val = 8.6e-07; % for \alpha = 1.7
        sim.thresh.logVal = log(sim.thresh.val);
        sim.input.file.path = "../in/T17table4_3.txt";
        sim.input.file.contents = importdata(sim.input.file.path,' ',47);
        sim.output.path = "../out/" + dataset; if ~isfolder(sim.output.path); mkdir(sim.output.path); end
        sim.zone = sim.input.file.contents.data(:,1) + 1;
        sim.lisoEiso = sim.input.file.contents.data(:,20)*1.e51;
        sim.logZone = log(sim.zone);
        sim.logLisoEiso = log(sim.lisoEiso);
        sim.logPbolSbol = sim.logLisoEiso - getLogLisoLumDisTerm(sim.zone);
    elseif strcmpi(dataset,"L19")
        if ~convertEisoToLiso
            sim.type = "fluence";
            %sim.thresh.val = 2e-6; % value in L19 paper
            %sim.thresh.val = 7e-10; % value to get \alpha = 2.30
            sim.thresh.val = 1.6e-7; % value to match T17 graph visually
            sim.thresh.logVal = log(sim.thresh.val);
            sim.input.file.path = "../in/L19figure1.xlsx";
            sim.input.file.contents = importdata(sim.input.file.path);
            sim.output.path = "../out/" + dataset; if ~isfolder(sim.output.path); mkdir(sim.output.path); end
            sim.zone = sim.input.file.contents.data(:,1) + 1;
            sim.lisoEiso = sim.input.file.contents.data(:,3)*1.e52;
            sim.logZone = log(sim.zone);
            sim.logLisoEiso = log(sim.lisoEiso);
            sim.logPbolSbol = sim.logLisoEiso - getLogEisoLumDisTerm(sim.zone);
        elseif convertEisoToLiso
            sim.type = "flux";
            %sim.thresh.val = 7.e-7; % value in paper
            sim.thresh.val = 2.e-9; % visual match of L19 Liso graph
            sim.thresh.logVal = log(sim.thresh.val);
            sim.input.file.path = "../in/L19figure1.xlsx";
            sim.input.file.contents = importdata(sim.input.file.path);
            sim.output.path = "../out/" + dataset; if ~isfolder(sim.output.path); mkdir(sim.output.path); end
            sim.zone = sim.input.file.contents.data(:,1) + 1;
            sim.lisoEiso = 1.e52*sim.input.file.contents.data(:,3).*sim.zone./sim.input.file.contents.data(:,2);
            sim.logZone = log(sim.zone);
            sim.logLisoEiso = log(sim.lisoEiso);
            sim.logPbolSbol = sim.logLisoEiso - getLogLisoLumDisTerm(sim.zone);
        else
            error("convertEisoToLiso must be 'true' or 'false'");
        end
    else
        error("Dataset must be Y15, P16, T17, or L19");
    end
    
    % trial-run the histogram only
    if histogramTrialRun
        figure("color", figureColor); hold on; box on;
            h = histogram(sim.logPbolSbol/log(10),"binwidth",0.25);
            line([log(sim.thresh.val)/log(10),log(sim.thresh.val)/log(10)], [0, ceil(max(h.Values)/10)*10],'color','black','linewidth',2,'linestyle','--');
            xlim([floor(min(sim.thresh.logVal,min(sim.logPbolSbol))/log(10)-0.5),ceil(max(sim.thresh.logVal,max(sim.logPbolSbol))/log(10)+0.5)]);
            if strcmpi(sim.type,"flux")
                xlabel("log_{10}( Flux [ ergs / s / cm^2 ] )", "interpreter", "tex", "fontSize", fontSize);     
            elseif strcmpi(sim.type,"fluence")
                xlabel("log_{10}( Fluence [ ergs / cm^2 ] )", "interpreter", "tex", "fontSize", fontSize);
            else
                error("sim.type must be 'flux' or 'fluence'");
            end
            ylabel("Count", "interpreter", "tex", "fontSize", fontSize);
            legend([dataset + " sample", dataset + " detection limit"], "interpreter", "tex", "fontSize", fontSize,'color',figureColor); 
        hold off;
        return
    end
    
    sim.estat = EfronStat   ( sim.logZone ... logx
                            , sim.logLisoEiso ... logy
                            , sim.thresh.logVal ... observerLogThresh
                            , sim.type ... threshType
                            , logxMaxAlphaSearchStart ...
                            );
    sim.thresh.logMin = log(1.e-9);
    sim.thresh.logMax = log(1.e-5);
    sim.thresh.logRange = sim.thresh.logMin:0.2:sim.thresh.logMax;
    sim.thresh.logRangeLen = length(sim.thresh.logRange);
    sim.estatList = cell(sim.thresh.logRangeLen,1);
    for i = 1:sim.thresh.logRangeLen
        sim.estatList{i} = EfronStat( sim.logZone ... logx
                                    , sim.logLisoEiso ... logy
                                    , sim.thresh.logRange(i) ... observerLogThresh
                                    , sim.type ... threshType
                                    , logxMaxAlphaSearchStart ...
                                    );
    end
    if ~strcmpi(dataset,"L19")
        save(sim.output.path + "/" + dataset + ".mat","sim");
    elseif strcmpi(dataset,"L19") && ~convertEisoToLiso
        save(sim.output.path + "/" + dataset + ".mat","sim");
    elseif strcmpi(dataset,"L19") && convertEisoToLiso
        save(sim.output.path + "/" + dataset + "Liso.mat","sim");
    end
else
    sim.output.path = "../out/" + dataset;
    if ~strcmpi(dataset,"L19")
        load(sim.output.path + "/" + dataset + ".mat"); % loads object
    elseif strcmpi(dataset,"L19") && ~convertEisoToLiso
        load(sim.output.path + "/" + dataset + ".mat"); % loads object
    elseif strcmpi(dataset,"L19") && convertEisoToLiso
        load(sim.output.path + "/" + dataset + "Liso.mat"); % loads object
    else
        error("convertEisoToLiso must be 'true' or 'false'");
    end
end

% plot tau (alpha = 0) versus threshold

sim.tauAtAlphaZero = zeros(sim.thresh.logRangeLen,1);
sim.alphaAtTauZero = zeros(sim.thresh.logRangeLen,1);
sim.alphaAtTauPosOne = zeros(sim.thresh.logRangeLen,1);
sim.alphaAtTauNegOne = zeros(sim.thresh.logRangeLen,1);
for i = 1:sim.thresh.logRangeLen
    sim.tauAtAlphaZero(i) = sim.estatList{i}.logxMax.tau;
    sim.alphaAtTauZero(i) = sim.estatList{i}.logxMax.alpha.tau.zero;
    sim.alphaAtTauPosOne(i) = sim.estatList{i}.logxMax.alpha.tau.posOne;
    sim.alphaAtTauNegOne(i) = sim.estatList{i}.logxMax.alpha.tau.negOne;
end

figure("color", figureColor); hold on; box on;
    plot( exp( sim.thresh.logRange ) ...
        , sim.tauAtAlphaZero ...
        , "color", "red" ...
        , "linewidth", lineWidth ...
        );
    xline(sim.thresh.val,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    yline(0,"linewidth", 2, "linestyle", "--", "color", [0, 0.4470, 0.7410]);
    scatter(sim.thresh.val,sim.estat.logxMax.tau,100,'black');
    if strcmpi(dataset,"Y15")
        scatter(2.0e-7, 0, 100, [0, 0.4470, 0.7410]);
        annotation('textarrow',[.45,.4],[.85,.85],'String','Y15 detection threshold','fontsize',11);
        annotation('textarrow',[.45,.4],[.25,.25],'String','\tau = -5.18','fontsize',11);
        %annotation('textarrow',[.52,.57],[.85,.85],'String','sim hypothetical threshold','fontsize',11);
        %annotation('textarrow',[.67,.62],[.53,.53],'String','\tau = 1.04','fontsize',11);
        annotation('textarrow',[.64,.59],[.41,.46],'String','flux = 2.0 \times 10^{-7}','interpreter', 'tex','fontsize',11);
    elseif strcmpi(dataset,"P16")
        scatter(3.94e-7, 0, 100, [0, 0.4470, 0.7410]);
        annotation('textarrow',[.45,.5],[.75,.75],'String','P16 detection threshold','fontsize',11);
        annotation('textarrow',[.45,.5],[.315,.315],'String','\tau = -4.69','fontsize',11);
        annotation('textarrow',[.68,.64],[.475,.555],'String','flux = 3.94 \times 10^{-7}','interpreter', 'tex','fontsize',11);
    elseif strcmpi(dataset,"T17")
        scatter(2.12e-6, 0, 100, [0, 0.4470, 0.7410]);
        annotation('textarrow',[.63,.68],[.75,.75],'String','T17 detection threshold','fontsize',11);
        annotation('textarrow',[.63,.68],[.32,.32],'String','\tau = -5.11','fontsize',11);
        annotation('textarrow',[.65,.75],[.45,.51],'String','flux = 2.12 \times 10^{-6}','interpreter', 'tex','fontsize',11);
    elseif strcmpi(dataset,"L19") && ~convertEisoToLiso
        scatter(1.04e-6, 0, 100, [0, 0.4470, 0.7410]);
        annotation('textarrow',[.48,.53],[.75,.75],'String','L19 detection threshold','fontsize',11);
        annotation('textarrow',[.48,.53],[.255,.255],'String','\tau = -6.01','fontsize',11);
        annotation('textarrow',[.755,.725],[.33,.415],'String','flux = 1.04 \times 10^{-6}','interpreter', 'tex','fontsize',11);
    elseif strcmpi(dataset,"L19") && convertEisoToLiso
    else
        error("Dataset must be Y15, P16, T17, or L19 for tau (alpha = 0) vs threshold");
    end
    if strcmpi(sim.type,"flux")
        xlabel("Detection Threshold Flux [ ergs / s / cm^2 ]", "interpreter", "tex", "fontsize", fontSize);
    elseif strcmpi(sim.type,"fluence")
        xlabel("Detection Threshold Fluence [ ergs / cm^2 ]", "interpreter", "tex", "fontsize", fontSize);
    else
        error("sim.type must be 'flux' or 'fluence'");
    end
    ylabel("Efron-Petrosian Tau Statistic \tau at \alpha = 0", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'linear', "color", figureColor);
    if saveNewImages
        if ~strcmpi(dataset,"L19")
            export_fig(sim.output.path + "/" + dataset + "threshTau.png", "-m4 -transparent");
        elseif strcmpi(dataset,"L19") && ~convertEisoToLiso
            export_fig(sim.output.path + "/" + dataset + "threshTau.png", "-m4 -transparent");
        elseif strcmpi(dataset,"L19") && convertEisoToLiso
            export_fig(sim.output.path + "/" + dataset + "threshTauLiso.png", "-m4 -transparent");
        end
    end
hold off;

% plot alpha (tau = 0) versus threshold

figure("color", figureColor); hold on; box on;
    plot( exp( sim.thresh.logRange ) ...
        , sim.alphaAtTauZero ...
        , "color", "red" ...
        , "linewidth", lineWidth ...
        );
    xline(sim.thresh.val,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
    scatter(sim.thresh.val, sim.estat.logxMax.alpha.tau.zero, 100, 'black');
    if strcmpi(dataset,"Y15")
        annotation('textarrow',[.45,.4],[.85,.85],'String','Y15 detection threshold','fontsize',11);
        annotation('textarrow',[.45,.4],[.775,.775],'String','\alpha = 2.04','fontsize',11);
        %annotation('textarrow',[.52,.57],[.885,.885],'String','Y15 hypothetical threshold','fontsize',11);
        %annotation('textarrow',[.67,.62],[.397,.397],'String','\alpha = -0.30','fontsize',11);
        %yline(sim.estat.logxMax.alpha.tau.posOne,"linewidth", 2, "linestyle", "--", "color", [1,0,1]);
        %yline(sim.estat.logxMax.alpha.tau.negOne,"linewidth", 2, "linestyle", "--", "color", [1,0,1]);
    elseif strcmpi(dataset,"P16")
        annotation('textarrow',[.59,.54],[.85,.85],'String','P16 detection threshold','fontsize',11);
        annotation('textarrow',[.59,.54],[.705,.705],'String','\alpha = 2.35','fontsize',11);
    elseif strcmpi(dataset,"T17")
        annotation('textarrow',[.625,.675],[.4,.4],'String','T17 detection threshold','fontsize',11);
        annotation('textarrow',[.625,.675],[.605,.605],'String','\alpha = 1.60','fontsize',11);
    elseif strcmpi(dataset,"L19") && ~convertEisoToLiso
        annotation('textarrow',[.48,.53],[.4,.4],'String','L19 detection threshold','fontsize',11);
        annotation('textarrow',[.48,.53],[.715,.715],'String','\alpha = 1.31','fontsize',11);
    end
    if strcmpi(sim.type,"flux")
        xlabel("Detection Threshold Flux [ ergs / s / cm^2 ]", "interpreter", "tex", "fontsize", fontSize);
    elseif strcmpi(sim.type,"fluence")
        xlabel("Detection Threshold Fluence [ ergs / cm^2 ]", "interpreter", "tex", "fontsize", fontSize);
    else
        error("Dataset must be Y15, P16, T17, or L19 for alpha (tau = 0) vs threshold");
    end
    ylabel("\alpha at Efron-Petrosian Tau Statistic \tau = 0", "interpreter", "tex", "fontsize", fontSize);
    set(gca, 'xscale', 'log', 'yscale', 'linear', "color", figureColor);
    if saveNewImages
        if ~strcmpi(dataset,"L19")
            export_fig(sim.output.path + "/" + dataset + "threshAlpha.png", "-m4 -transparent");
        elseif strcmpi(dataset,"L19") && ~convertEisoToLiso
            export_fig(sim.output.path + "/" + dataset + "threshAlpha.png", "-m4 -transparent");
        elseif strcmpi(dataset,"L19") && convertEisoToLiso
            export_fig(sim.output.path + "/" + dataset + "threshAlphaLiso.png", "-m4 -transparent");
        end
    end
hold off;

% plot the original bivariate data for zone-lisoEiso

sim.thresh.logZoneLimits = [1,12];
sim.thresh.logZone = log(sim.thresh.logZoneLimits(1)):0.02:log(sim.thresh.logZoneLimits(2)); % the range of z+1 for which the detection threshold will be drawn.
sim.thresh.zone = exp(sim.thresh.logZone);
if strcmpi(sim.type,"flux")
    sim.thresh.logLisoEiso = sim.thresh.logVal + getLogLisoLumDisTerm(sim.thresh.zone);
elseif strcmpi(sim.type,"fluence")
    sim.thresh.logLisoEiso = sim.thresh.logVal + getLogEisoLumDisTerm(sim.thresh.zone);
end
sim.thresh.lisoEiso = exp(sim.thresh.logLisoEiso);

% fit the data by keeping the slope constant

sim.getZcorrection = @(logZone) sim.estat.logxMax.alpha.tau.zero * logZone;
sim.regression.slope  = sim.estat.logxMax.alpha.tau.zero;
sim.regression.getLogLisoEiso = @(intercept, logZone) intercept + sim.getZcorrection(logZone);
sim.getSumDistSq = @(intercept) sum( (sim.logLisoEiso - sim.regression.getLogLisoEiso(intercept,sim.logZone)).^2 );
sim.regression.intercept = fminsearch( sim.getSumDistSq , 120 );
sim.regression.logZone = min(sim.logZone):0.05:max(sim.logZone);
sim.regression.logLisoEiso = sim.regression.getLogLisoEiso(sim.regression.intercept, sim.regression.logZone);

% fit the detection threshold

sim.thresh.regression.pointIndices = [ length(sim.thresh.logZone) - 5 , length(sim.thresh.logZone) ];
sim.thresh.regression.logZoneLimits = [ sim.thresh.logZone(sim.thresh.regression.pointIndices(1)) , sim.thresh.logZone(sim.thresh.regression.pointIndices(2)) ];
sim.thresh.regression.logLisoEisoLimits = [ sim.thresh.logLisoEiso(sim.thresh.regression.pointIndices(1)) , sim.thresh.logLisoEiso(sim.thresh.regression.pointIndices(2)) ];
sim.thresh.regression.slope = ( sim.thresh.regression.logLisoEisoLimits(2) - sim.thresh.regression.logLisoEisoLimits(1) ) ...
                            / ( sim.thresh.regression.logZoneLimits(2) - sim.thresh.regression.logZoneLimits(1) );

figure("color", figureColor); hold on; box on;
    plot( sim.zone ...
        , sim.lisoEiso ...
        , "." ...
        , "markersize", 15 ...
        , "linewidth", lineWidth ...
        );
    plot( sim.thresh.zone ...
        , sim.thresh.lisoEiso ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    plot( exp( sim.regression.logZone ) ...
        , exp( sim.regression.logLisoEiso ) ...
        , "--" ...
        , "color", [1,0,1] ...
        , "linewidth", 1.5 * lineWidth ...
        );
    if strcmpi(dataset,"Y15")
        line([sim.thresh.logZoneLimits(1),4.86],[2.9e+51,2.9e+51],'color','black','linewidth',1,'linestyle','--')
        line([4.86,4.86],[2.9e+51,1.e56],'color','black','linewidth',1,'linestyle','--')
        scatter(2.77,2.9e51,75,'black')
        text(2,1.e55,'N_{i}','fontsize',13);
        annotation('textarrow',[.5,.453],[.45,.545],'String','point i','fontsize',12);
    end
    xlim(sim.thresh.logZoneLimits);
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    if strcmpi(sim.type,"flux")
        ylabel("L_{iso} [ ergs / s ]", "interpreter", "tex", "fontsize", fontSize);
    elseif strcmpi(sim.type,"fluence")
        ylabel("E_{iso} [ ergs ]", "interpreter", "tex", "fontsize", fontSize);
    end
    legend([dataset + " sample", dataset + " detection limit","Regression line slope = \alpha"], "interpreter", "tex", "location", "southeast", "fontSize", fontSize,'color',figureColor)
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    if saveNewImages
        if strcmpi(sim.type,"flux")
            export_fig(sim.output.path + "/" + dataset + "zoneLiso.png", "-m4 -transparent");
        elseif strcmpi(sim.type,"fluence")
            export_fig(sim.output.path + "/" + dataset + "zoneEiso.png", "-m4 -transparent");
        end
    end
hold off;

% Now build the decorrelated data and plot the redshift-corrected bivariate data for zone-lisoEiso

sim.corrected.logLisoEiso = sim.logLisoEiso(:) - sim.getZcorrection( sim.logZone(:) );
sim.corrected.lisoEiso = exp(sim.corrected.logLisoEiso);
sim.corrected.thresh.logLisoEiso = sim.thresh.logLisoEiso(:) - sim.getZcorrection( sim.thresh.logZone(:) );
sim.corrected.thresh.lisoEiso = exp(sim.corrected.thresh.logLisoEiso);

figure("color", figureColor); hold on; box on;
    plot( sim.zone ...
        , sim.corrected.lisoEiso ...
        , "." ...
        , "markersize", 15 ...
        ..., "color", "black" ...
        , "linewidth", lineWidth ...
        );
    plot( sim.thresh.zone ...
        , sim.corrected.thresh.lisoEiso ...
        , "color", "black" ...
        , "linewidth", lineWidth ...
        );
    xlim(sim.thresh.logZoneLimits);
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    if strcmpi(sim.type,"flux")
        ylabel("L_{0} [ ergs / s ]", "interpreter", "tex", "fontsize", fontSize);
    elseif strcmpi(sim.type,"fluence")
        ylabel("E_{0} [ ergs ]", "interpreter", "tex", "fontsize", fontSize);
    end
    legend([dataset + " sample", dataset + " detection limit"], "interpreter", "tex", "location", "southeast", "fontSize", fontSize,'color',figureColor)
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    if saveNewImages
        if strcmpi(sim.type,"flux")
            export_fig(sim.output.path + "/" + dataset + "zoneLisoCorrected.png", "-m4 -transparent");
        elseif strcmpi(sim.type,"fluence")
            export_fig(sim.output.path + "/" + dataset + "zoneEisoCorrected.png", "-m4 -transparent");
        end
    end
hold off;

% Plot the data set zone-PbolSbol

figure("color", figureColor); hold on; box on;
    plot( sim.zone ...
        , exp(sim.logPbolSbol) ...
        , "." ...
        ,"markersize", 15 ...
        , "linewidth", lineWidth ...
        );
    line([sim.thresh.logZoneLimits(1),sim.thresh.logZoneLimits(2)],[sim.thresh.val,sim.thresh.val],'color','black','linewidth',1,'linestyle','--');
    xlabel("z + 1", "interpreter", "tex", "fontsize", fontSize);
    if strcmpi(sim.type,"flux")
        ylabel("Flux [ ergs / s / cm^2]", "interpreter", "tex", "fontsize", fontSize);
    elseif strcmpi(sim.type,"fluence")
        ylabel("Fluence [ ergs / cm^2]", "interpreter", "tex", "fontsize", fontSize);
    end
    ylim([exp(floor(min(sim.thresh.logVal,min(sim.logPbolSbol))-0.5)),exp(ceil(max(sim.thresh.logVal,max(sim.logPbolSbol))+0.5))]);
    legend([dataset + " sample", dataset + " detection limit"], "interpreter", "tex", "location", "northeast", "fontSize", fontSize,'color',figureColor);
    set(gca, 'xscale', 'log', 'yscale', 'log', "color", figureColor);
    if saveNewImages
        if strcmpi(sim.type,"flux")
            export_fig(sim.output.path + "/" + dataset + "zonePbol.png", "-m4 -transparent");
        elseif strcmpi(sim.type,"fluence")
            export_fig(sim.output.path + "/" + dataset + "zoneSbol.png", "-m4 -transparent");
        end
    end
hold off;

% Plot a histogram of PbolSbol

figure("color", figureColor); hold on; box on;
    h = histogram(sim.logPbolSbol/log(10),"binwidth",0.25);
    line([log(sim.thresh.val)/log(10),log(sim.thresh.val)/log(10)], [0, ceil(max(h.Values)/10)*10],'color','black','linewidth',2,'linestyle','--');
    xlim([floor(min(sim.thresh.logVal,min(sim.logPbolSbol))/log(10)-0.5),ceil(max(sim.thresh.logVal,max(sim.logPbolSbol))/log(10)+0.5)]);
    if strcmpi(sim.type,"flux")
        xlabel("log_{10}( Flux [ ergs / s / cm^2 ] )", "interpreter", "tex", "fontSize", fontSize);     
    elseif strcmpi(sim.type,"fluence")
        xlabel("log_{10}( Fluence [ ergs / cm^2 ] )", "interpreter", "tex", "fontSize", fontSize);
    else
        error("sim.type must be 'flux' or 'fluence'");
    end
    ylabel("Count", "interpreter", "tex", "fontSize", fontSize);
    legend([dataset + " sample", dataset + " detection limit"], "interpreter", "tex", "fontSize", fontSize,'color',figureColor); 
    if saveNewImages
        if strcmpi(sim.type,"flux")
            export_fig(sim.output.path + "/" + dataset + "histPbol.png", "-m4 -transparent");
        elseif strcmpi(sim.type,"fluence")
            export_fig(sim.output.path + "/" + dataset + "histSbol.png", "-m4 -transparent");
        end
    end
hold off;