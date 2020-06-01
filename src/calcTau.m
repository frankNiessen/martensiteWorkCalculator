function [Tau] = calcTau(varargin)
%function [Tau] = calcTau(sigma,m,n,mode,varargin)
% Input
%  sigma - stress @tensor
%  m - normal vector the the slip or twinning plane
%  n - Burgers vector (slip) or twin shear direction (twinning)
%  mode - 'Twinning' 'Slip' or 'TRIP'
% Output
% Stucture Tau containing:
%  tauMax - maximum shear stress
%  m      - active plane
%  n      - active direction
%  tau    - shear stresses with respect to all planes
% Options
% symmetrise - consider also all symmetrically equivalent planes and directions
%
% See Also
%% Varargin
if isa(varargin{1},'tensor') && isa(varargin{2},'Miller') && isa(varargin{2},'Miller') && isa(varargin{4},'char') %Plane direction Schmid law
   calcMode = 'SchmidLaw';
   sigma = varargin{1}; m = varargin{2}; n = varargin{3}; mode = varargin{4};  
elseif isa(varargin{1},'tensor') && isa(varargin{2},'double') && length(size(varargin{2}))>1 && isa(varargin{3},'char') %Shape deformation matrix  
   calcMode = 'ShapeDeformation';
   sigma = varargin{1}; F = varargin{2}; mode = varargin{3}; 
end
%% Calculate Tau
if strcmpi(calcMode,'SchmidLaw')
   tau = calcSchmid(sigma,m,n,varargin);
elseif strcmpi(calcMode,'ShapeDeformation')
   tau = calcShapeDef(sigma,F,varargin);
end

%% Determine maximum resolved shear stress (Tau)
if size(tau,1)>1
  if strcmpi(mode,{'Slip'})
     [~,ind] = max(abs(tau));                                               % For slip systems
       tauMax = abs(tau(sub2ind(size(tau),ind,1:size(tau,2))));
  elseif any(strcmpi(mode,{'Twinning'}))
     [~,ind] = max(subplus(tau));                                          % For twin systems --> subplus enforces the directionality condition
      tauMax = tau(sub2ind(size(tau),ind,1:size(tau,2)));
  elseif strcmpi(mode,{'TRIP'})
     [~,ind] = max(tau);
      tauMax = tau(sub2ind(size(tau),ind,1:size(tau,2)));
  else
      error(['No valid deformation mechanism ''',mode,'''']);
  end
else
  if strcmpi(mode,{'Slip'})
      tauMax = abs(tau);    
  elseif any(strcmpi(mode,{'TRIP','Twinning'}))
      tauMax = tau;      
  end
  ind = ones(size(tauMax));
end

%% Output structure
Tau.max = tauMax;
Tau.all = tau;
Tau.ind = ind;

if strcmpi(calcMode,'SchmidLaw')
    Tau.mMax = m(ind);
    Tau.nMax = n(ind);  
    Tau.m = m;
    Tau.n = n;
elseif strcmpi(calcMode,'ShapeDeformation')
    Tau.F = F;   
end
end
%% Calculate tau by Schmid factor method
function tau = calcSchmid(sigma,m,n,varargin) 
    %% Apply symmetry
if check_option(varargin,'symmetrise')   
  [m,~] = symmetrise(m,'antipodal');                                       %Get equivalent slipplanes
  [n,~] = symmetrise(n,'antipodal');                                       %Get equivalent slipdirections
  [r,c] = find(isnull(dot_outer(vector3d(m),vector3d(n))));                %Find orthogonal pairs
  assert(~isempty(r)||~isempty(c),'Slip planes and directions are not perpendicular') %Errorcheck
  m = m(r);                                                                %Reduce to orthogonal slipplanes
  n = n(c);                                                                %Reduce to orthogonal slipdirections
else
  assert(length(m)==length(n),'Number of planes and directions must be the same.'); %Errorcheck
end

%% Plot slipsystems
if check_option(varargin,'plot')
   figure;
   c = hsv(size(n,2)); 
   for i = 1:size(n,2)
       plot(n(i),'antipodal','markerfacecolor',c(i,:),'markersize',12,'Marker','d'); 
       hold on
       plot(m(i),'antipodal','plane','linewidth',2,'color',c(i,:));
   %    plot(m(i),'markerfacecolor',c(i,:),'markersize',12,'Marker','o'); 
   end
   set(gcf,'units','normalized','position',[0.1 0.1 0.4 0.7],'name','Slipsystems'); %Set figure properties
end
%% Compute SchmidTensors and resolved shear stress (Tau)
tau = zeros(length(m),length(sigma));
for i = 1:length(m)
%   R = SchmidTensor(m(i),n(i),varargin{:}); 
%   tau(i,:) = EinsteinSum(R,[-1 -2],sigma,[-1 -2]); %[cos(theta)*cos(rho)]
%EDITED Frank Niessen 2019/11/20 from schmidFactor.m
  tau(i,:) = double(EinsteinSum(sigma,[-1,-2],m(i),-1,n(i),-2));
end
end
%% Calculate tau with shape deformation matrices
function tau = calcShapeDef(sigma,F,varargin)
for i = 1:size(sigma,1)
   for sol = 1:size(F,3)
      tau(sol,i) = trace((F(:,:,sol)-eye(3))*sigma(i).matrix);     
   end
end
end
%% Make plane normal and direction orthogonal
function [mOut,nOut] = mkOrthogonal(mIn,nIn)
%function [mOut,nOut] = mkOrthogonal(mIn,nIn)
%Make almost perpendicular vectors m and n perpendicular with minimal
%adjustment
%m,n: Miller (MTEX)
%mOut,nOut: Miller (MTEX)
m = vector3d(mIn);                                                         %Convert to vector 3d
n = vector3d(nIn);                                                         %Convert to vector 3d
mnMean = mean([m,n]);                                                      %Find mean vector of m and n
mnOrth = cross(m,n);                                                       %Find perpendicular vector to m and n
a = rotation('axis',mnOrth,'angle',45*degree)*mnMean;                      %Rotate mean vector around perpendicular vector by +45°
b = rotation('axis',mnOrth,'angle',-45*degree)*mnMean;                     %Rotate mean vector around perpendicular vector by -45°
%Identify and assign new vectors
if angle(a,m) < angle(b,m)
    mOut = Miller(a',mIn.CS);
    nOut = Miller(b',nIn.CS);
else
    mOut = Miller(b',mIn.CS);
    nOut = Miller(a',nIn.CS);   
end
%Output of applied angular adjustments 
fprintf('\nVector m and n were rotated by %.4f° and %.4f° to become perfectly orthogonal\n',angle(mIn,mOut)/degree,angle(nIn,nOut)/degree)
end
