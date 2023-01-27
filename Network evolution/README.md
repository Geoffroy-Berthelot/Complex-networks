# Scale-free and lattice network evolution
This is the Matlab/C++ code used for evolving a number of scale-free or lattice networks.

Please refer to the following articles for more information:

(*i*) Kang, MY., Berthelot, G., Tupikina, L. et al. Morphological organization of point-to-point transport in complex networks. Sci Rep 9, 8322 (2019). https://doi.org/10.1038/s41598-019-44701-6

(*ii*) Berthelot, G., Tupikina, L., Kang, MY. et al. Pseudo-Darwinian evolution of physical flows in complex networks. Sci Rep 10, 15477 (2020). https://doi.org/10.1038/s41598-020-72379-8

## Usage
The usage is straight-forward:
1. modify the parameters in the 'main.m' file, and run it. The simulation will proceed and the results will be dumped in the /results folder.
2. once you have your results ready, you can then run the 'build_results.m' file to build a MATLAB structure 'RES' (which is dumped as 'RES.mat' in the root directory). 
This structure contains:
- a $6 \times n$ array (with $n$ the total number of simulations) and with the following columns: [$N_0$, $\beta$, $\gamma$, strategy, $\Delta$, topology] (see articles above for more information)
- 

A sample code for building a figure using RES.mat is provided below:


A number of parameters can be changed in the 'main.m' file, including the topology of the network (scale-free or lattice), 

