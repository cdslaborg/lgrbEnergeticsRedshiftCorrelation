clc;
%clear all;
%close all;
%clear classes;
format compact; format long;

addpath(genpath("../../../../libmatlab/"),"-begin")

% change MATLAB's working directory to the folder containing this script

filePath = mfilename('fullpath');
[currentDir,fileName,fileExt] = fileparts(filePath); cd(currentDir);
cd(fileparts(mfilename('fullpath'))); % Change working directory to source code directory.

% generate Y15 object

y15 = AnalysisY15(true,0.0);
