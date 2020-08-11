%clc;
%clear all;
%close all;
%clear classes;
%format compact; format long;
filePath = mfilename('fullpath');
[currentDir,fileName,fileExt] = fileparts(filePath); cd(currentDir);
cd(fileparts(mfilename('fullpath'))); % Change working directory to source code directory.
addpath(genpath("../../../../libmatlab"),"-begin");
addpath(genpath("../"),"-begin");

fontSize = 13;
figureColor = "white";
freshRunEnabled = false; % this must be set to true for first ever simulation. Thereafter, it can be set to false to save time.

if freshRunEnabled

    y15 = struct();
    y15.thresh.val = 2.e-8;
    y15.thresh.logVal = log(y15.thresh.val);

    y15.input.file.path = "../../in/Y15table1.xlsx";
    y15.input.file.contents = importdata(y15.input.file.path);
    y15.input.file.contents.sorted = sortrows(y15.input.file.contents.data,2);
    y15.output.path = "../../out/Y15/"; if ~isdir(y15.output.path); mkdir(y15.output.path); end
    y15.zone = y15.input.file.contents.sorted(:,2) + 1;
    y15.liso = y15.input.file.contents.sorted(:,4);
    y15.logZone = log(y15.zone);
    y15.logLiso = log(y15.liso);

    y15.estat = EfronStat   ( y15.logZone ... logx
                            , y15.logLiso ... logy
                            , y15.thresh.logVal ... observerLogThresh
                            , "flux" ... threshType
                            );

    y15.logPbol = y15.estat.logyDistanceFromLogThresh + y15.thresh.logVal;
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

    save(y15.output.path+"y15.mat","y15");

else
    
    load(y15.output.path+"y15.mat"); % loads y15 object
    
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

figure; hold on; box on;
plot( y15.thresh.logRange / log(10) ...
    , y15.tauAtAlphaZero ...
    , "color", "red" ...
    , "linewidth", 1 ...
    );
xlabel("Detection Threshold Flux [ergs / s / cm^2]", "interpreter", "tex", "fontsize", fontSize);
ylabel("Efron-Petrosian Tau Statistic \tau at \alpha = 0", "interpreter", "tex", "fontsize", fontSize);
hold off;

figure; hold on; box on;
plot( y15.thresh.logRange / log(10) ...
    , y15.alphaAtTauZero ...
    , "color", "red" ...
    , "linewidth", 1 ...
    );
xlabel("Detection Threshold Flux [ergs / s / cm^2]", "interpreter", "tex", "fontsize", fontSize);
ylabel("\alpha at Efron-Petrosian Tau Statistic \tau = 0", "interpreter", "tex", "fontsize", fontSize);
hold off;



