function build_results()
%%%%%%%%%%%%%%%%%
%% Build results (t_c values) from folder '/results'
%%%%%%%%%%%%%%%%%

addpath('package');

%'results' structure is:
%[N_0, \beta, \gamma, strategy, \Delta, topology, pair number];
%'strategy' is the following:
% random strategy = 0
% pseudo-darwinian strategy = 1
% strongest strategy = 2
%'topology' is the following:
% scale-free = 1
% lattice = 2
% We store the number of links and Q (total flux) for each evolution.
% The final 'results' structure is then stored in the 'RES.mat' file at the
% root of this project.

%----------------------- GATHER DATA ----------------------------
fprintf(1,'retrieve info from ''results\'' folder for the following files:\n');
RES = build_data_set( 'results\' );
save('RES.mat','RES','-v7.3');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTION build_data_set()
function RES = build_data_set( folder_name )
D = dir(folder_name);
n = size(D,1); %number of files

RES.infos = [];
ked = 1;
ked2 = 1;
for k=3:n
    
    %LOAD FILE AND GATHER INFOS------
    %standard files:
    load(strcat(folder_name, '/', D(k).name));
    fprintf(1, 'load %s...', D(k).name);
    R = deserialize(R_ser);
    clear R_ser; %free some memory on the fly
    
    %Group by parameters:
    for ii=1:size(R,2) %(1) for the number of realizations
        %Build final index structure:
        %[N_0, \beta, \gamma, strategy, \Delta, topology, pair number];
        A(ii, 1) = R{ii}.n_nodes;
        A(ii, 2) = R{ii}.beta;
        A(ii, 3) = R{ii}.gamma;
        A(ii, 4) = R{ii}.strategy; %evolution strategy
        A(ii, 5) = R{ii}.dis_source_sink; %\Delta
        if( strcmp(R{ii}.Topology, 'scale-free') == 1 )
            A(ii, 6) = 1; %scale free network
        else
            if( strcmp(R{ii}.Topology, 'lattice') == 1 )
                A(ii, 6) = 2; %lattice
            else
                A(ii, 6) = NaN; %unknown topology
            end
        end
        
        %Append to larger structure:
        if( isfield( R{ii}, 'Q_') == 1 )
            RES.total_flux{ked} = R{ii}.Q_;
        end

        if( isfield( R{ii}, 'n_links') == 1 )
            RES.n_links{ked} = R{ii}.n_links;
        end

        ked = ked +1;
    end

    RES.infos = [RES.infos; A];
    clear A;
    
    fprintf(1, 'ok\n');
end

rmpath('package');





