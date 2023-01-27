function network_simulations( P )
% start the network simulations.
% 'P' : structure of parameters for the simulations.

%Set variables and functions:
S = P.S;
mexd = P.is_mex;
nsims = P.n_sims;
T = P.topology;

%Create function handle depending on the mex option:
if( P.is_mex == 1 )
    F = @find_dis_full; 
else
    F = @find_dis;
end

%***** Run simulations *****
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Running simulations.
%% If 'scale-free' topology is selected, then the program will iterate through
%% \gamma values. If 'lattice' is selected thend the programm will not 
%% iterate through \gamma values (see INIT script) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:length(P.N0) %for each network size
    for i = 1:length(T.gamma) %for each gamma value
        for j = 1:length(P.p_beta) %for each beta value

            %***** Parallel *****
            if(P.is_parallel)
                c_N0 = P.N0(k);
                c_gamma = T.gamma(i);
                c_beta = P.p_beta(j);
                c_Delta = P.Delta;
                R_temp = cell(1, nsims);

                parfor n = 1:nsims
                    error_assign = 1;
                    while(error_assign == 1)
                        fprintf(1,'sim: N0=%d, gamma=%.2f, beta=%.1f (%d/%d) ...', c_N0, c_gamma, c_beta, n, nsims);
                        c_try = one_network_simulation(T, c_N0, c_Delta, c_gamma, c_beta, S, mexd, F);
                        
                        if(c_try.error_assign == 0)
                            error_assign = 0;
                            R_temp{n} = c_try;
                            fprintf(1,' ok\n');
                        else
                            fprintf(1,' failed, retry\n');
                        end
                    end
                end
                
                %Then append to existing structure:
                fprintf(1,'Appending results...');
                s_idx = 1+(j-1)*nsims;
                e_idx = s_idx + nsims -1;
                R(s_idx:e_idx) = R_temp;
                fprintf(1,' ok\n');

                %***** not parallel *****
            else
                for n = 1:nsims
                    c_N0 = P.N0(k);
                    c_gamma = T.gamma(i);
                    c_beta = P.p_beta(j);
                    c_Delta = P.Delta;
                    error_assign = 1;
                    
                    while(error_assign == 1)
                        fprintf(1,'sim: N0=%d, gamma=%.2f, beta=%.1f (%d/%d) ...', c_N0, c_gamma, c_beta, n, nsims);
                        c_try = one_network_simulation(T, c_N0, c_Delta, c_gamma, c_beta, S, mexd, F);
                        
                        if(c_try.error_assign == 0)
                            error_assign = 0;
                            R{n+(j-1)*P.n_sims} = c_try;
                            fprintf(1,' ok\n');
                        else
                            fprintf(1,' failed, retry\n');
                        end
                    end
                end
            end
        end

        %dump result to disk:
        fprintf(1, 'Dump result to /results folder:\n');
        Export(R);
    end
end
