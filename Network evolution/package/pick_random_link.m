function [r, c] = pick_random_link( adjm )
%Select a random link.

%retrieve the number of links from the adjacency matrix: 
[a, b] = find(adjm); %it doesnt matter if matrix is symmetric, since we pick randomly

%assign random link:
idx = randi(size(a,1));
r = a(idx);
c = b(idx);
