function R = one_network_simulation(T, N0, d, p_gamma, p_beta, S, is_mex, F)
%performs one simulation:
%- construct the network
%- evolve the network
%- gather results

%-----Build UCM graph:
G = build_graph(T, N0, p_gamma);

%-----Cast the adjacency matrix as an uint8 type (see 'INIT.m' for more explanations):
G.adjm = uint8(G.adjm);

%-----Assign distances between nodes:
[G.dis_eucl] = get_distances(G.XY, G.adjm, p_beta); %Build distances impact according to beta

%-----Assign distance between source and drain (sink):
[G.inflow, G.outflow, distance_sinksource] = get_sink_source(G.adjm, d, F);

if( distance_sinksource == -1 )
    %sink / source may not be connected due to a failure in the linking
    %algorithm (may occur with high gamma values)
    R.error_assign = 1;
    return;
else
    if( distance_sinksource == -2 )
        R.error_assign = 1;
        warning('Could not assign source and drain nodes due to the requested \Delta value. Try to use a smaller \Delta value.');
        return;
    else
        G.error_assign = 0;
        G.distance_SS = distance_sinksource;
    end
end

%push essential info about the network to the 'R' structure.
G.n_nodes = N0;
G.gamma = p_gamma;
G.strategy = S;
G.beta = p_beta;
if(strcmp(T.topo, 'lattice') == 1)
    G.config = 'lattice';
else
    G.config = 'scale-free';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ATTACK THE NETWORK
% (remove the weaskest links until there remains no flux between inflow and outflow)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
is_exit = 0;
is_warning = 0;
k = 1;

R = {};
RN = {};
RL = {};
while(1)
    
    [G.Potentials, G.fluxes, is_warning] = get_flow(G, is_mex); %Compute the flow
    
    %===Gather statistics and figures data:
    R = gather_evol_statistics(G, R, RN, RL, k, is_warning);
    
    %===Apply pruning strategy:
    if( is_warning == 0 )
        if( S == 0 )
            [r, c] = pick_random_link( G.adjm ); %Remove random link
        else
            if( S == 1 )
                [r, c] = pick_weakest_link( G.fluxes ); %Remove weakest link
            else
                if( S == 2 )
                    [r, c] = pick_strongest_link( G.fluxes ); %Remove strongest link
                end
            end
        end
        
        % remove selected link:
        [G, RL] = remove_link(G, r, c, F);
        
        % returns distance between source and sink
        cur_dis = F(G.adjm, G.inflow, G.outflow);
    end
    
    %if(sum(sum(~isnan(G.fluxes),2)) == 0 || is_exit == 1 || cur_dis == -1 || G.is_warning == 1)
    if(is_warning == 1 || cur_dis == -1 || sum(sum(~isnan(G.fluxes),2)) == 0)
        %We stop because either:
        % - no more fluxes are existing,
        % - a warning was raised due to singular matrix (subgraphs)
        % - is_exit flag is 'on'
        % - the source and sink are disconnected
        break; %we exit.
    end
    
    [G, RN, is_exit] = clean_network(G, F); %then remove single nodes
        
    if(is_exit == 1)
        %we removed either the sink or source, thus we exit.
        break;
    end
    
    k=k+1;
end


