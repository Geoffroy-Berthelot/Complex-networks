%INIT_ script that handles all initializations-------------

%-----Folder inits
addpath('../package');
addpath('../toolboxes/MIT_Toolbox');

%-----Warning inits
%ensure warnings are thrown for the following exceptions:
warning('on', 'MATLAB:SingularMatrix');
warning('on', 'MATLAB:nearlySingularMatrix');

%-----Mex-files compilation (if required):
% Matlab default type is 'double'. The adjacency matrix contains two values only: '0' and
% '1'. This matrix is better described as an array of 'int' rather than an array of
% 'double'. We change the type of the adjacency matrix in the 'one network
% simulation.m' Matlab file to 'uint8', which is the smallest possible Matlab numeric integer 
% type in order to use less memory. The C/C++ version of these files uses accordingly 'uint8_t' 
% as the default type for the adjacency matrix.
%
% Please note that we also propose 'double' implementations of these C/C++ % files 
% (check in the mex-files folder) and change the following lines if you
% wish to use the 'double' implementations. If you do so, then remove the 
% G.adjm = uint8(G.adjm); line in 'one network simulation.m', otherwise it
% will crash.
%
% Limitations:
% The C/C++ files use the 'uint32_t' type (32bit version), which limits N_0 to 2^32 ~ 4.2 * 10^9 Nodes
% For larger N_0, change type: uint32_t to uint64_t in C/C++ files (for example).
if(is_mex && recompile_mex)
    % for 'uint8_t' type implementation, use the following,
    % but be careful to cast the adjacency matrix as a 'uint8_t' type in Matlab
    % (see the 'one network simulation.m' Matlab file)
    mex ../package/mex-files/prepare_sys_full.c;
    mex ../package/mex-files/find_dis_full.cpp;
    mex ../package/mex-files/compute_q_full.c;
    
    % for 'double' type implementation, use the following:
    %mex ../package/mex-files/prepare_sys_full_double.c;
    %mex ../package/mex-files/find_dis_full_double.cpp;
    %mex ../package/mex-files/compute_q_full_double.c;
end

%-----make sure all alpha and beta values are unique:
p_beta = unique(p_beta);
if( strcmp(T.topo, 'lattice') == 1 )
    T.gamma = NaN;
else
    T.gamma = unique(T.gamma);
    T.dimension = NaN; %remove dimension for scale-free networks
    T.periodic_conditions = NaN;
end

%-----RNG: make sure to shuffle the RNG to have different realizations at each call:
rng('shuffle');

%-----set the value of 'S' regarding the strategy:
% '0' is 'random' (removes a random link)
% '1' is 'minimal' (removes link with the minimal flux value)
% '2' is 'strongest' (removes link with the maximal vlue value)
if(strcmp(strategy,'random') == 1)
    fprintf(1,'''*%s'' strategy for evolution\n', strategy);
    S = 0;
else
    if(strcmp(strategy,'minimal') == 1)
        fprintf(1,'''*%s'' strategy for evolution\n', strategy);
        S = 1;
    else
        if(strcmp(strategy,'strongest') == 1)
            fprintf(1,'''*%s'' strategy for evolution\n', strategy);
            S = 2;
        else %default strategy:
            fprintf(1,'''*%s'' strategy for evolution \n', strategy);
            S = 0;
        end
    end
end

%-----Append parameters to structure:
param.N0 = N0;
param.Delta = Delta;
param.S = S;
param.p_beta = p_beta;
param.n_sims = n_sims;
param.is_mex = is_mex;
param.is_parallel = is_parallel;
param.override = override;
param.topology = T;

clear N0 Delta S p_beta n_sims is_mex is_parallel override T

%-----Set parallel pool:
if(param.is_parallel)
    %Init parallel pool:
    mPool = Start_MultiCores_Env_2017(param.override);
end

%-----Verbose:
%--distance choice:
if(param.Delta >= 0) 
    fprintf(1,'*using minimal distance (d=%d) betwen source and drain nodes\n', param.Delta);
else
    fprintf(1,'*random distance between source and drain nodes\n');
end

%--total number of sims:
fprintf(1, 'Total number of simulations is %d\n', length(param.N0) * length(param.topology.gamma) * length(param.p_beta) * param.n_sims);
pause(1);
