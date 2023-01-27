function [r, c] = pick_weakest_link( fluxes )
%Select the link that has the smallest amount of flux.

V = min( fluxes( fluxes > 0) ); %Find value of weakest positive flow

[r, c] = find( fluxes==V ); %find its corresponding index

if(size(r,1) > 1)
    % we have several similar identical minimal fluxes values!
    % we remove the first one:
    r = r(1);
    c = c(1);
end


