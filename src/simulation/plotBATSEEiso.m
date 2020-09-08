%clear all;
close all;
format compact; format long;
filePath = mfilename('fullpath');
[currentDir,fileName,fileExt] = fileparts(filePath); cd(currentDir);
cd(fileparts(mfilename('fullpath'))); % Change working directory to source code directory.
addpath(genpath("..\..\..\..\libmatlab\astro"),"-begin");
addpath(genpath("..\..\..\..\libmatlab"),"-begin");
addpath(genpath("..\"),"-begin");
addpath(genpath("..\chris\"),"-begin");

fileType = ".png";
outPath = "../../out/simulation/";
figExportSynHistogram = 0;
%figExportAlphaTau = 0;
figExportAlphaDetector = 0;
figExportTauDetector = 0;
figExportRegressionScatter = 0;
figExportDecorrelatedRedshiftData = 0;
figExportSynScatterPlots = 0; % if there is a regression line we can't export a figure that doesnt have regression line
regressionRequested = 1; % make a regression line on the scatter plots
figColor = 'white';
figVisibility = 'on';
dryRunEiso = false;

fontSize = 13;
skip = 100;
global alpha; alpha = 0.0;

rangeX = [1.e0, 3.6e1]; % redshift+1
rangeY = [1.e46, 3.e56]; % log10Eiso
b10 = importdata("..\..\..\..\20181213_BatseLgrbRedshift\git\___SyntheticSample___\winx64\intel\release\static\serial\bin\out\kfacOneThird\syntheticSampleB10.csv");
detProbIndex = 10;
sbolAtHalfDetectionProb = exp( mean( b10.data( b10.data(:,detProbIndex)>0.48 & b10.data(:,detProbIndex)<0.52 , 7) ) );
sbolAtTenDetectionProb = exp( mean( b10.data( b10.data(:,detProbIndex)>0.08 & b10.data(:,detProbIndex)<0.12 , 7) ) );
sbolAtNinetyDetectionProb = exp( mean( b10.data( b10.data(:,detProbIndex)>0.88 & b10.data(:,detProbIndex)<0.92 , 7) ) );
%Mask = b10.data(1:1:end,detProbIndex) > 0.5;
Mask = b10.data(1:1:end,detProbIndex) > unifrnd(0,1,length(b10.data(1:1:end,detProbIndex)),1);
DataX = b10.data(Mask,9) + 1; DataX = DataX(1:skip:end);
DataY = exp( b10.data(Mask,3) ); DataY = DataY(1:skip:end);
detectionProb = b10.data(Mask,detProbIndex); detectionProb = detectionProb(1:skip:end);
logDataX = log(DataX); %redshift
logDataY = log(DataY); %Eiso
ndata = length(DataX);
ndataString = string(ndata);


zoneLim = [0.8, 20];
zoneGrid = 1.001:0.001:zoneLim(2);
logZoneGrid = log(zoneGrid);

    
EisoDetection = struct();
EisoDetection.threshold = Thresh(log(sbolAtHalfDetectionProb), "fluence");
EisoDetection.thresholdLogVals = EisoDetection.threshold.getLogValInt(logZoneGrid);
EisoDetection.thresholdVals = exp(EisoDetection.thresholdLogVals);
    
    
    


% histogram of fluence

logFluence = logDataY - EisoDetection.threshold.getLogValInt(logDataX) + log(sbolAtHalfDetectionProb);
figure('visible',figVisibility,'Color',figColor); hold on; box on; 
h = histogram(logFluence/log(10));
line([log(sbolAtHalfDetectionProb)/log(10), log(sbolAtHalfDetectionProb)/log(10)], [0, 130],'color',[0 ,0, 0],'linewidth',2,'linestyle','--')
line([log(sbolAtTenDetectionProb)/log(10), log(sbolAtTenDetectionProb)/log(10)], [0, 130],'color',[0 ,1, 1],'linewidth',2,'linestyle','--')
line([log(sbolAtNinetyDetectionProb)/log(10), log(sbolAtNinetyDetectionProb)/log(10)], [0, 130],'color',[1 ,0, 1],'linewidth',2,'linestyle','--')
legend([ndataString + " synthetic sample", "detection limit at 50%-probability", "detection limit at 10%-probability", "detection limit at 90%-probability"])
ylim([0,max(h.Values)+5])
xlabel("Log10 ( Fluence )")
ylabel("Count")

if figExportSynHistogram
    fileName = getFullPath(outPath+"SynHistFluence"+fileType);
    export_fig (fileName,'-m4 -transparent');
    hold off; close(gcf);
else
    hold off;
end


% plot alpha vs detector
if dryRunEiso
Eisoestat = struct();
Eisoestat.thresh.Val = sbolAtHalfDetectionProb;
Eisoestat.thresh.logVal = log(Eisoestat.thresh.Val);
Eisoestat.estat = EfronStat   ( logDataX ... logx
                            , logDataY ... logy
                            , Eisoestat.thresh.logVal ... observerLogThresh
                            , "fluence" ... threshType
                            );

    Eisoestat.thresh.logMin = log(1.e-9);
    Eisoestat.thresh.logMax = log(1.e-5);
    Eisoestat.thresh.logRange = Eisoestat.thresh.logMin:0.2:Eisoestat.thresh.logMax;
    Eisoestat.thresh.logRangeLen = length(Eisoestat.thresh.logRange);
    Eisoestat.estatList = cell(Eisoestat.thresh.logRangeLen,1);
    %return
    for i = 1:Eisoestat.thresh.logRangeLen
        Eisoestat.estatList{i} = EfronStat( logDataX ... logx
                                    , logDataY ... logy
                                    , Eisoestat.thresh.logRange(i) ... observerLogThresh
                                    , "fluence" ... threshType
                                    );
    end



% plot alpha(tau = 0) versus threshold

Eisoestat.tauAtAlphaZero = zeros(Eisoestat.thresh.logRangeLen,1);
Eisoestat.alphaAtTauZero = zeros(Eisoestat.thresh.logRangeLen,1);
Eisoestat.alphaAtTauPosOne = zeros(Eisoestat.thresh.logRangeLen,1);
Eisoestat.alphaAtTauNegOne = zeros(Eisoestat.thresh.logRangeLen,1);
for i = 1:Eisoestat.thresh.logRangeLen
    Eisoestat.tauAtAlphaZero(i) = Eisoestat.estatList{i}.logxMax.tau;
    Eisoestat.alphaAtTauZero(i) = Eisoestat.estatList{i}.logxMax.alpha.tau.zero;
    Eisoestat.alphaAtTauPosOne(i) = Eisoestat.estatList{i}.logxMax.alpha.tau.posOne;
    Eisoestat.alphaAtTauNegOne(i) = Eisoestat.estatList{i}.logxMax.alpha.tau.negOne;
end

end

figure('visible',figVisibility,'Color',figColor); hold on; box on;
p = xline(sbolAtHalfDetectionProb,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
p1 = scatter(sbolAtHalfDetectionProb, Eisoestat.estat.logxMax.alpha.tau.zero, 0.01, 'white');
plot( exp( Eisoestat.thresh.logRange ) ...
    , Eisoestat.alphaAtTauZero ...
    , "color", "red" ...
    , "linewidth", 2 ...
    );


%dx = 2.e-7; dy = 2.e-7;
%text(sbolAtHalfDetectionProb+dx, Eisoestat.estat.logxMax.alpha.tau.zero+dy, '\leftarrow \alpha = ' + string(Eisoestat.estat.logxMax.alpha.tau.zero),'Fontsize', 12)
%text(sbolAtHalfDetectionProb+dx, 3.8+dy, '\leftarrow p16 detection threshold','Fontsize', 12)
legend([p,p1],"detection limit at 50%-probability","\alpha = " + string(Eisoestat.estat.logxMax.alpha.tau.zero + " at detection limit"),"location","southwest")
xlabel("Detection Threshold Fluence [ergs / cm^2]", "interpreter", "tex", "fontsize", 10);
ylabel("\alpha at Efron-Petrosian Tau Statistic \tau = 0", "interpreter", "tex", "fontsize", 10);
set(gca, 'xscale', 'log', 'yscale', 'linear');
%export_fig(p16.output.path + "/P16threshAlpha.png", "-m4 -transparent")

if figExportAlphaDetector
    fileName = getFullPath(outPath+"SynAlphaVsDetectorEiso"+fileType);
    export_fig (fileName,'-m4 -transparent');
    hold off; close(gcf);
else
    hold off;
end












figure('visible',figVisibility,'Color',figColor); hold on; box on;
p = xline(sbolAtHalfDetectionProb,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
p1 = scatter(sbolAtHalfDetectionProb, Eisoestat.estat.logxMax.tau, 0.01, 'white');
plot( exp( Eisoestat.thresh.logRange ) ...
    , Eisoestat.tauAtAlphaZero ...
    , "color", "red" ...
    , "linewidth", 2 ...
    );


%dx = 2.e-7; dy = 2.e-7;
%text(sbolAtHalfDetectionProb+dx, Eisoestat.estat.logxMax.alpha.tau.zero+dy, '\leftarrow \tau = ' + string(Eisoestat.estat.logxMax.alpha.tau.zero),'Fontsize', 12)
%text(sbolAtHalfDetectionProb+dx, 3.8+dy, '\leftarrow p16 detection threshold','Fontsize', 12)
legend([p,p1],"detection limit at 50%-probability","\tau = " + string(Eisoestat.estat.logxMax.tau + " at detection limit"),"location","southwest")
xlabel("Detection Threshold Fluence [ergs / cm^2]", "interpreter", "tex", "fontsize", 10);
ylabel("Efron-Petrosian Tau Statistic at \alpha = 0", "interpreter", "tex", "fontsize", 10);
set(gca, 'xscale', 'log', 'yscale', 'linear');
%export_fig(p16.output.path + "/P16threshAlpha.png", "-m4 -transparent")

if figExportTauDetector
    fileName = getFullPath(outPath+"SynTauVsDetectorEiso"+fileType);
    export_fig (fileName,'-m4 -transparent');
    hold off; close(gcf);
else
    hold off;
end




Eisoestat.thresh.logEiso = log(sbolAtHalfDetectionProb) + getLogEisoLumDisTerm(zoneGrid);
Eisoestat.thresh.eiso = exp(Eisoestat.thresh.logEiso);

Eisoestat.getZcorrection = @(logZone) Eisoestat.estat.logxMax.alpha.tau.zero * logZone;
Eisoestat.corrected.logEiso = logDataY(:) - Eisoestat.getZcorrection( logDataX(:) );
Eisoestat.corrected.eiso = exp(Eisoestat.corrected.logEiso);
Eisoestat.corrected.thresh.logEiso = Eisoestat.thresh.logEiso(:) - Eisoestat.getZcorrection( logZoneGrid(:) );
Eisoestat.corrected.thresh.eiso = exp(Eisoestat.corrected.thresh.logEiso);

Eisoestat.regression.slope  = Eisoestat.estat.logxMax.alpha.tau.zero;
Eisoestat.regression.getLogEiso = @(intercept, logZone) intercept + Eisoestat.getZcorrection(logZone);
Eisoestat.getSumDistSq = @(intercept) sum( (logDataY - Eisoestat.regression.getLogEiso(intercept,logDataX)).^2 );
Eisoestat.regression.intercept = fminsearch( Eisoestat.getSumDistSq , 120 );
Eisoestat.regression.logZone = min(logDataX):0.05:max(logDataX);
Eisoestat.regression.logEiso = Eisoestat.regression.getLogEiso(Eisoestat.regression.intercept, Eisoestat.regression.logZone);

figure('visible',figVisibility,'Color',figColor); hold on; box on; colormap('cool');

scatter ( DataX ...
        , DataY ...
        , 20.75*ones(ndata,1) ...
        , detectionProb ...
        , '.' ...
        )
CBar = colorbar;
CBar.Label.String = 'Probability of Detection by BATSE LADs';
CBar.Label.Interpreter = 'tex';
CBar.Label.FontSize = fontSize;
xlim(rangeX);
ylim(rangeY);
xlabel("z + 1","interpreter", "tex","fontsize",fontSize)
ylabel("Isotropic Radiated Energy: E_{iso} [ ergs ]","interpreter", "tex","fontsize",fontSize)
set(gca,'xscale','log','yscale','log');

% add threshold


%threshGrid = exp( getLogThreshLim(log(zoneGrid),sbolAtHalfDetectionProb) );
plot( zoneGrid ...
    , EisoDetection.thresholdVals ...
    , "linewidth", 2 ...
    , 'color', 'black' ...
    );
legend([ndataString + " synthetic sample", "detection limit at 50%-probability"],"location","southeast","fontsize",fontSize)
xlim(zoneLim);
ylim([1.e48, 5.e55]);
set(gca,'xscale','log','yscale','log');

if regressionRequested
    plot( exp( Eisoestat.regression.logZone ) ...
        , exp( Eisoestat.regression.logEiso ) ...
        , "--" ...
        , "color", [0,1,0] ...
        , "linewidth", 2 ...
        );
    
    legend([ndataString + " synthetic sample","detection limit at 50%-probability","regression line"],"location","southeast","fontsize",fontSize)
    if figExportRegressionScatter
        fileName = getFullPath(outPath+"SynEisoVsZoneRegression"+fileType);
        export_fig (fileName,'-m4 -transparent');
        hold off; close(gcf);
    else
        hold off;
    end
else
    legend([ndataString + " synthetic sample", "detection limit at 50%-probability"],"location","southeast","fontsize",fontSize)
    if figExportSynScatterPlots
        fileName = getFullPath(outPath+"SynEisoVsZone"+fileType);
        export_fig (fileName,'-m4 -transparent');
        hold off; close(gcf);
    else
        hold off;
    end
 end
%[rho,pval] = corr(selectionLog10DataX,selectionLog10DataY,'type','Kendall')


% decorrelated redshift plot
figure("color", figColor); hold on; box on;
    plot( DataX ...
        , Eisoestat.corrected.eiso ...
        , "." ...
        , "markersize", 15 ...
        ..., "color", "black" ...
        , "linewidth", 2 ...
        );
    plot( zoneGrid ...
        , Eisoestat.corrected.thresh.eiso ...
        , "color", "black" ...
        , "linewidth", 2 ...
        );

xlabel("z + 1", "interpreter", "tex", "fontsize", 12);
ylabel("E_{0} [ ergs ]", "interpreter", "tex", "fontsize", 12);
legend([ndataString + " synthetic sample", "detection limit at 50%-probability"], "interpreter", "tex", "location", "southeast", "fontSize", 12,'color',figColor)
set(gca, 'xscale', 'log', 'yscale', 'log', "color", figColor);


if figExportDecorrelatedRedshiftData
    fileName = getFullPath(outPath+"SynEisoVsZoneCorrected"+fileType);
    export_fig (fileName,'-m4 -transparent');
    hold off; close(gcf);
else
    hold off;
end