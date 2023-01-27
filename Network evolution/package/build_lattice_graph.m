function cnet = build_lattice_graph(N0, d, periodic_conditions)
%Returns a nd-grid lattice network with 'N0' nodes and dimension 'd'

%-----Check for perfect square (since the graph is mapped on a lattice N*N)
if( ~check_perfect_square(N0, d) )
    warning('''n_nodes'' is not a perfect d-square number: it will be rounded.');
    n_nodes_squarred = round(nthroot(N0, d)); %or round(n_nodes^(1/3))
else
    n_nodes_squarred = nthroot(N0, d); %check for real square roots values
end

% %-----Compute network side array 
% use sqrt(n_nodes)-1 for a spacing of '1' between node (remember the networks are 0-index based)
net_size = n_nodes_squarred-1;  %'size' of the network (1 means the unit square)

% %Build X,Y layout, such that node i is at Xi, Yi:
% S = linspace(0, net_size, n_nodes_squarred);
% 
% %Build nodes structure:
% cnet.layout = S;
% X = ndgrid(S, S);
% Y = X'; 
% cnet.XY = [X(:), Y(:)];
% cnet.dim = d;

if(d == 2)
    %this is a faster approach in O(n)
    cnet = build_2D_lattice(N0, n_nodes_squarred, net_size, periodic_conditions);
else
    if(d > 2) %otherwise standard approach using adjacency matrix properties
        cnet = build_ND_lattice(N0, n_nodes_squarred, net_size, d, periodic_conditions);
    end
end

function c = check_perfect_square(n_nodes, D)
%Return 1 (true) if it is a perfect square.
whole = nthroot(n_nodes, D);
natural = fix(whole);
diff = whole-natural;
c = diff==0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% build a 2-dimensional lattice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cnet = build_2D_lattice(n_nodes, n_nodes_squarred, net_size, periodic_conditions)

%Build X,Y layout, such that node i is at Xi, Yi:
S = linspace(0, net_size, n_nodes_squarred);

%Build nodes structure:
cnet.layout = S;
X = ndgrid(S,S);
Y = X'; %should be replaced by something faster
cnet.XY = [X(:), Y(:)]; %has implications in the 'wire(cnet)' function (see below)
cnet.gamma = NaN; %there is no 'gamma' in this configuration

%Wire lattice (full wiring):
cnet.adjm = wire_2D_(n_nodes, n_nodes_squarred, periodic_conditions);

%Get degrees from lattice's wiring:
cnet.degree = get_degree(cnet.adjm);

function adjm = wire_2D_(N0, N, PC)
%Wire the lattice in a straight-forward way, by taking advantage of the zig-zag indexation from Matlab:

adjm = zeros(N0, N0); %pre-alloc

%By using linspace, the (:) operator in the above function and the fact
%that we know the lattice to be ordered in a upward zig-zag way, we could 
%simply loop through all the nodes of the lattice.
%Corners are hardcoded at following indexes: [1] [n] [s-n] [s]

%wire the lattice:
for i=1:N0
    %(1) catch the corners first.
    if(i == 1) %Top-left corner
        adjm(1, 2) = 1; adjm(2, 1) = 1;     %bottom connexion
        adjm(1, N+1) = 1; adjm(N+1, 1) = 1; %right connexion
        if(PC == 1) %periodic conditions
            adjm(1, N) = 1; adjm(N, 1) = 1;             %top connexion
            adjm(1, N0-N+1) = 1; adjm(N0-N+1, 1) = 1;   %left connexion
        end
    else
        if(i == N) %lower-left corner
            adjm(i, N-1) = 1; adjm(N-1, i) = 1; %top connexion
            adjm(i, 2*N) = 1; adjm(2*N, i) = 1; %right connexion
            if(PC == 1) %periodic conditions
                adjm(i, N0) = 1; adjm(N0, i) = 1;   %left connexion (top connection already done previously)
                adjm(i, N0) = 1; adjm(N0, i) = 1;   %top connexion
            end
        else
            if(i == N0-N+1) %upper-right corner
                adjm(i, i+1) = 1; adjm(i+1, i) = 1; %down connexion
                adjm(i, i-N) = 1; adjm(i-N, i) = 1; %left connexion
                if(PC == 1) %periodic conditions
                    adjm(i, N0) = 1; adjm(N0, i) = 1;   %top connexion (right connection already done previously)
                end
            else
                if(i == N0) %lower-right corner
                    adjm(i, i-N) = 1; adjm(i-N, i) = 1; %top connexion
                    adjm(i, i-1) = 1; adjm(i-1, i) = 1; %left connexion
                    %PC: No connections to specify here as they are already
                    %done in the previous corners
                else
                    %(2) Check for the 4 boundaries.
                    if(i < N) %left bound first
                        adjm(i, i-1) = 1; adjm(i-1, i) = 1; %up connexion
                        adjm(i, i+N) = 1; adjm(i+N, i) = 1; %right connexion
                        adjm(i, i-1) = 1; adjm(i-1, i) = 1; %down connexion
                        if(PC == 1)
                            adjm(i, N0-N+i) = 1; adjm(N0-N+i, i) = 1; %left (to right) connexion
                        end
                    else
                        if(mod(i-1, N) == 0) %top bound
                            adjm(i, i-N) = 1; adjm(i-N, i) = 1; %left connexion
                            adjm(i, i+1) = 1; adjm(i+1, i) = 1; %down connexion
                            adjm(i, i+N) = 1; adjm(i+N, i) = 1; %right connexion
                            if(PC == 1)
                                adjm(i, i+N-1) = 1; adjm(i+N-1, i) = 1; %Up (to down) connexion
                            end
                        else
                            if(mod(i, N) == 0) %bottom bound
                                adjm(i, i-N) = 1; adjm(i-N, i) = 1; %left connexion
                                adjm(i, i-1) = 1; adjm(i-1, i) = 1; %up connexion
                                adjm(i, i+N) = 1; adjm(i+N, i) = 1; %right connexion
                            else
                                if( i > N0 - N ) %right bound
                                    adjm(i, i-1) = 1; adjm(i-1, i) = 1; %up connexion
                                    adjm(i, i-N) = 1; adjm(i-N, i) = 1; %left connexion
                                    adjm(i, i+1) = 1; adjm(i+1, i) = 1; %down connexion
                                else
                                    %(3) normal wiring: N / E / S / W
                                    adjm(i, i-1) = 1; adjm(i-1, i) = 1; %top connexion
                                    adjm(i, i+N) = 1; adjm(i+N, i) = 1; %right connexion
                                    adjm(i, i+1) = 1; adjm(i+1, i) = 1; %bottom connexion
                                    adjm(i, i-N) = 1; adjm(i-N, i) = 1; %left connexion
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% build a N-dimensional lattice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cnet = build_ND_lattice(N0, n_nodes_squarred, net_size, dim, PC)

%Build X,Y layout, such that node i is at Xi, Yi:
S = linspace(0, net_size, n_nodes_squarred);

%create a cell array containing the spatial coordinates for each point.
Z = cell(dim,1);
[Z{:}] = ndgrid(S);

%we need to flat these cell arrays to a nD spatial coordinates sytem.
%For this, we need to read through the layers of the cell arrays:
%for dim=3, we can use the following:
%PX = Z{1};
%PY = Z{2};
%PZ = Z{3};
%Solution = [PX(:), PY(:), PZ(:)];
%A general solution (i.e. for any dim) is to use 'cat' and 'reshape':
cnet.XY = reshape(cat(dim,Z{:}), N0, dim);

cnet.gamma = NaN; %there is no 'gamma' in this configuration

%Wire lattice (full wiring):
cnet.adjm = wire_ND_(N0, dim, PC);

%Get degrees from lattice's wiring:
cnet.degree = get_degree(cnet.adjm);

function adj = wire_ND_(N0, dim, PC)
%Wire the lattice in a straight-forward way:
% General case, for d >= 2 (where 'd' is 'dim'):
% The number of links per node for this dimension is nL = 2 * dim
% Considering the upper triangular part, there are nL/2 = dim diagonals.
% Compute the quantities for each diagonal :
% Starting points are defined by: N0^((i-1)/D) +1 with i ranging from
% [1:dim]
v = 1:dim;
start_points = round(N0.^((v-1) / dim));
%the length of each pattern in each dimension is given by L = round(N0.^(v/dim));
L = round(N0.^(v/dim));
%such that we know the number of repetitions 'rep' for each:
rep = N0 ./ L; %number of repetitions
%disconnections (defined with '0') in each repetitions:
dis = round(N0.^((v-1) / dim));

%pre-alloc:
adj = zeros(N0, N0);

%now compute each diagonal
for i=1:dim-1
    diagVec = ones(L(i), 1);
    diagVec(end-dis(i)+1:end) = 0;
    diagVec = repmat(diagVec, rep(i), 1);
    diagVec = diagVec(1:N0-start_points(i)); %remove trailing zeros.
    adj = adj + diag(diagVec, start_points(i));
end
%append the final diagonal:
diagVec = ones(L(dim) - start_points(dim),1);
adj = adj + diag(diagVec, start_points(dim));

%for (open) periodic boundaries conditions:
if(PC == 1)
    N = nthroot(N0,dim);
    %diagonals start at N^D - N^(D-1)+1, where 'D' is 'dim':
    start_points = N.^v-N.^(v-1)+1;
    trim_points = N0 - start_points+1;
    L = N.^v;       %size of each pattern
    E = N.^(v-1);   %number of '1' (ones) in each pattern
    rep = N0 ./ L;  %number of repetitions for each pattern

    for i=1:dim
        diagVec = repmat([ones(1, E(i)), zeros(1, L(i) - E(i))], 1, rep(i));
        diagVec = diagVec(1:trim_points(i)); %trim trailing zeros
        adj = adj + diag(diagVec, start_points(i)-1);
    end
    
    %tester si tous les noeuds ont bien 2D liens pour dimensions 3,4,5,6 et
    %N0=5 (ou 4)
end

%then copy triu to tril:
adj = adj+adj.';

function degrees = get_degree(adjm)
%returns degree list from adjm matrix:

degrees = sum(adjm,2); %recall sum(adjm,2) == sum(adjm,1)'
