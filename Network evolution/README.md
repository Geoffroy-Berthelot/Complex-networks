# Scale-free and lattice network evolution
This is the Matlab/C++ code used for evolving a number of scale-free or lattice networks.

Please refer to the following articles for more information:

(*i*) Kang, MY., Berthelot, G., Tupikina, L. et al. Morphological organization of point-to-point transport in complex networks. Sci Rep 9, 8322 (2019). https://doi.org/10.1038/s41598-019-44701-6

(*ii*) Berthelot, G., Tupikina, L., Kang, MY. et al. Pseudo-Darwinian evolution of physical flows in complex networks. Sci Rep 10, 15477 (2020). https://doi.org/10.1038/s41598-020-72379-8

## Usage
The usage is straight-forward:
1. modify the parameters in the 'main.m' file, and run it. The simulation will proceed and the results will be dumped in the /results folder.
2. once you have your results ready, you can then run the 'build_results.m' file to build a MATLAB structure 'RES' (which is dumped as 'RES.mat' in the root directory). 

This structure contains the following fields:
- 'infos': a $n \times 6$ array (with $n$ the total number of simulations) and with the following columns: [ $N_0$, $\beta$, $\gamma$, strategy, $\Delta$, topology ] (see articles above for more information),
- 'total_flux': the collection of total flux values $Q$ as numerical vectors for each simulation,
- 'n_links': the collection of the number of links $L$ as numerical vectors for each siumulation

A sample code for building a figure using RES.mat is provided below:
```
%load the structure 'RES':
load('RES.mat');

% Select strategy '0' (random evolution):
idxs_S0 = find(RES.infos(:,4) == 0);
% Select strategy '1' (pseudo-darwinian evolution):
idxs_S1 = find(RES.infos(:,4) == 1);

% Collect the total flux for the random strategy:
for i=1:size(idxs_S0,1)
    Q_S0{i} = RES.total_flux{idxs_S0(i)};
end

% Similarly collect the total flux for the pseudo-darwinian strategy:
for i=1:size(idxs_S1,1)
    Q_S1{i} = RES.total_flux{idxs_S1(i)};
end

% Plot them to a graph:
h = figure;
hold on;
for i=1:size(idxs_S0,1)
    if(i == 1)
        hhh(1) = plot(Q_S0{i} / Q_S0{i}(1), 'b');
    else
        plot(Q_S0{i} / Q_S0{i}(1), 'b');
    end
end

for i=1:size(idxs_S1,1)
    if(i == 1)
        hhh(2) = plot(Q_S1{i} / Q_S1{i}(1), 'g');
    else
        plot(Q_S1{i} / Q_S1{i}(1), 'g');
    end
end

ylim([0, 1.01]);
title('network evolution');
xlabel('t');
ylabel('Q / Q_0');
legend(hhh, 'random', 'pseudo-darwinian');
```

Wich results in the following figure:
![This is an image](/../blob/main/images/CN_Fig0.png)


A number of parameters can be changed in the 'main.m' file, including the topology of the network (scale-free or lattice), 

