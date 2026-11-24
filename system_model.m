n = 16;

% Fully connected groups of four generators
areas = {
    [1 2 3 4]
    [5 6 7 8]
    [9 10 11 12]
    [13 14 15 16]
};

% Inter-area connections
interEdges = [
     4  5
     4 10
     4 13
     5 10
     5 13
    10 13
];

% Build adjacency matrix
Adj = zeros(n);

for a = 1:4
    nodes = areas{a};

    for i = 1:4
        for j = i+1:4
            Adj(nodes(i),nodes(j)) = 1;
            Adj(nodes(j),nodes(i)) = 1;
        end
    end
end

for k = 1:size(interEdges,1)
    i = interEdges(k,1);
    j = interEdges(k,2);

    Adj(i,j) = 1;
    Adj(j,i) = 1;
end

% Graph Laplacian
L = diag(sum(Adj,2)) - Adj;

% Unweighted adjacency matrix
Adj = double(abs(L) > 1e-12);
Adj(1:n+1:end) = 0;
Adj = double((Adj + Adj.') > 0);

% Assign four areas
areaID = repelem((1:4)',4);

% Generator inertia and damping
rng(10); % Reproducible parameters

% Similar inertia within each area, but unique
M = zeros(n,1);
Mbase = [3.5; 4.5; 5.5; 6.5];

for i = 1:n
    M(i) = Mbase(areaID(i)) + 0.02*i;
end

% Unique damping values within allowed range
d = linspace(0.10,0.40,n)';

% Assign line reactances
% Short lines: approximately 0.10 pu
% Long lines: approximately 0.90 pu

W = zeros(n);

[ei,ej] = find(triu(Adj,1));
nEdges = length(ei);

shortCount = 0;
longCount = 0;

for k = 1:nEdges
    i = ei(k);
    j = ej(k);

    if areaID(i) == areaID(j)
        shortCount = shortCount + 1;
        wij = 0.100 + 0.0005*shortCount;
    else
        longCount = longCount + 1;
        wij = 0.900 + 0.001*longCount;
    end

    W(i,j) = wij;
    W(j,i) = wij;
end

% Initial equilibrium
% Angles between 50 and 60 degrees
delta0 = deg2rad(linspace(50,60,n)');
omega0 = zeros(n,1);

% Electrical power at the chosen equilibrium
Pe0 = zeros(n,1);

for k = 1:nEdges
    i = ei(k);
    j = ej(k);

    Pij = sin(delta0(i)-delta0(j))/W(i,j);

    Pe0(i) = Pe0(i) + Pij;
    Pe0(j) = Pe0(j) - Pij;
end

% Choose turbine inputs to satisfy equilibrium
u0 = Pe0;