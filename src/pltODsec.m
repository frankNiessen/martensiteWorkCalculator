function [hfig, hax] = pltODsec(OD,data,label,varargin) 
scrPrnt('SubStep','Plotting OD section');
hfig = figure;                                                             % Create figure
if check_option(varargin,'smooth')
    OD.sec.plot(data,'smooth');                                            % Plot ODF section
else
    OD.sec.plot(data,'linestyle','none');                                  % Plot ODF section
end
set(gcf,'name',label);                                                     % Set figure name
colorbar;                                                                  % Colorbar
% cMap = open('cMap.mat');
% colormap(gca,cMap.cm);
mtexColorMap jet                                                           % Colormap
%mtexColorMap blue2red                                                     % Colormap
hax = gca;