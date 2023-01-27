function G = build_graph(T, N0, p_gamma)

if(strcmp(T.topo, 'scale-free') == 1) %scale-free network
    G = build_UCMgraph(N0, p_gamma);
else
    if(strcmp(T.topo, 'lattice') == 1) %lattice graph
        G = build_lattice_graph(N0, T.dimension, T.periodic_conditions);
    else
        error('wrong network configuration, please check ''Topologies'' in the ''main.m'' script');
    end
end

%visual inspection here for lattice graphs (2D):
% figure;
% 
% hold on;
% for i=1:size(G.XY,1)
%     plot(G.XY(i,1), G.XY(i,2), 'k.', 'Markersize', 30);
%     
%     idx = find(G.adjm(i,:)); %find connected nodes
%     
%     %draw a line:
%     for j=1:size(idx,2)
%         plot([G.XY(i,1), G.XY(idx(j),1)], [G.XY(i,2), G.XY(idx(j),2)], 'k-', 'linewidth', 2);
%     end
% end
% axis square;
% axis on;

%visual inspection here for lattice graphs (3D):
% figure;
% hold on;
% plot3(G.XY(:,1), G.XY(:,2), G.XY(:,3), 'k.', 'Markersize', 30);
% for i=1:size(G.XY,1)
%     idx = find(G.adjm(i,:)); %find connected nodes
%     %draw a line:
%     for j=1:size(idx,2)
%         plot3([G.XY(i,1), G.XY(idx(j),1)], [G.XY(i,2), G.XY(idx(j),2)], [G.XY(i,3), G.XY(idx(j),3)], 'k-', 'linewidth', 2);
%     end
% end
% axis square;
% axis off;
% view(50,25);

