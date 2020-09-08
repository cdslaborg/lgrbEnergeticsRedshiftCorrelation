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
figExportAlphaTau = 0;
figExportAlphaDetector = 0;
figExportTauDetector = 0;
figExportRegressionScatter = 0;
figExportDecorrelatedRedshiftData = 0;
figExportSynScatterPlots = 0; % if there is a regression line we can't export a figure that doesnt have regression line
regressionRequested = 1; % make a regression line on the scatter plots
figColor = 'white';
figVisibility = 'on';
dryRunLiso = false;

fontSize = 13;
skip = 100;
global alpha; alpha = 0.0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% Liso plots %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rangeX = [1.e0, 3.6e1]; % redshift+1
rangeY = [1.e46, 3.e56]; % log10Liso
b10 = importdata("..\..\..\..\20181213_BatseLgrbRedshift\git\___SyntheticSample___\winx64\intel\release\static\serial\bin\out\kfacOneThird\syntheticSampleB10.csv");
detProbIndex = 10;
pbolAtHalfDetectionProb = exp( mean( b10.data( b10.data(:,detProbIndex)>0.48 & b10.data(:,detProbIndex)<0.52 , 5) ) );
pbolAtTenDetectionProb = exp( mean( b10.data( b10.data(:,detProbIndex)>0.08 & b10.data(:,detProbIndex)<0.12 , 5) ) );
pbolAtNinetyDetectionProb = exp( mean( b10.data( b10.data(:,detProbIndex)>0.88 & b10.data(:,detProbIndex)<0.92 , 5) ) );
%Mask = b10.data(1:1:end,detProbIndex) > unifrnd(0,1,length(b10.data(1:1:end,detProbIndex)),1);
Mask = b10.data(1:1:end,detProbIndex) > unifrnd(0,1,length(b10.data(1:1:end,detProbIndex)),1);
DataX = b10.data(Mask,9) + 1; DataX = DataX(1:skip:end);
DataY = exp( b10.data(Mask,1) ); DataY = DataY(1:skip:end);
detectionProb = b10.data(Mask,detProbIndex); detectionProb = detectionProb(1:skip:end);
logDataX = log(DataX);
logDataY = log(DataY);
ndata = length(DataX);
ndataString = string(ndata);

zoneLim = [0.8, 20];
zoneGrid = 1.001:0.001:zoneLim(2);
logZoneGrid = log(zoneGrid);

LisoDetection = struct();
LisoDetection.threshold = Thresh(log(pbolAtHalfDetectionProb), "flux");
LisoDetection.thresholdLogVals = LisoDetection.threshold.getLogValInt(logZoneGrid);
LisoDetection.thresholdVals = exp(LisoDetection.thresholdLogVals);

    
% histogram of flux

logFlux = logDataY -  LisoDetection.threshold.getLogValInt(logDataX) + log(pbolAtHalfDetectionProb);
figure('visible',figVisibility,'Color',figColor); hold on; box on; 
h = histogram(logFlux/log(10));
line([log(pbolAtHalfDetectionProb)/log(10), log(pbolAtHalfDetectionProb)/log(10)], [0, 130],'color','black','linewidth',2,'linestyle','--')
line([log(pbolAtTenDetectionProb)/log(10), log(pbolAtTenDetectionProb)/log(10)], [0, 130],'color',[0 ,1, 1],'linewidth',2,'linestyle','--')
line([log(pbolAtNinetyDetectionProb)/log(10), log(pbolAtNinetyDetectionProb)/log(10)], [0, 130],'color',[1 ,0, 1],'linewidth',2,'linestyle','--')
legend([ndataString + " synthetic sample", "detection limit at 50%-probability", "detection limit at 10%-probability", "detection limit at 90%-probability"])
ylim([0,max(h.Values)+5])
xlabel("Log10 ( Flux [ergs/s/cm^2])")
ylabel("Count")

if figExportSynHistogram
    fileName = getFullPath(outPath+"SynHistFlux"+fileType);
    export_fig (fileName,'-m4 -transparent');
    hold off; close(gcf);
else
    hold off;
end



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % compute tau-alpha plot
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% logRefinedZoneMax = getXmax ( logDataX ... xvec
%                             , logDataY ... yvec
%                             , @getLogThreshLimLiso ... getThreshLim
%                             );
% 
% stat = getZoneEisoDependency(logDataX, logDataY, logRefinedZoneMax);
% statCount = length(stat);
% alphaValues = zeros(statCount,1);
% tauValues = zeros(statCount,1);
% for i = 1:statCount
%     alphaValues(i) = -stat{i}.alpha;
%     tauValues(i) = -stat{i}.epstat.tau;
% end
% 
% 
% % the inferred alpha / tau
% 
% minTau = struct();
% [minTau.value, minTau.index] = min(abs(tauValues)); minTau.value = tauValues(minTau.index);
% minTau.alpha = alphaValues(minTau.index);
% minAlpha.value = alphaValues(alphaValues==0);
% minAlpha.tau = tauValues(alphaValues==0);
% 
% figure('visible',figVisibility,'Color',figColor); hold on; box on;
% 
%     plot( alphaValues ...
%         , tauValues ...
%         , '.-' ...
%         , 'linewidth', 2 ...
%         , 'color', 'black' ...
%         , 'markersize', 20 ...
%         );
%  scatter( minAlpha.value ...
%         , minAlpha.tau ...
%         , 1500 ...
%         , 'red' ...
%         , '.' ...
%         );
%  scatter( minTau.alpha ...
%         , minTau.value ...
%         , 1500 ...
%         , 'blue' ...
%         , '.' ...
%         );
%     xlabel("\alpha in L_{iso} / (z + 1)^\alpha", "interpreter", "tex", "fontsize", fontSize);
%     ylabel("Efron - Petrosian Statistic", "interpreter", "tex", "fontsize", fontSize);
%     legend(["Efron-Petrosian curve", "original sample", "redshift-decorrelated sample"],"location","southwest","fontsize",fontSize)
% 
% if figExportAlphaTau
%     fileName = getFullPath(outPath+"SynAlphaVsTauLiso"+fileType);
%     export_fig (fileName,'-m4 -transparent');
%     hold off; close(gcf);
% else
%     hold off;
% end



% plot alpha vs detector
if dryRunLiso
Lisoestat = struct();
Lisoestat.thresh.Val = pbolAtHalfDetectionProb;
Lisoestat.thresh.logVal = log(Lisoestat.thresh.Val);
Lisoestat.estat = EfronStat   ( logDataX ... logx
                            , logDataY ... logy
                            , Lisoestat.thresh.logVal ... observerLogThresh
                            , "flux" ... threshType
                            );

    Lisoestat.thresh.logMin = log(1.e-9);
    Lisoestat.thresh.logMax = log(1.e-5);
    Lisoestat.thresh.logRange = Lisoestat.thresh.logMin:0.2:Lisoestat.thresh.logMax;
    Lisoestat.thresh.logRangeLen = length(Lisoestat.thresh.logRange);
    Lisoestat.estatList = cell(Lisoestat.thresh.logRangeLen,1);
    %return
    for i = 1:Lisoestat.thresh.logRangeLen
        Lisoestat.estatList{i} = EfronStat( logDataX ... logx
                                    , logDataY ... logy
                                    , Lisoestat.thresh.logRange(i) ... observerLogThresh
                                    , "flux" ... threshType
                                    );
    end



% plot tau(alpha = 0) versus threshold

Lisoestat.tauAtAlphaZero = zeros(Lisoestat.thresh.logRangeLen,1);
Lisoestat.alphaAtTauZero = zeros(Lisoestat.thresh.logRangeLen,1);
Lisoestat.alphaAtTauPosOne = zeros(Lisoestat.thresh.logRangeLen,1);
Lisoestat.alphaAtTauNegOne = zeros(Lisoestat.thresh.logRangeLen,1);
for i = 1:Lisoestat.thresh.logRangeLen
    Lisoestat.tauAtAlphaZero(i) = Lisoestat.estatList{i}.logxMax.tau;
    Lisoestat.alphaAtTauZero(i) = Lisoestat.estatList{i}.logxMax.alpha.tau.zero;
    Lisoestat.alphaAtTauPosOne(i) = Lisoestat.estatList{i}.logxMax.alpha.tau.posOne;
    Lisoestat.alphaAtTauNegOne(i) = Lisoestat.estatList{i}.logxMax.alpha.tau.negOne;
end
end

figure('visible',figVisibility,'Color',figColor); hold on; box on;

p = xline(pbolAtHalfDetectionProb,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
p1 = scatter(pbolAtHalfDetectionProb, Lisoestat.estat.logxMax.alpha.tau.zero, 0.01, 'white');
plot( exp( Lisoestat.thresh.logRange ) ...
    , Lisoestat.alphaAtTauZero ...
    , "color", "red" ...
    , "linewidth", 2 ...
    );


%dx = 2.e-8; dy = 2.e-8;
%text(pbolAtHalfDetectionProb+dx, Lisoestat.estat.logxMax.alpha.tau.zero+dy, '\leftarrow \alpha = ' + string(Lisoestat.estat.logxMax.alpha.tau.zero),'Fontsize', 12)
%text(pbolAtHalfDetectionProb+dx, 3.8+dy, '\leftarrow p16 detection threshold','Fontsize', 12)
legend([p,p1],"detection limit at 50%-probability","\alpha = " + string(Lisoestat.estat.logxMax.alpha.tau.zero + " at detection limit"),"location","southwest")
xlabel("Detection Threshold Flux [ergs / s / cm^2]", "interpreter", "tex", "fontsize", 10);
ylabel("\alpha at Efron-Petrosian Tau Statistic \tau = 0", "interpreter", "tex", "fontsize", 10);
set(gca, 'xscale', 'log', 'yscale', 'linear');
if figExportAlphaDetector
    fileName = getFullPath(outPath+"SynAlphaVsDetectorLiso"+fileType);
    export_fig (fileName,'-m4 -transparent');
    hold off; close(gcf);
else
    hold off;
end









%plot tau at alpha=0

figure('visible',figVisibility,'Color',figColor); hold on; box on;
p = xline(pbolAtHalfDetectionProb,"linewidth", 2, "linestyle", "--", "color", [0,0,0,0.3]);
p1 = scatter(pbolAtHalfDetectionProb, Lisoestat.estat.logxMax.tau, 0.01, 'white');
plot( exp( Lisoestat.thresh.logRange ) ...
    , Lisoestat.tauAtAlphaZero ...
    , "color", "red" ...
    , "linewidth", 2 ...
    );


%dx = 2.e-7; dy = 2.e-7;
%text(pbolAtHalfDetectionProb+dx, Lisoestat.estat.logxMax.alpha.tau.zero+dy, '\leftarrow \tau = ' + string(Lisoestat.estat.logxMax.alpha.tau.zero),'Fontsize', 12)
%text(pbolAtHalfDetectionProb+dx, 3.8+dy, '\leftarrow p16 detection threshold','Fontsize', 12)
legend([p,p1],"detection limit at 50%-probability","\tau = " + string(Lisoestat.estat.logxMax.tau + " at detection limit"),"location","southwest")
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














%%%%%%%%% scatter plot %%%%%%%%%%%%
zoneLim = [0.8, 20];
logZoneLimits = log(zoneLim);

Lisoestat.thresh.logLiso = log(pbolAtHalfDetectionProb) + getLogLisoLumDisTerm(zoneGrid);
Lisoestat.thresh.liso = exp(Lisoestat.thresh.logLiso);

Lisoestat.getZcorrection = @(logZone) Lisoestat.estat.logxMax.alpha.tau.zero * logZone;
Lisoestat.corrected.logLiso = logDataY(:) - Lisoestat.getZcorrection( logDataX(:) );
Lisoestat.corrected.liso = exp(Lisoestat.corrected.logLiso);
Lisoestat.corrected.thresh.logLiso = Lisoestat.thresh.logLiso(:) - Lisoestat.getZcorrection( logZoneGrid(:) );
Lisoestat.corrected.thresh.liso = exp(Lisoestat.corrected.thresh.logLiso);

Lisoestat.regression.slope  = Lisoestat.estat.logxMax.alpha.tau.zero;
Lisoestat.regression.getLogLiso = @(intercept, logZone) intercept + Lisoestat.getZcorrection(logZone);
Lisoestat.getSumDistSq = @(intercept) sum( (logDataY - Lisoestat.regression.getLogLiso(intercept,logDataX)).^2 );
Lisoestat.regression.intercept = fminsearch( Lisoestat.getSumDistSq , 120 );
Lisoestat.regression.logZone = min(logDataX):0.05:max(logDataX);
Lisoestat.regression.logLiso = Lisoestat.regression.getLogLiso(Lisoestat.regression.intercept, Lisoestat.regression.logZone);



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
ylabel("Isotropic Peak Luminosity: L_{iso} [ ergs / s ]","interpreter", "tex","fontsize",fontSize)
set(gca,'xscale','log','yscale','log');

% add threshold

zoneGrid = 1.001:0.001:zoneLim(2);
%threshGrid = exp( getLogThreshLim(log(zoneGrid),pbolAtHalfDetectionProb,true));
plot( zoneGrid ...
    , LisoDetection.thresholdVals ...
    , "linewidth", 2 ...
    , 'color', 'black' ...
    );

xlim(zoneLim);
ylim([10^46,10^56]);
set(gca,'xscale','log','yscale','log');

if regressionRequested
    plot( exp( Lisoestat.regression.logZone ) ...
        , exp( Lisoestat.regression.logLiso ) ...
        , "--" ...
        , "color", [0,1,0] ...
        , "linewidth", 2 ...
        );
    
    legend([ndataString + " synthetic sample","detection limit at 50%-probability","regression line"],"location","southeast","fontsize",fontSize)
    if figExportRegressionScatter
        fileName = getFullPath(outPath+"SynLisoVsZoneRegression"+fileType);
        export_fig (fileName,'-m4 -transparent');
        hold off; close(gcf);
    else
        hold off;
    end
else
    legend([ndataString + " synthetic sample", "detection limit at 50%-probability"],"location","southeast","fontsize",fontSize)
    if figExportSynScatterPlots
        fileName = getFullPath(outPath+"SynLisoVsZone"+fileType);
        export_fig (fileName,'-m4 -transparent');
        hold off; close(gcf);
    else
        hold off;
    end
end






% decorrelated redshift
figure("color", figColor); hold on; box on;
    plot( DataX ...
        , Lisoestat.corrected.liso ...
        , "." ...
        , "markersize", 15 ...
        ..., "color", "black" ...
        , "linewidth", 2 ...
        );
    plot( zoneGrid ...
        , Lisoestat.corrected.thresh.liso ...
        , "color", "black" ...
        , "linewidth", 2 ...
        );

xlabel("z + 1", "interpreter", "tex", "fontsize", 12);
ylabel("L_{0} [ ergs / s ]", "interpreter", "tex", "fontsize", 12);
legend([ndataString + " synthetic sample", "detection limit at 50%-probability"], "interpreter", "tex", "location", "southeast", "fontSize", 12,'color',figColor)
set(gca, 'xscale', 'log', 'yscale', 'log', "color", figColor);
%xlim(rangeX);
xlim(zoneLim);
ylim([10^46,10^56]);

if figExportDecorrelatedRedshiftData
    fileName = getFullPath(outPath+"SynLisoVsZoneCorrected"+fileType);
    export_fig (fileName,'-m4 -transparent');
    hold off; close(gcf);
else
    hold off;
end