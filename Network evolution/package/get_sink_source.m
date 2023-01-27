function [in, out, d] = get_sink_source(adjm, Delta, F)
%Randomly assign the source and drain nodes:

%Randomize vector at the initial stage:
R = randperm(size(adjm,1));

%Pick two random nodes:
in = R(1);
out = R(2);

%F() finds distance between 'in' and 'out' using adjacency matrix 'adjm'
d = F(adjm, in, out);

% check if there is at least one link between the source and drain
% nodes, otherwise we raise an error by setting d = NaN;
if ( d == -1 )
    return;
else
    if (d < Delta) %if a minimal distance is requested (\Delta >= 0):
        %then try all the couples but avoiding i=j. The total number of
        %possible tests is N0(N0-1)/2:
        for i=1:size(R,2)
            for j=i+1:size(R,2)
                if( i ~= j )
                    in = R(i);
                    out = R(j);
                    d = F(adjm, in, out);
                    if( d >= Delta )
                        return
                    end
                end
            end
        end
        %could not find the requested \Delta value, thus drop a warning
        %(see 'one_network_simulation()').
        d = -2;
    end
end
