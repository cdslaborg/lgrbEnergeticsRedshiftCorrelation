clear all;
close all;
format compact; format long;
filePath = mfilename('fullpath');
[currentDir,fileName,fileExt] = fileparts(filePath); cd(currentDir);
cd(fileparts(mfilename('fullpath'))); % Change working directory to source code directory.
addpath(genpath("D:\Dropbox\Projects\libmatlab\astro"),"-begin");

fontSize = 13;
skip = 100;
global alpha; alpha = 0.0;

rangeX = [1.e0, 3.6e1]; % redshift+1
rangeY = [1.e46, 3.e56]; % log10Eiso
b10 = importdata("D:\Dropbox\Projects\20181213_BatseLgrbRedshift\git\___SyntheticSample___\winx64\intel\release\static\serial\bin\out\kfacOneThird\syntheticSampleB10.csv");
detProbIndex = 10;
sbolAtHalfDetectionProb = exp( mean( b10.data( b10.data(:,detProbIndex)>0.48 & b10.data(:,detProbIndex)<0.52 , 7) ) );
%Mask = b10.data(1:1:end,detProbIndex) > 0.5;
Mask = b10.data(1:1:end,detProbIndex) > unifrnd(0,1,length(b10.data(1:1:end,detProbIndex)),1);
DataX = b10.data(Mask,9) + 1; DataX = DataX(1:skip:end);
DataY = exp( b10.data(Mask,3) ); DataY = DataY(1:skip:end);
detectionProb = b10.data(Mask,detProbIndex); detectionProb = detectionProb(1:skip:end);
logDataX = log(DataX);
logDataY = log(DataY);
ndata = length(DataX)

%selectionMask = (Log10DataX < log10(6)) &  (Log10DataY > 52);
%selectionLog10DataX = Log10DataX(selectionMask);
%selectionLog10DataY = Log10DataY(selectionMask);

zoneLim = [0.8, 20];
figure; hold on; box on; colormap('cool');

    scatter ( DataX ...
            , DataY ...
            ..., 0.75*ones(ZModel.(ZModel.ID{imodel}).Synthetic.count,1) ...
            , 20.75*ones(ndata,1) ...
            ..., 40*ones(sum(Mask),1) ...
            , detectionProb ...
            , '.' ..., 'filled' ...
            )
    CBar = colorbar;
    CBar.Label.String = 'Probability of Detection by BATSE LADs';
    CBar.Label.Interpreter = 'tex';
    CBar.Label.FontSize = fontSize;
    xlim(rangeX);
    ylim(rangeY);
    xlabel("z + 1","interpreter", "tex","fontsize",fontSize)
    ylabel("Isotropic Radiated Energy: E_{iso} [ ergs/s ]","interpreter", "tex","fontsize",fontSize)
    set(gca,'xscale','log','yscale','log');

    % add threshold

    zoneGrid = 1.001:0.001:zoneLim(2);
    threshGrid = exp( getLogThreshLim(log(zoneGrid),sbolAtHalfDetectionProb) );
    plot( zoneGrid ...
        , threshGrid ...
        , "linewidth", 2 ...
        , 'color', 'black' ...
        );
    legend(["380 synthetic sample", "detection limit at 50%-probability"],"location","southeast","fontsize",fontSize)
    xlim(zoneLim);
    ylim([1.e48, 5.e55]);
    set(gca,'xscale','log','yscale','log');

%[rho,pval] = corr(selectionLog10DataX,selectionLog10DataY,'type','Kendall')


% histogram of fluence

logFluence = logDataY - getLogThreshLim(logDataX,sbolAtHalfDetectionProb) + log(sbolAtHalfDetectionProb);
figure; hold on; box on; 
    h = histogram(logFluence/log(10));
    line([log(sbolAtHalfDetectionProb)/log(10), log(sbolAtHalfDetectionProb)/log(10)], [0, 100],'color','black','linewidth',2,'linestyle','--')
    legend(["380 synthetic sample", "detection limit at 50%-probability"])
    xlabel("Log10 ( Fluence )")
    ylabel("Count")
    export_fig("batseFluenceHist.png", "-m2 -transparent")
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute tau-alpha plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

logRefinedZoneMax = getMaxRedshift ( logDataX ... xvec
                            , logDataY ... yvec
                            , @getLogThreshLim ... getThreshLim
                            );

stat = getZoneEisoDependency(logDataX, logDataY, logRefinedZoneMax);
statCount = length(stat);
alphaValues = zeros(statCount,1);
tauValues = zeros(statCount,1);
for i = 1:statCount
    alphaValues(i) = -stat{i}.alpha;
    tauValues(i) = -stat{i}.epstat.tau;
end


% the inferred alpha / tau

minTau = struct();
[minTau.value, minTau.index] = min(abs(tauValues)); minTau.value = tauValues(minTau.index);
minTau.alpha = alphaValues(minTau.index);
minAlpha.value = alphaValues(alphaValues==0);
minAlpha.tau = tauValues(alphaValues==0);

figure; hold on; box on;

    plot( alphaValues ...
        , tauValues ...
        , '.-' ...
        , 'linewidth', 2 ...
        , 'color', 'black' ...
        , 'markersize', 20 ...
        );
 scatter( minAlpha.value ...
        , minAlpha.tau ...
        , 1500 ...
        , 'red' ...
        , '.' ...
        );
 scatter( minTau.alpha ...
        , minTau.value ...
        , 1500 ...
        , 'blue' ...
        , '.' ...
        );
    xlabel("\alpha in E_{iso} / (z + 1)^\alpha", "interpreter", "tex", "fontsize", fontSize);
    ylabel("Efron - Petrosian Statistic", "interpreter", "tex", "fontsize", fontSize);
    legend(["Efron-Petrosian curve", "original sample", "redshift-decorrelated sample"],"location","southwest","fontsize",fontSize)

hold off;



