clear all;
close all;
format compact; format long;
filePath = mfilename('fullpath');
[currentDir,fileName,fileExt] = fileparts(filePath); cd(currentDir);
cd(fileparts(mfilename('fullpath'))); % Change working directory to source code directory.
addpath(genpath("../../../../libmatlab"),"-begin");
addpath(genpath("../"),"-begin");

fontSize = 13;
figureColor = "white";

global alpha
alpha = 0.0;

d = importdata("../../in/Y15table1.xlsx");

dsorted = sortrows(d.data,2);
zone = dsorted(:,2)+1;
liso = dsorted(:,4);

ithreshList = log10(1.e-8):.1:log10(1.e-5);
ithreshLen = length(ithreshList);
tauAlphaZero = zeros(ithreshLen,1);
alphaTauZero = zeros(ithreshLen,1);
alphaTauZeroValue = zeros(ithreshLen,1);
j = 1;
for ithresh = ithreshList
    threshLim = 10^ithresh;

    logZone = log(zone);
    logLiso = log(liso);
    ndata = length(logZone);
    logZoneMax = getMaxRedshift( logZone ... xvec
                        , logLiso ... yvec
                        , threshLim ...
                        , @getLogThreshLim ... getThreshLim
                        );

    epstat = getEfronStat( logZone ... xvec
                         , logLiso ... yvec
                         , logZoneMax ... getLim
                         );

    % generate alpha-tau curve
    plotZoneEisoDependency_2
    tauAlphaZero(j) = minAlpha.tau;
    alphaTauZero(j) = minTau.alpha;
    alphaTauZeroValue(j) = minTau.value;
    j = j + 1;

end

figure; hold on; box on;
    plot(10.^ithreshList,tauAlphaZero,'.-','linewidth',2,'color','black','markersize',20);
    xlabel("Threshold Limit [ erg s^{-1} cm^{-2} ]", "interpreter", "tex", "fontSize", fontSize);
    ylabel("Tau at Alpha = 0", "fontSize", fontSize);
    set(gca, 'xscale', 'log');
    set(gcf, 'color', figureColor);
    set(gca,'color',figureColor, 'fontSize', fontSize)
    export_fig("../../out/Y15/Y15tauAlphaZero.png", "-m2 -transparent");
hold off;

figure; hold on; box on;
    colormap('winter');
    plot(10.^ithreshList,alphaTauZero,'-','linewidth',2,'color','black','markersize',20);
    scatter(10.^ithreshList,alphaTauZero,800,tauAlphaZero,'.');
    cb = colorbar();
    cb.Label.String = 'Tau at Alpha = 0';
    xlabel("Threshold Limit [ erg s^{-1} cm^{-2} ]", "interpreter", "tex", "fontSize", fontSize);
    ylabel("Alpha near Tau = 0", "fontSize", fontSize);
    set(gca, 'xscale', 'log');
    set(gcf, 'color', figureColor);
    set(gca,'color',figureColor, 'fontSize', fontSize)
    export_fig("../../out/Y15/Y15alphaTauZero.png", "-m2 -transparent");
hold off;