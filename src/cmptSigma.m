function [MOut] = cmptSigma(label)
%% Read in Stress tensors
M.RD_T  = [1 0 0; 0 0 0; 0 0 0];                                           %Uniaxial tension along RD
M.RD_PS = [2/sqrt(3) 0 0; 0 1/sqrt(3) 0; 0 0 0];                           %Plane strain along RD
M.BB    = [1 0 0; 0 1 0; 0 0 0];                                           %Balanced Biaxial tension
M.TD_PS = [1/sqrt(3) 0 0; 0 2/sqrt(3) 0; 0 0 0];                           %Plane strain along TD
M.TD_T  = [0 0 0; 0 1 0; 0 0 0];                                           %Uniaxial tension along TD
M.TD_DD = [-1/sqrt(7) 0 0; 0 2/sqrt(7) 0; 0 0 0];                          %Deep drawing along TD
M.TD_S  = [-1/sqrt(3) 0 0; 0 1/sqrt(3) 0; 0 0 0];                          %Pure shear with TD positive
M.RD_EX = [-2/sqrt(7) 0 0; 0 1/sqrt(7) 0; 0 0 0];                          %Extrusion along RD
M.RD_C  = [-1 0 0; 0 0 0; 0 0 0];                                          %Compression along RD
M.RD_SH = [-2/sqrt(3) 0 0; 0 -1/sqrt(3) 0; 0 0 0];                         %Shrinking along RD
M.BB_C  = [-1 0 0; 0 -1 0; 0 0 0];                                         %Balanced Biaxial compression
M.TD_SH = [-1/sqrt(3) 0 0; 0 -2/sqrt(3) 0; 0 0 0];                         %Shrinking along TD
M.TD_C  = [0 0 0; 0 -1 0; 0 0 0];                                          %Compression along TD
M.TD_EX = [1/sqrt(7) 0 0; 0 -2/sqrt(7) 0; 0 0 0];                          %Extrusion along TD
M.RD_S  = [1/sqrt(3) 0 0; 0 -1/sqrt(3) 0; 0 0 0];                          %Pure shear with RD positive
M.RD_DD = [2/sqrt(7) 0 0; 0 -1/sqrt(7) 0; 0 0 0];                          %Deep drawing along RD

%% Write Output stress tensors
k = 0;
for i = 1:length(label)
    if isfield(M,label{i})
       k = k+1;
       MOut{k} = tensor(M.(label{i}),'propertyname',['Stress ',label{i}],'rank',2);
    else
       error(sprintf('\nStress state ''%s'' is not defined!\n',label{i}));
    end
end