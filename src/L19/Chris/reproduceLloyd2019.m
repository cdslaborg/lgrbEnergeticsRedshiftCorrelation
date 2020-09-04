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
THRESH_LIM = 1.6e-7;

global alpha
alpha = 0.0;

d = importdata("../../../in/L19figure1.xlsx"); % getLogLumDisWicMPC.m

dsorted = sortrows(d.data);
dsorted(:,3:4) = dsorted(:,3:4) * 1.e52;
threshMask = dsorted(:,3) > exp( getLogThreshLim( log(dsorted(:,1)+1) ) );
%dsorted = dsorted( threshMask, : );

Mask = dsorted(:,2) > 2;
lenMask = length(Mask);
zone = dsorted(Mask,1) + 1;
eiso = dsorted(Mask,3) .* getZoneCorrection(zone);
eiso2 = dsorted(Mask,4);


logZone = log(zone);
logEiso = log(eiso);
ndata = length(logZone);
logZoneMax = getXmax( logZone ... xvec
                    , logEiso ... yvec
                    , @getLogThreshLim ... getThreshLim
                    );

figure; hold on; box on;
zoneLim = [0.8, 12]; % 2200];

    plot(zone,eiso,'.','markersize',20) %,'color','red')
    %plot(zone,eiso2,'.','markersize',20)

    % threhshold

    zoneGrid = 1.001:0.001:zoneLim(2);
    %threshGrid = exp( LOGMPC2CMSQ4PI + 2*getLogLumDisWicMPC(zoneGrid) + LOG_THRESH_LIM - 52*log(10) - log(zoneGrid) );
    threshGrid = exp( getLogThreshLim(log(zoneGrid)) );
    plot( zoneGrid ...
        , threshGrid ...
        , "linewidth", 2 ...
        , 'color', 'black' ...
        );

    xlim(zoneLim);
    ylim([1.e48, 5.e55]);
    xlabel("z + 1", "fontSize", fontSize)
    ylabel("Eiso [ ergs ]", "fontSize", fontSize)
    set(gca,'xscale','log','yscale','log');
    legend(["L19 sample", "L19 detection limit"], "interpreter", "tex", "location", "southeast", "fontSize", fontSize,'color',figureColor)

    epstat = getEfronStat   ( logZone ... xvec
                            , logEiso ... yvec
                            , logZoneMax ... getLim
                            );
    zoneMax = exp(epstat.xmax);
    %plot(zoneMax, exp(getLogThreshLim(epstat.xmax)), '.', 'markersize', 15)


    ibegin = 1;
    iend = ndata;
    minDistSqFromThreshLine = zeros(iend-ibegin+1,1);
    logZoneMinDist = zeros(iend-ibegin+1,1);
    logEisoMinDist = zeros(iend-ibegin+1,1);
    %global logZoneCurrent logEisoCurrent
    for i = 1:iend-ibegin+1 %ndata
        getDistSq = @(x) log( (getLogThreshLim(x) - logEiso(i+ibegin-1)).^2 + (x-logZone(i+ibegin-1)).^2 );
        %logZoneCurrent = logZone(i+ibegin-1);
        %logEisoCurrent = logEiso(i+ibegin-1);
        options = optimset("MaxIter", 100000, "MaxFunEvals", 100000, "TolFun", 1.e-7, "TolX", 1.e-7);
        %[logZoneMinDistCurrent, funcVal, exitflag, output] = fminsearch(@getDistSq, logZone(i+ibegin-1), options);
        [logZoneMinDistCurrent, funcVal, exitflag, output] = fminsearch(getDistSq, logZone(i+ibegin-1), options);
        if exitflag==1
            logZoneMinDist(i) = logZoneMinDistCurrent;
            logEisoMinDist(i) = getLogThreshLim(logZoneMinDistCurrent);
            minDistSqFromThreshLine(i) = funcVal;
        else
            disp( "failed at iteration " + string(i) ...
                + " with xvec(i) = " + string(logZone(i+ibegin-1)) ...
                + ", yvec(i) = " + string(logEiso(i+ibegin-1)) + " with fval = " + string(funcVal) );
            i
            logZone(i)
            logEiso(i)
            output
        end
    end
    %plot(exp(logZoneMinDist),exp(logEisoMinDist),'.','color','red','markersize',20)
    %plot(exp(logZone(ibegin:iend)),exp(logEiso(ibegin:iend)),'.','color','red','markersize',20)

    set(gcf,'color',figureColor)
    set(gca,'color',figureColor, 'fontSize', fontSize)
    %export_fig("../../../out/L19/L19zoneEiso.png", "-m4 -transparent")

hold off
epstat.tau

% figure; plot((zoneGrid), getDistSq(log(zoneGrid)),'.')
% set(gca,'xscale','log','yscale','linear');
% xlim(zoneLim);

% figure; hold on; box on;
% plot(log(zoneGrid), log(threshGrid), "linewidth", 2, 'color', 'black');
% plot(logZone,logEiso,'.','markersize',20)
% plot((logZoneMinDist),(logEisoMinDist),'.','color','red','markersize',20)
% hold off;

LOG_THRESH_LIM = log(THRESH_LIM);
verticalDistanceFromThreshLine = logEiso - getLogThreshLim(logZone) + LOG_THRESH_LIM;
figure; hold on; box on;
    h = histogram(verticalDistanceFromThreshLine/log(10),"binwidth",0.5);
    line([LOG_THRESH_LIM/log(10), LOG_THRESH_LIM/log(10)], [0, 100],'color','black','linewidth',2,'linestyle','--')
    legend(["L19 sample", "L19 detection limit"], "interpreter", "tex", "fontSize", fontSize-2,'color',figureColor)
    xlabel("Log10 ( Fluence [ ergs / cm^2 ] )", "interpreter", "tex", "fontSize", fontSize-2)
    ylabel("Count", "interpreter", "tex", "fontSize", fontSize-2)
    set(gcf,'color',figureColor)
    set(gca,'color',figureColor, 'fontSize', fontSize)
    export_fig("../../../out/L19/L19histSbol.png", "-m4 -transparent")
hold off;

figure; hold on; box on;
    plot(exp(logZone),exp(verticalDistanceFromThreshLine),'.-','markersize',10); set(gca,'xscale','log','yscale','linear');
    line([zoneLim(1), zoneLim(2)],[THRESH_LIM, THRESH_LIM],'color','black','linewidth',2,'linestyle','--')
    legend(["L19 sample", "L19 detection limit"], "fontSize", fontSize,'color',figureColor)
    xlabel("z + 1", "interpreter", "tex", "fontSize", fontSize)
    ylabel("Fluence [ ergs / cm^2 ]", "interpreter", "tex", "fontSize", fontSize)
    set(gca,'xscale','log','yscale','log');
    set(gcf,'color',figureColor)
    set(gca,'color',figureColor, 'fontSize', fontSize)
    export_fig("../../../out/L19/L19zoneSbol.png", "-m4 -transparent")
hold off;


% generate alpha-tau curve
%plotZoneEisoDependency



