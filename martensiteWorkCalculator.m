% *************************************************************************
% Martensite Work Calculator - v.0.2
% *************************************************************************
% Frank Niessen, University of Wollongong, EMC , 06/2020
% contactnospam@fniessen.com (remove the nospam to make this email address
% work)
% Ahmed A. Saleh, University of Wollongong, School of Mechanical, Materials, 
% Mechatronics and Biomedical Engineering
% -------------------------------------------------------------------------
% Mapping of available work from martensite formation as a function of
% parent crystal orientation and external stress state
% -------------------------------------------------------------------------
% Execution of the software requires installation of
% mtex (http://mtex-toolbox.github.io/)
% -------------------------------------------------------------------------
% License file in root-directory
%% Startup
clc; clear all; close all; clear hidden; fclose('all');
folder = fileparts(which(mfilename));                                      % Determine where your m-file's folder is.
addpath(genpath(folder));                                                  % Add that folder plus all subfolders to the path.
scrPrnt('StartUp','DEF.-MODE ANALYZER, v.0.2','silent');
try MTEXmenu; catch; startup_mtex; end                                     % Startup m-tex
%% Initializization
scrPrnt('SegmentStart','Initialization');
% ******************* Crystal Systems and crystal orientation
% *** Parent Crystal
cif.A = 'Beta_InamuraEtAl_PhilMag_2007_16Nb_3Al';                          %Parent cif name
CS.A = loadCIF(cif.A);                                                     %Load parent cif
% *** Child crystal
cif.B = 'ADP_InamuraEtAl_PhilMag_2007_16Nb_3Al';                           %Daughter cif name
CS.B = loadCIF(cif.B);                                                     %Load daughter cif
% *** Martensite Crystallography
Def.calcMode = 'ShapeDeformation';                                         %Choose 'SchmidFactor', 'BainDeformation' or 'ShapeDeformation'
Def.SPa = [1; 0; 1];                                                       %Lattice invariant deformation plane (Twinning or Slip)
Def.SDa = 'twinning';                                                      %Lattice invariant deformation direction (Slip) or 'twinning' for automated determination of twinning direction
Def.bCa = [1 0 0; 0 0.5 -0.5;0 0.5 0.5];                                   %Lattice correspondance matrix [uvwD*OR.LCM*uvwP]
Def.ORtype  = 'LTM';                                                       %Theoretical orientation relationship of Lattice Transformation Matrix ('LTM') or from PTMC solution ('PTMC')
Def.LISvars = 'lowestM1';                                                  %Lattice invariant transformation twin variants - 'all' or 'lowestM1' for using all variant solutions or the onew with lowest LIS magnitude
%*******************  Orientations and Stress states
%*** Orientation distribution (OD)
OD.info = {'phi2',45,5};                                                   %ODF section parameters: {Section dimension, section angle [°], resolution [°]}
SS = specimenSymmetry('mmm');                                              %Specimen Symmetry (determines range of OD section)
% *** Applied stress state
% Set [1|0] index below predefined stress state to activate of deactivate;
% define new stress states in cmptSigma.m
Sig.labels = {'RD_T','RD_PS','BB','TD_PS','TD_T','TD_DD','TD_S','RD_EX','RD_C','RD_SH','BB_C','TD_SH','TD_C','TD_EX','RD_S','RD_DD'};
Sig.choice = [  1       1      1     1      1       1      1       1      1       1      1       1      1       1      1       1];
Sig.choice = find(Sig.choice);
% *** Postprocessing settings
Post.cLim = [];                                                            %Colorrange Contour Plots [min max] (keep empty for automatic limits)
Post.saveImgs = 0;                                                         %Save images [0|1]
Post.path = GetFullPath('data\output\images');                             %Out path to save images
%NO EDITING RECOMMENDED FROM HERE ON **************************************
%% PreProcessing
scrPrnt('SegmentStart','Preprocessing');
% *******************   Write stress tensor
scrPrnt('Step',sprintf('Defining %.0f Stress tensors',length(Sig.labels(Sig.choice))));
[Sig.ten] = cmptSigma(Sig.labels(Sig.choice));                             %Get stress tensors
% Compute Orientation distribution section
scrPrnt('Step',sprintf('Defining %s OD section at %.0f�',OD.info{1},OD.info{2}));
OD = cmptOD(CS.A,OD,SS);                                                   %Compute parent OD
% *******************   Initialize deformation mode
scrPrnt('SegmentStart','Initializing deformation mode');
% Calculating PTMC solution
scrPrnt('Step','Calculating PTMC solution');   
PTMC = mainPTMC(CS.A,CS.B,Def.SPa,Def.SDa,Def.bCa);                        %Compute PTMC solution
OR = cmptOR(CS,Def,PTMC);                                                  %Compute orientation relationship and variants
PTMC = analyzePTMC(PTMC,Def,CS,OR,Post,'symmetrise');                      %Analyze PTMC solution
%% Compute Schmid factors and plot OD sections1
scrPrnt('SegmentStart','Computing Schmid factors');
for i=1:length(Sig.ten)
    scrPrnt('Step',sprintf('%.0f/%.0f: Stress state %s',i,length(Sig.ten),Sig.labels{Sig.choice(i)}));
    Sig.tenRot{i} = rotate(Sig.ten{i},rotation(inv(OD.grid)));             %Transform stress tensor from specimen to crystal coordinates
    scrPrnt('SubStep','Computing Available Work');
    [SF{i},U{i}] = cmptTransPot(Sig.tenRot{i},PTMC,Def);                   %Compute Schmid factors
    [h.fig(i), h.ax(i)] = pltODsec(OD,SF{i}.max,['ODF_',...
                          Sig.labels{Sig.choice(i)}],'smooth');            %Plot OD section   
end
%% PostProcessing
scrPrnt('SegmentStart','Post-Processing');
scrPrnt('Step','Define common colorbar limits for all OD-sections');
tmp = [SF{:}]; 
if isempty(Post.cLim); Post.cLim = [min(min([tmp.max])) max(max([tmp.max]))]; end; clear tmp
for i=1:length(h.ax)
    caxis(h.ax(i),Post.cLim);
end
tileFigs;                                                                  % Distribute figures
scrPrnt('Termination','All Done!');
