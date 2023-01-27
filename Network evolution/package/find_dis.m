function cur_dis = find_dis(adjm, in, out)
%will returns the distance between 'in' and 'out' nodes.

%If both nodes are equal:
if(in == out)
    cur_dis = -1;
    return
end

%Start from inflow node then check existing paths:
idx = find(adjm(in,:));

%check for out in distance 0:
if( adjm(in, out) == 1 )
    cur_dis = 0;
    return
end

n = size(adjm,1);

%Check for each entry of idx:
cur_dis = 1;
is_found = 0;
k = 1;
while(is_found == 0)
    %'idx' will grow at each iteration in the loop, capturing more and more
    %nodes until it matches requested distance:
    idx = find( any(adjm(idx, :)) );
    
    cur_dis = cur_dis +1;

    if(any(nonzeros(idx) == out))
        %we found it!
        is_found = 1;
    else
        if(k > n)
            %we should have visited all the nodes at least once, but we
            %can't. It means that the graph is disconnected and that there
            %is no path between in and out. too bad. Thus we set 'cur_dis'
            %to -1:
            cur_dis = -1;
            break;
        end
    end
    k=k+1;
end

%makes it '0-based' indexed (remove this line if you want it '1-based'):
%'0-based' : minimal distance (two connected nodes) is 0
%'1-based' : minimal distance (two connected nodes) is 1
cur_dis = cur_dis-1;


