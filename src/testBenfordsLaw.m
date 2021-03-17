%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Test Benford's Law on various datasets                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;
filePath = mfilename('fullpath');
[currentDir,fileName,fileExt] = fileparts(filePath); cd(currentDir);
cd(fileparts(mfilename('fullpath'))); % Change working directory to source code directory.

% Options
fontSize = 13;
lineWidth = 1.5;
figureColor = "white";
dataset = "synSamFlux"; % must be "Y15", "P16", "T17", "L19", "synSamFlux", or "synSamFluence"

% Begin code
if strcmpi(dataset,"Y15")
    load("../out/Y15/Y15.mat");
    ndata = length(sim.lisoEiso);
    yint = sim.lisoEiso;
elseif strcmpi(dataset,"P16")
    load("../out/P16/P16.mat");
    ndata = length(sim.lisoEiso);
    yint = sim.lisoEiso;
elseif strcmpi(dataset,"T17")
    load("../out/T17/T17.mat");
    ndata = length(sim.lisoEiso);
    yint = sim.lisoEiso;
elseif strcmpi(dataset,"L19")
    load("../out/L19/L19.mat");
    ndata = length(sim.lisoEiso);
    yint = sim.lisoEiso;
elseif strcmpi(dataset,"synSamFlux")
    load("../out/synSam/synSamflux.mat");
    ndata = synSam.ndata;
    yint = synSam.yint;
elseif strcmpi(dataset,"synSamFluence")
    load("../out/synSam/synSamfluence.mat");
    ndata = synSam.ndata;
    yint = synSam.yint;
else
    error("Invalid dataset choice");
end
    
Y = zeros(1,ndata);
for i = 1:ndata
    a = char(string(yint(i)));
    Y(i) = str2double(a(1));
end

figure("color", figureColor); hold on; box on;
    histogram(Y, "normalization", "probability");
    title(dataset + " Test for " + ndata + " data points", "fontsize", fontSize);
    xlabel("First Digit","interpreter", "tex", "fontsize", fontSize);
    ylabel("Probability","interpreter", "tex", "fontsize", fontSize);
hold off;