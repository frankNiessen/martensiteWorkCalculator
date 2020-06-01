function OD = cmptOD(CS,OD,SS)
% function o = computeOD(P,OD,SS)
% Sets up Phi section plots and orientation grids
%% Ini
section      = OD.info{1};
sectionAngle = OD.info{2};
gridRes      = OD.info{3};
%% Define OD section
switch section
    case 'phi1'
        OD.sec = phi1Sections(CS,SS);
    case 'Phi'
        OD.sec = PhiSections(CS,SS);
    case 'phi2'
        OD.sec = phi2Sections(CS,SS);
end
%% Define grid
OD.sec.(section) = sectionAngle*degree;
OD.grid = OD.sec.makeGrid('resolution',gridRes*degree);
OD.grid.SS = SS;

%% Manual input solution
% k = 0;
% for phi2 = 1:size(OD.phi2,2)
%    for Phi = 1:size(OD.Phi,2)
%         for phi1 = 1:size(OD.phi1,2)
%            k = k+1;
%            o(k) = orientation(rotation('Euler',OD.phi1(phi1)*degree,...
%                   OD.Phi(Phi)*degree,OD.phi2(phi2)*degree),P.CS,SS);
%         end
%     end
% end
