%% TITANIUM beta->alpha''
% For reproduction of results from 
% [F. Niessen, E. V. Pereloma, A. A. Saleh, Predicting the available work 
% from deformation induced ?’’ martensite formation in metastable ? 
% Ti-alloys, J. Appl. Crystallogr. (2020).]
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
OD.info = {'phi2',45,5};                                                   %ODF section parameters: {Section dimension, section angle [Â°], resolution [Â°]}
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

%% STEEL gamma->alpha'
% For reproduction of results from 
% [A. Creuziger, T. Foecke, Transformation potential predictions for the
% stress-induced austenite to martensite transformation in steel, 
% Acta Mater. 58 (2010) 85–91. doi:10.1016/j.actamat.2009.08.059.]
scrPrnt('SegmentStart','Initialization');
% ******************* Crystal Systems and crystal orientation
% *** Parent Crystal
cif.A = 'Fe-gamma_CreuzigerFoecke_ActaMat_2010';                           %Parent cif name
CS.A = loadCIF(cif.A);                                                     %Load parent cif
% *** Child crystal
cif.B = 'Fe-alpha_CreuzigerFoecke_ActaMat_2010';                           %Daughter cif name
CS.B = loadCIF(cif.B);                                                     %Load daughter cif
% *** Martensite Crystallography
Def.calcMode = 'ShapeDeformation';                                         %Choose 'SchmidFactor', 'BainDeformation' or 'ShapeDeformation'
Def.SPa = [1; 0; 1];                                                       %Lattice invariant deformation plane (Twinning or Slip)
Def.SDa = 'twinning';                                                      %Lattice invariant deformation direction (Slip) or 'twinning' for automated determination of twinning direction
Def.bCa = [1 -1 0; 1 1 0;0 0 1];                                           %Lattice correspondance matrix [uvwD*OR.LCM*uvwP]
Def.ORtype  = 'PTMC';                                                      %Theoretical orientation relationship of Lattice Transformation Matrix ('LTM') or from PTMC solution ('PTMC')
Def.LISvars = 'all';                                                       %Lattice invariant transformation twin variants - 'all' or 'lowestM1' for using all variant solutions or the onew with lowest LIS magnitude
%*******************  Orientations and Stress states
%*** Orientation distribution (OD)
OD.info = {'phi2',45,5};                                                   %ODF section parameters: {Section dimension, section angle [Â°], resolution [Â°]}
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
