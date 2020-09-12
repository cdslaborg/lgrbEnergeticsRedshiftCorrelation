close all;
clear all;
format compact; format long;
filePath = mfilename('fullpath');
[scriptPath,fileName,fileExt] = fileparts(filePath); cd(scriptPath);

addpath(genpath('../../../../libmatlab/')) % added by josh

% read Swift time table

datPath = '../data/';
%fileExtension = ".pdf";


outPath = '../../out/simulation/';
kfacType = 'OneThird';

ZoneRequested = 1;
bivarPlotsRequested = 1;
bivarFigExportRequested = 1;
fontSize = 13;
SynSam.Path.root = '../../../../20181213_BatseLgrbRedshift/git/___SyntheticSample___/'; % added by Josh
SynSam.Path.output = [SynSam.Path.root,'winx64/intel/release/static/serial/bin/out/kfac',kfacType,'/'];
SynSam.Path.input = [SynSam.Path.root,'in/'];

% import BATSE data

Dummy = importdata([SynSam.Path.input,'batse_1366_lgrb_pbol_epk_sbol(0.001,20000).txt']);
Batse.LogData.Obs = [ Dummy.data(:,2) ... % logPbol
                    , Dummy.data(:,4) ... % logEpk
                    , Dummy.data(:,3) ... % logSbol
                    , Dummy.data(:,8) ... % logDur
                    ];
Batse.Data.Obs = exp(Batse.LogData.Obs);
Batse.ngrb = length(Batse.Data.Obs(:,1));
Batse.Trigger = Dummy.data(:,1);


% read synthetic data
ZModel.ID = {'H06','L08','B10'};    %,'B04','F00','Y04'};

ZModel.count = length(ZModel.ID);

ZPath = cell(ZModel.count,1);
for imodel = 1:ZModel.count
    ZPath{imodel} = [SynSam.Path.root,'../zestimation/winx64/intel/release/static/serial/kfac',kfacType,'/',ZModel.ID{imodel},'/bin/out/'];
end

nvar = 4;
VarPair = zeros(20,2);
VarPair(1:6,1:2)    = [ 1, 2 ... logLiso-logEpkz
                      ; 1, 3 ... logLiso-logEiso
                      ; 1, 4 ... logLiso-logDurz
                      ; 3, 2 ... logEiso-logEpkz
                      ; 3, 4 ... logEiso-logDurz
                      ; 4, 2 ... logDurz-logEpkz
                      ];
VarPair(7:12,1:2) = VarPair(1:6,1:2) + 4;
VarPair(13:20,1:2)  = [ 9, 1 ... redshift-logLiso
                      ; 9, 2 ... redshift-logEpkz
                      ; 9, 3 ... redshift-logEiso
                      ; 9, 4 ... redshift-logDurz
                      ; 9, 5 ... redshift-logPbol
                      ; 9, 6 ... redshift-logEpk
                      ; 9, 7 ... redshift-logSbol
                      ; 9, 8 ... redshift-logDur
                      ];

VarName = {'Liso','Epkz','Eiso','Durz','Pbol','Epk','Sbol','T90','Redshift','RedshiftPlusOne'};%,'LumDis'};
AxisLabel = { 'Bolometric Peak Luminosity: L_{iso} [ ergs/s ]' ...
            , 'Intrinsic Spectral Peak Energy: E_{pz} [ keV ]' ...
            , 'Isotropic Radiated Energy: E_{iso} [ ergs ]' ...
            , 'Intrinsic Duration: T_{90z} [ s ]' ...
            , 'Bolometric Peak Flux: P_{bol} [ ergs/s/cm^2 ]' ...
            , 'Observed Spectral Peak Energy: E_{p} [ keV ]' ...
            , 'Bolometric Fluence: S_{bol} [ ergs/cm^2 ]' ...
            , 'Observed Duration: T_{90} [ s ]' ...
            , 'Redshift: z' ...
            , 'z + 1' ...
            };
Log10VarLim =   [ 46, 56 ... log10Liso
                ; 0 , 5  ... log10Epkz
                ; 46, 56 ... log10Eiso
                ; -1, 4  ... log10Durz
                ; -13, -2 ... log10Pbol
                ; -1 , 4 ... log10Epk
                ; -15, 0 ... log10Sbol
                ; -1, 4  ... log10Dur
                ; -1, 1.5  ... redshift
                ; 0, 2  ... redshift+1
                ];
VarLim =        [ 5.e46, 1.e55  ... log10Liso
                ; 1.e0 , 3.e4  ... log10Epkz
                ; 1.e46, 3.e56 ... log10Eiso
                ; 5.e-2, 2.e3  ... log10Durz
                ; 1.e-13, 1.e-2 ... log10Pbol
                ; 2.e-1 , 1.e4 ... log10Epk
                ; 1.e-13, 1.e0 ... log10Sbol
                ; 1.e-1, 5.e3  ... log10Dur
                ; 1.e-1, 3.5e1  ... redshift
                ; 1.e0, 3.6e1  ... redshift+1
                ];

outPathSynSam =  getFullPath(fullfile(outPath,'SynSam_kfac',kfacType,'/'));%[outPath,'SynSam_kfac',kfacType,'/'];
if ~exist(['kfac',kfacType],'dir'); mkdir(outPathSynSam); end

nVarPair = length(VarPair);
for iVarPair = [5,13,15,16] %1:nVarPair

    disp(['processing variable pairs # ', num2str(iVarPair)]);

    for imodel = 1:ZModel.count

        if ~isfield(ZModel,ZModel.ID{imodel})

            ZModel.(ZModel.ID{imodel}).Synthetic = importdata([SynSam.Path.output,'syntheticSample',ZModel.ID{imodel},'.csv']);
            ZModel.(ZModel.ID{imodel}).Synthetic.data(:,1:8) = exp( ZModel.(ZModel.ID{imodel}).Synthetic.data(:,1:8) );

        end

        synBegin = 1;
        synEnd = length(ZModel.(ZModel.ID{imodel}).Synthetic.data(:,1));%13660;
        ZModel.(ZModel.ID{imodel}).Synthetic.count = synEnd-synBegin+1;

        if bivarPlotsRequested

            if bivarFigExportRequested
                figure('visible','off','Color','none');
            else
                figure;
            end
            hold on; box on;

            colormap('cool');
            % get the matrix containing that colormap, then flip the matrix to invert the colormap.
            %cmap = colormap; cmap = flipud(cmap); colormap(cmap);

            %Mask = zeros( length(ZModel.(ZModel.ID{imodel}).Synthetic.data(:,1)) , 1 ); Mask(synBegin:synEnd) = 1;
            Mask = ZModel.(ZModel.ID{imodel}).Synthetic.data(synBegin:synEnd,10)>-1; % Josh made this change 10 to 14, plots using SWift detection threshold
            %Mask = ZModel.(ZModel.ID{imodel}).Synthetic.data(synBegin:synEnd,end)>0.5;
            %Mask = log10 (     ZModel.(ZModel.ID{imodel}).Synthetic.data(:,11) ) ... Nbol
            %     - log10 ( 0.5*ZModel.(ZModel.ID{imodel}).Synthetic.data(:,8) ) > log10(3);

            VarPairX = VarPair(iVarPair,1);
            DataX = ( ZModel.(ZModel.ID{imodel}).Synthetic.data( Mask , VarPairX ) );
            if VarPairX==9 && ZoneRequested % corresponding to redshift variable
                DataX = DataX + 1.0;
                VarPairX = VarPairX + 1;
            end

            VarPairY = VarPair(iVarPair,2);
            DataY = ( ZModel.(ZModel.ID{imodel}).Synthetic.data( Mask , VarPairY ) );
            if VarPairY==9 && ZoneRequested % corresponding to redshift variable
                DataY = DataY + 1.0;
                VarPairY = VarPairY + 1;
            end

            
            if iVarPair ~=16
                scatter ( DataX ...
                        , DataY ...
                        ..., 0.75*ones(ZModel.(ZModel.ID{imodel}).Synthetic.count,1) ...
                        , 0.75*ones(sum(Mask),1) ...
                        , ZModel.(ZModel.ID{imodel}).Synthetic.data(Mask,10) ...
                        ..., log10 ( ZModel.(ZModel.ID{imodel}).Synthetic.data(Mask,11) ) ... Nbol
                        ...- log10 ( 0.5*ZModel.(ZModel.ID{imodel}).Synthetic.data(Mask,8) ) ... duration
                        ..., ZModel.(ZModel.ID{imodel}).Synthetic.data(Mask,13) ...
                        ... , ZModel.(ZModel.ID{imodel}).Synthetic.data(Mask,14) ... %josh changed 13 to 14
                        , '.' ..., 'filled' ...
                        )
            else
                scatter ( DataX ...
                        , DataY ...
                        ..., 0.75*ones(ZModel.(ZModel.ID{imodel}).Synthetic.count,1) ...
                        , 0.75*ones(sum(Mask),1) ...
                        , ZModel.(ZModel.ID{imodel}).Synthetic.data(Mask,10) ...
                        ..., log10 ( ZModel.(ZModel.ID{imodel}).Synthetic.data(Mask,11) ) ... Nbol
                        ...- log10 ( 0.5*ZModel.(ZModel.ID{imodel}).Synthetic.data(Mask,8) ) ... duration
                        ..., ZModel.(ZModel.ID{imodel}).Synthetic.data(Mask,13) ...
                        ..., ZModel.(ZModel.ID{imodel}).Synthetic.data(Mask,13) ... %josh changed 13 to 14
                        , '.' ..., 'filled' ...
                        )
            end    
            
            
            CBar = colorbar;
            CBar.Label.String = 'Probability of Detection by BATSE LADs';

            CBar.Label.Interpreter = 'tex';
            CBar.Label.FontSize = fontSize;



            set(gca,'xscale','log','fontsize',fontSize);
            set(gca,'yscale','log','fontsize',fontSize,'YDir','normal');

            xlim( VarLim(VarPairX,:) );
            ylim( VarLim(VarPairY,:) );
            xlabel(AxisLabel{VarPairX}, 'Interpreter', 'tex', 'fontSize', fontSize);
            ylabel(AxisLabel{VarPairY}, 'Interpreter', 'tex', 'fontSize', fontSize);
            legend  ( {['Simulated LGRB: ',ZModel.ID{imodel},' Rate']} ...
                    , 'location' , 'southwest' ...
                    , 'fontSize' , fontSize ...
                    , 'color' , 'none' ...
                    , 'box', 'off' ...
                    );

            set(gca, 'color', 'none', 'fontsize', fontSize);
            if bivarFigExportRequested
                fileName = [outPathSynSam,VarName{VarPairX},VarName{VarPairY},ZModel.ID{imodel},'.png'];
                export_fig (fileName,'-m4 -transparent');
                hold off; close(gcf);
            else
                hold off;
            end

        end % bivarPlotsRequested

    end % imodel

end









