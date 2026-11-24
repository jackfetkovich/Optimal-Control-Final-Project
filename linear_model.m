%% ============================================================
%  EQUILIBRIUM AND LINEARIZATION

% Generator parameters
Mmat = diag(M);
Dmat = diag(d);

% Weighted adjacency matrix: 1 / reactance
Aw = zeros(n);
mask = W > 0;
Aw(mask) = 1 ./ W(mask);

% 1. Equilibrium phase angles
delta0 = deg2rad(linspace(50,60,n)');
omega0 = zeros(n,1);

%%2. Equilibrium inputs
angleDiff = delta0 - delta0.';

Pe0 = sum(Aw .* sin(angleDiff),2);

u0 = Pe0;

fprintf('\nEquilibrium inputs:\n');
disp(u0);

% 3. Effective Laplacian
% Weights are cos(angle difference) / reactance

Keff = Aw .* cos(angleDiff);

Leff = diag(sum(Keff,2)) - Keff;

% 4. Construct A and B
A = [zeros(n), eye(n);
    -Mmat\Leff, -Mmat\Dmat];

B = [zeros(n);
    Mmat\eye(n)];