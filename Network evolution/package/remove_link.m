function [G, removed_link] = remove_link(G, i, j, F)
%Remove link at indice i, j in network G

%Gather info from the nodes i & j, whose links will be removed in the subsequent code:
%Do not gather potential, as 'Potential' list is updated on the fly 
%(ie. each time a node is removed, the corresponding potential is also removed):

%node 'i'
removed_link.degree(1) = G.degree(i);
removed_link.XY(1) = G.XY(i);
removed_link.distance_source(1) = F(G.adjm, i, G.inflow);
removed_link.distance_drain(1) = F(G.adjm, i, G.outflow);
%node 'j'
removed_link.degree(2) = G.degree(j);
removed_link.XY(2) = G.XY(j);
removed_link.distance_source(2) = F(G.adjm, j, G.inflow);
removed_link.distance_drain(2) = F(G.adjm, j, G.outflow);

%symetric matrix (with a '-' difference)
G.fluxes(i,j) = NaN;            %set value to NaN
G.fluxes(j,i) = NaN;            %set value to NaN

%symmetric matrix
G.dis_eucl(i,j) = NaN;          %set distance to NaN
G.dis_eucl(j,i) = NaN;          %set distance to NaN

%symmetric matrix
G.adjm(i,j) = 0;                %set adjacency matrix link to 0
G.adjm(j,i) = 0;                %set adjacency matrix link to 0

G.degree(i) = G.degree(i) - 1;  %update degree list from node i.
G.degree(j) = G.degree(j) - 1;  %update degree list from node j.

