function var = cmptOR(CS,Def,PTMC)
%% Get OR symmetry matrices
R_mtex = rotation(CS.A.properGroup);
%% Determine OR
if strcmpi(Def.ORtype,'PTMC')
    scrPrnt('Step','Defining Orientation Relationship based on PTMC solution');
    var.OR = orientation('Matrix',PTMC.OR(:,:,4),CS.A,CS.B);
elseif strcmpi(Def.ORtype,'LTM') %% Map OR from Lattice correspondance matrix
    scrPrnt('Step','Defining Orientation Relationship based on lattice correspondance matrix');
    var.OR = orientation('Matrix',PTMC.bTa',CS.A,CS.B);
else
    error('''%s'' is no valid OR-type -> Choose ''PTMC'' or ''LTM''',Def.ORtype);
end
scrPrnt('SubStep',sprintf('OR-Euler angles: [%s]°',num2str([var.OR.phi1,var.OR.Phi,var.OR.phi2]/degree,'%.0f ')));
%% Compute variants
var.ParentOri = orientation('Euler',0,0,0,CS.A);
[var.vars,ind] = unique(R_mtex*var.ParentOri*inv(var.OR));
var.SymRot = R_mtex(ind);
var.SymM = var.SymRot.matrix;
scrPrnt('SubStep',sprintf('Defining %.0f orientation variants',length(var.vars)));