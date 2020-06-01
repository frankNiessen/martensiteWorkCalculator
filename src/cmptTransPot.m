function [SF,U] = cmptTransPot(sigma,PTMC,Def,varargin)
%function SF = cmptSF(tenRot,P)
scrPrnt('SegmentStart','Computing avaliable work');
%% Processing
%Compute shear stress and Schmid factors
scrPrnt('Step',sprintf('Available work based on %s',Def.calcMode));
maxVar = nan(1,size(sigma,1));
maxU = zeros(1,size(sigma,1));
for i = 1:length(PTMC)
    if strcmpi(Def.calcMode,'SchmidFactor')
        U{i} = calcTau(sigma,PTMC{i}.Miller.H.A,PTMC{i}.Miller.d,'TRIP'); 
        U{i}.all = PTMC{i}.m2'.*U{i}.all;
    elseif strcmpi(Def.calcMode,'ShapeDeformation')
        U{i} = calcTau(sigma,PTMC{i}.F,'TRIP');
    elseif strcmpi(Def.calcMode,'BainDeformation')
        U{i} = calcTau(sigma,PTMC{i}.M.A,'TRIP');
    elseif strcmpi(Def.calcMode,'internalFunction')
        U{i} = getStressComponents(PTMC{i},sigma);                         %U.all is d*sigma*HP - multiplication with molarV gives J/mol energy 
    end
    if strcmpi(Def.calcMode,'BainDeformation')
       U{i}.sol = 1;
       U{i}.m2 = [];        
    elseif strcmpi(Def.LISvars,'first') %Only the first variant is chosen
       U{i}.sol = 1;
       U{i}.m2 = PTMC{i}.m2(1);
       U{i}.all = U{i}.all(1,:);
       U{i}.max = U{i}.all;
       if strcmpi(Def.calcMode,'SchmidFactor')
           U{i}.m = U{i}.m(1);
           U{i}.n = U{i}.n(1);
       elseif any(strcmpi(Def.calcMode,{'ShapeDeformation','BainDeformation'}))
           U{i}.F = U{i}.F(:,:,1);
       end
    elseif strcmpi(Def.LISvars,'lowestM1') %Only the energetically favourable variants are chosen
       scrPrnt('Step','Choosing the energetically most favourable variants');
       [~,ind] = sort(PTMC{i}.m1,'ascend');
       U{i}.sol = ind([1 2]);
       U{i}.m2 = PTMC{i}.m2(U{i}.sol);
       U{i}.all = U{i}.all(U{i}.sol,:);
       U{i}.max = max(U{i}.all);
       if strcmpi(Def.calcMode,'SchmidFactor')
           U{i}.m = U{i}.m(U{i}.sol);
           U{i}.n = U{i}.n(U{i}.sol);   
       elseif any(strcmpi(Def.calcMode,{'ShapeDeformation','BainDeformation'}))
           U{i}.F = U{i}.F(:,:,U{i}.sol);
       end
    
    elseif strcmpi(Def.LISvars,'all') %All variants are chosen
       U{i}.sol = 1:4;
       U{i}.m2 = PTMC{i}.m2;
       U{i}.max = max(U{i}.all);
    else 
       error('No valid LIS variant selection option selected');
    end
    if i == 1
       SF.max = U{i}.max; 
    else
       SF.max = max([SF.max; U{i}.max]);
    end
    %Save which variant has highest potential
    maxVar(U{i}.max>maxU) = i;
    maxU(U{i}.max>maxU) = U{i}.max(U{i}.max>maxU);   
end

% Lattice Invariant Shear Twinning
if strcmpi(PTMC{1}.LIS,'Twinning')
    if strcmpi(Def.LISvars,'lowestM1') %Only the energetically favourable variants are chosen
       scrPrnt('SubStep','Twinning LIS: Choosing two variants with lowest LIS magnitude');
    elseif strcmpi(Def.LISvars,'all')
       scrPrnt('SubStep','Twinning LIS: Choosing all four possible variants');
    elseif strcmpi(Def.LISvars,'first')
       scrPrnt('SubStep','Twinning LIS: Choosing first variant only');
    end
    tw(1) = 1-(1+max(PTMC{1}.m1)./min(PTMC{1}.m1)).^(-1);
    tw(2) = (1+max(PTMC{1}.m1)./min(PTMC{1}.m1)).^(-1);
    scrPrnt('SubStep',sprintf('Twinning LIS: Twin-ratio %.2f to %.2f',max(tw),min(tw)));
end
for i = 1:length(PTMC)
    U{i}.maxVar = maxVar;
end
U = cell2mat(U);
end

%% getStressComponents
function U = getStressComponents(PTMC,Sigma)
for sol = 1:size(PTMC.solNr,2) %Loop over solutions
    %Get PTMC solution data
    U.m(:,sol) = PTMC.H.A(:,sol);                                         %Habit plane in parent phase
    U.n(:,sol)  = PTMC.d(:,sol);                                      %Direction of shape change
    for s = 1:length(Sigma)
        U.sigT(:,sol,s) = Sigma(s).M*U.m(:,sol);                          %Traction Sigma_T on habit plane
        U.sigNormal(sol,s) = U.sigT(:,sol,s)'*U.m(:,sol);                 %Normal stress acting along habit plane normal
        U.all(sol,s) = U.sigT(:,sol,s)'*U.n(:,sol);                        %Shear stress acting in habit plane along direction d  Fitting with Schmidtfactor code
        U.sigShear(sol,s) = (U.sigT(:,sol,s)-U.sigNormal(sol,s))'...
                               *U.n(:,sol);                                %Shear stress acting in habit plane along direction d  Fitting with [S. Kundu, H.K.D.H. Bhadeshia, Scr. Mater. 57 (2007) 869–872.]  
    end
end
end




