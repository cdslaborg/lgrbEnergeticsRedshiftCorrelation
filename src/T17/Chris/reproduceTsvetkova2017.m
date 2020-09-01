clear all;
close all;
format compact; format long;
filePath = mfilename('fullpath');
[currentDir,fileName,fileExt] = fileparts(filePath); cd(currentDir);
cd(fileparts(mfilename('fullpath'))); % Change working directory to source code directory.
addpath(genpath("../../../../../libmatlab"),"-begin");
addpath(genpath("../../"),"-begin");

fontSize = 13;
figureColor = "white";

global alpha
alpha = 0.0;
threshLim = 8.6e-7;

d = importdata("../../../in/T17table4_2.txt",' ',47);

dsorted = sortrows(d.data,1);
zone = dsorted(:,1)+1;
liso = dsorted(:,20)*1.e+51;

logZone = log(zone);
logLiso = log(liso);
ndata = length(logZone);
logZoneMax = getMaxRedshift( logZone ... xvec
                    , logLiso ... yvec
                    , threshLim ...
                    , @getLogThreshLim ... getThreshLim
                    );

figure; hold on; box on;
zoneLim = [1, 6.5]; % 2200];

    plot(zone,liso,'.','markersize',20)

    % threhshold

    zoneGrid = 1.001:0.001:zoneLim(2);
    threshGrid = exp( getLogThreshLim(log(zoneGrid),threshLim) );
    plot( zoneGrid ...
        , threshGrid ...
        , "linewidth", 2 ...
        , 'color', 'black' ...
        );

    xlim(zoneLim);
    ylim([1.e50, 5.e55]);
    xlabel("z + 1", "fontSize", fontSize)
    ylabel("L_{iso} [ ergs / s ]", "fontSize", fontSize)
    set(gca,'yscale','log');
    set(gca,'xscale','log');
    legend(["T17 sample", "T17 detection limit"], "interpreter", "tex", "location", "southeast", "fontSize", fontSize,'color',figureColor)

    epstat = getEfronStat   ( logZone ... xvec
                            , logLiso ... yvec
                            , logZoneMax ... getLim
                            );
    zoneMax = exp(epstat.xmax);

    ibegin = 1;
    iend = ndata;
    minDistSqFromThreshLine = zeros(iend-ibegin+1,1);
    logZoneMinDist = zeros(iend-ibegin+1,1);
    logLisoMinDist = zeros(iend-ibegin+1,1);
    for i = 1:iend-ibegin+1 %ndata
        getDistSq = @(x) log( (getLogThreshLim(x,threshLim) - logLiso(i+ibegin-1)).^2 + (x-logZone(i+ibegin-1)).^2 );
        options = optimset("MaxIter", 100000, "MaxFunEvals", 100000, "TolFun", 1.e-7, "TolX", 1.e-7);
        [logZoneMinDistCurrent, funcVal, exitflag, output] = fminsearch(getDistSq, logZone(i+ibegin-1), options);
        if exitflag==1
            logZoneMinDist(i) = logZoneMinDistCurrent;
            logLisoMinDist(i) = getLogThreshLim(logZoneMinDistCurrent,threshLim);
            minDistSqFromThreshLine(i) = funcVal;
        else
            disp( "failed at iteration " + string(i) ...
                + " with xvec(i) = " + string(logZone(i+ibegin-1)) ...
                + ", yvec(i) = " + string(logEiso(i+ibegin-1)) + " with fval = " + string(funcVal) );
            i
            logZone(i)
            logLiso(i)
            output
        end
    end
    
    set(gcf,'color',figureColor)
    set(gca,'color',figureColor, 'fontSize', fontSize)
    export_fig("../../../out/T17/T17zoneLiso.png", "-m4 -transparent")

hold off
epstat.tau

LOG_THRESH_LIM = log(threshLim);
verticalDistanceFromThreshLine = logLiso - getLogThreshLim(logZone,threshLim) + LOG_THRESH_LIM;
figure; hold on; box on;
    h = histogram(verticalDistanceFromThreshLine/log(10),"binwidth",0.25);
    line([LOG_THRESH_LIM/log(10), LOG_THRESH_LIM/log(10)], [0, 50],'color','black','linewidth',2,'linestyle','--')
    legend(["P16 sample", "P16 detection limit"], "interpreter", "tex", "fontSize", fontSize-2,'color',figureColor)
    xlabel("log10( Flux [ ergs / s / cm^2 ] )", "interpreter", "tex", "fontSize", fontSize-2)
    ylabel("Count", "interpreter", "tex", "fontSize", fontSize-2)
    set(gcf,'color',figureColor)
    set(gca,'color',figureColor, 'fontSize', fontSize)
    export_fig("../../../out/T17/T17histSbol.png", "-m4 -transparent")
hold off;

figure; hold on; box on;
    plot(exp(logZone),exp(verticalDistanceFromThreshLine),'.-','markersize',10); set(gca,'xscale','log','yscale','linear');
    line([zoneLim(1), zoneLim(2)],[threshLim, threshLim],'color','black','linewidth',2,'linestyle','--')
    legend(["P16 sample", "P16 detection limit"], "fontSize", fontSize,'color',figureColor)
    xlabel("z + 1", "interpreter", "tex", "fontSize", fontSize)
    ylabel("Flux [ ergs / s / cm^2 ]", "interpreter", "tex", "fontSize", fontSize)
    xlim(zoneLim)
    set(gca,'xscale','log','yscale','log');
    set(gcf,'color',figureColor)
    set(gca,'color',figureColor, 'fontSize', fontSize)
    export_fig("../../../out/T17/T17zoneSbol.png", "-m4 -transparent")
hold off;


% generate alpha-tau curve
plotZoneEisoDependency