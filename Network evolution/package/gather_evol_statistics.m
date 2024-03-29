function R = gather_evol_statistics(G, R, RN, RL, k, is_warning)
%gather statistics related to the evolution process

if(k == 1) %initial construction (no evolution)
    %Copy initial parameters:
    R.n_nodes = G.n_nodes;
    R.gamma = G.gamma;
    R.strategy = G.strategy;
    R.beta = G.beta;
    R.Topology = G.config;
    R.error_assign = G.error_assign;
    
    %Save source and drain indexes:
    R.source_idx = G.inflow;
    R.sink_idx = G.outflow;
    R.dis_source_sink = G.distance_SS;
    
    %degree of the source and drain:
    R.degree_source = G.degree(G.inflow);
    R.degree_drain = G.degree(G.outflow);
    
    R.n_nodes_evol(k) = G.n_nodes;
    R.n_links(k) = size(nonzeros(G.adjm),1)/2; %return the number of links
    
    %Total flux:
    R.Q_(k) = -sum(G.fluxes(G.inflow,~isnan(G.fluxes(G.inflow,:)))); %compute total flux from the source node only
else
    % the flux cannot be computed if the network has multiple components
    % (ie. the graph was plitted into multiple subgraphs).
    % we avoid this case by looking at the 'is_warning' warning:
    if(is_warning == 0)
        %We collect the following information at each evolution step:
        %(feel free to remove '%' in the followinf sections if you wish to collect more information):
        
        %%%%%%%%%%%%%%%%%%%%%%%
        %% Removed nodes info
        %%%%%%%%%%%%%%%%%%%%%%%
        %we additionnaly want to save some info on each deleted node ('RN' structure) and each deleted link ('RL' structure), ie.:
        %- distance (in number of nodes) from source and drain
        %- degree
        %- Potential
        %R.removed_nodes_list{k} = RN;   %'RN' holds the removed nodes info.
        %R.removed_links_list{k} = RL;   %'LN' holds the removed links info.
        
        %%%%%%%%%%%%%%%%%%%%%%%
        %% Number of nodes
        %%%%%%%%%%%%%%%%%%%%%%%
        %R.n_nodes_evol(k) = size(G.adjm,1);
        
        %%%%%%%%%%%%%%%%%%%%%%%
        %% Number of links (L)
        %%%%%%%%%%%%%%%%%%%%%%%
        R.n_links(k) = size(nonzeros(G.adjm),1)/2; %return the number of links
        
        %%%%%%%%%%%%%%%%%%%%%%%
        %% Total flux (Q)
        %%%%%%%%%%%%%%%%%%%%%%%
        R.Q_(k) = -sum(G.fluxes(G.inflow,~isnan(G.fluxes(G.inflow,:)))); %compute total flux from the source node only
    end
end

