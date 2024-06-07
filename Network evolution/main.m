%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main file for simulating the transport in complex and lattices networks.
%
% Please refer to the following papers:
% (i) Kang, MY., Berthelot, G., Tupikina, L. et al. Morphological organization of point-to-point transport in complex networks. Sci Rep 9, 8322 (2019). https://doi.org/10.1038/s41598-019-44701-6
% (ii) Berthelot, G., Tupikina, L., Kang, MY. et al. Pseudo-Darwinian evolution of physical flows in complex networks. Sci Rep 10, 15477 (2020). https://doi.org/10.1038/s41598-020-72379-8
%
% This program:
% - Uses full matrices only
% - Does not use Matlab graph functions
% 
% The simulation stops for 4 conditions:
% (i) no path exists between the source and the drain (i.e. the source and drain are disconnected)
% (ii) either the source or drain are removed from the network,
% (iii) a portion of the network —a subgraph containing one or more node— is disconnected 
% from the rest of the network containing the source and drain.
% (iv) the flux is 0
%
% Copyright (C) <2023> Geoffroy Berthelot, Min-Yeong Kang, Liubov
% Tupikina, Denis Grebenkov, Bernard Sapoval
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----Size of the network N0 = N * N (scale-free and for 2d lattices)
% examples: 
% N0 = [50*50, 70*70]; %for scale-free networks of size N0={2500, 4900}
% N0 = [5*5*5, 10*10*10]; %for 3d lattices of size N0={125, 1000}
N0 = 10*10;

%-----Topology of the network T
% Two topologies: Scale-free or nd-grid Lattice
% Example: T.topo = 'scale-free' or T.topo = 'lattice'
T.topo = 'scale-free';
% ****** dimension (lattice networks) ******
% for T.topo = 'ndgrid', the dimension (T.dimension) should be provided
% high dimensions request large ressources (memory and processor)
T.dimension = 2;
% ****** periodic conditions (lattice networks) ******
% could be either: 0 for 'open' boundaries or 1 for periodic boundaries
T.periodic_conditions = 1;
% ****** gamma (scale-free networks) ******
% parameter of the discrete degree distribution function P(k) ~ k^(-\gamma)
% example:
% T.gamma = [1.5, 2.0, 2.5, 3.0, 4.0, 5.0, 6.0]; %can be a vector of gamma
% velues to test
T.gamma = 2.3;

%-----Distance (\Delta) between source and drain nodes:
% is the requested minimal distance (in number of nodes) between inflow and outflow node.
% Delta = -1 means we assign randomly the source and drain nodes without searching for a minimal (specific) distance.
% example:
% if Delta = 4 then will only keep networks that have a distance >= 4 between the source and drain nodes
% Warning: if \Delta is too high, the algorithm won't find a solution and return a warning & error.
Delta = 0;

%-----Beta:
% beta defines the relation-ship with distance, could be a vector in order 
% to test different values of beta (example: beta = [-1,0,1];;)
% beta = -1 : inverse-relationship with euclidean distance
% beta = 0 : no effect of distance 
% beta = 1 : typical effect of euclidean distance
% beta = 2 : power-2 effect of euclidean distance
p_beta = 0;

%-----Strategy:
strategy = 'minimal';
%defines strategies for pruning the network's links, possible options are: 
%'random' : will remove links randomly (S = 0)
%'minimal': will remove the link with the minimal flux (the first one found
%if equal values) (S = 1)
%'strongest': will remove the link with the strongest flux (the first one
%found if equal values) (S = 2)

%-----Simulation parameters:
n_sims = 1e3;        %number of simulations (realizations) to perform per configurations

% ****** Computer parameters ******
recompile_mex = 0;  %recompile mex file (if needed, else will try to re-use the provided compiled MEX-file).
is_mex = 1;         %use mex file?
is_parallel = 1;    %Should parallel computing be used?
override = 3;       %one could choose to override the number of physical
%cores when paralleling the computations, thus is override == 3; will use 3
%cores instead of machine capacity.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIALIZATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run('package\INIT_.m'); %call the INIT script.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SIMULATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
network_simulations( param );
t = toc;
fprintf(1, 'total time = %5fs (approx.)\n', t);

CLEAN_; %call the cleaning script.


