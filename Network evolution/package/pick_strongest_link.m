function [r, c] = pick_strongest_link( fluxes )
%Select the link that has the strongest amount of flux.

V = max( max(fluxes) ); %Find value of strongest positive flow

[r, c] = find( fluxes==V ); %find its corresponding index

if(size(r,1) > 1)
    % we have several similar identical maximal fluxes values!
    % we only use the first one:
    r = r(1);
    c = c(1);
end

