clc; clear; close all;

run("system_model.m");
run("linear_model.m");

%% TABLE 1: OPEN-LOOP EIGENVALUES AND MODAL PROPERTIES
lambda = eig(A);

% Numerical tolerance
tol = 1e-7;

% Identify eigenvalue types
zeroIdx = abs(lambda) < tol;

realIdx = abs(imag(lambda)) < tol & ~zeroIdx;

complexIdx = imag(lambda) > tol;

% Extract eigenvalues
zeroEig = lambda(zeroIdx);
realEig = lambda(realIdx);
complexEig = lambda(complexIdx);

% Sort oscillatory modes by natural frequency
[~,idx] = sort(abs(complexEig),'ascend');
complexEig = complexEig(idx);

% Verify eigenvalue counts
fprintf('\nEIGENVALUE VERIFICATION\n');
fprintf('Zero eigenvalues: %d\n',numel(zeroEig));
fprintf('Nonzero real eigenvalues: %d\n',numel(realEig));
fprintf('Complex conjugate pairs: %d\n',numel(complexEig));


% Calculate modal properties
sigma = real(complexEig);
omega_d = imag(complexEig);

omega_n = sqrt(sigma.^2 + omega_d.^2);

% Damping ratio
zeta = -sigma ./ omega_n;

% Oscillation frequency in Hz
f_d = omega_d/(2*pi);

% Format eigenvalue pairs
eigPairs = strings(length(complexEig),1);

for k = 1:length(complexEig)
    eigPairs(k) = sprintf('%.5f +/- j%.5f', ...
        sigma(k),omega_d(k));
end

%% Generate Table 1
Table1 = table( ...
    eigPairs, ...
    zeta, ...
    omega_n, ...
    'VariableNames', ...
    {'Eigenvalue_Pair', ...
     'Damping_Factor', ...
     'Natural_Frequency_rad_s'});

disp(' ');
disp('TABLE 1: OPEN-LOOP OSCILLATORY MODES');
disp(Table1);

%%Display remaining eigenvalues
fprintf('\nZero eigenvalue:\n');
disp(zeroEig);

fprintf('Negative real eigenvalue:\n');
disp(realEig);

% Optional: export to CSV
%writetable(Table1,'Table1_OpenLoopModes.csv');

% Plot open-loop eigenvalues
figure;
plot(real(lambda),imag(lambda),'bx', ...
    'MarkerSize',9,'LineWidth',1.5);
hold on;
xline(0,'k--');
yline(0,'k--');
grid on;

xlabel('Real Part (1/s)');
ylabel('Imaginary Part (rad/s)');
title('Open-Loop Eigenvalues of the 16-Generator System');