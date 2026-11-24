clc; clear; close all;

run("system_model.m");

% 6. Initial disturbance
x0 = [delta0; omega0];

% Perturb generator 1 by 2 degrees
x0(1) = x0(1) + deg2rad(2);

% 7. Nonlinear simulation
tspan = [0 60];

f = @(t,x) swing16(t,x,M,d,W,ei,ej,u0);

opts = odeset('RelTol',1e-8,'AbsTol',1e-10);

[t,x] = ode45(f,tspan,x0,opts);

% 8. Extract trajectories
delta = x(:,1:n);
omega = x(:,n+1:2*n);

% Relative angle deviations from equilibrium
delta_dev = rad2deg(delta - delta0');

% 9. Plot angle deviations
figure;
plot(t,delta_dev,'LineWidth',1.2);
grid on;
xlabel('Time (s)');
ylabel('Angle deviation (deg)');
title('16-Generator Rotor Angle Dynamics');

% 10. Plot frequency deviations
figure;
plot(t,omega/(2*pi),'LineWidth',1.2);
grid on;
xlabel('Time (s)');
ylabel('Frequency deviation (Hz)');
title('16-Generator Frequency Dynamics');

% 11. Display assigned parameters
disp(table((1:n)',areaID,M,d, ...
    'VariableNames', ...
    {'Generator','Area','Inertia','Damping'}));

% Local nonlinear dynamics function
function dx = swing16(~,x,M,d,W,ei,ej,u)

    n = length(M);

    delta = x(1:n);
    omega = x(n+1:2*n);

    Pe = zeros(n,1);

    for k = 1:length(ei)
        i = ei(k);
        j = ej(k);

        Pij = sin(delta(i)-delta(j))/W(i,j);

        Pe(i) = Pe(i) + Pij;
        Pe(j) = Pe(j) - Pij;
    end

    ddelta = omega;
    domega = (u - d.*omega - Pe)./M;

    dx = [ddelta; domega];
end
