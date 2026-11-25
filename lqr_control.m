clc; clear; close all;

run("system_model.m");
run("linear_model.m");

% --------------------------------------------------------------------
Q = zeros(32);

Q(20,20) = 10;
Q(21,21) = 10;
Q(26,26) = 10;
Q(29,29) = 10;

R = 0.8*eye(16);

r = zeros(32,1);
r([20 21 26 29]) = 0.1*60*2*pi;
[K,P,eigCL] = lqr(A,B,Q,R);
Acl = A - B*K;

s_are = Acl' \ (Q*r);

% 5. Initial condition
xe = [delta0; omega0];
x0 = xe;
x0(1) = x0(1) + deg2rad(2);

% 6. Nonlinear simulation
tspan = [0 60];

f = @(t,x) f_lqr(t,x,M,d,W,ei,ej, ...
    u0,K,s_are,R,B,xe);
opts = odeset('RelTol',1e-8,'AbsTol',1e-10);
[t,x] = ode45(f,tspan,x0, opts);

% 7. Plot angle deviations
delta = x(:,1:n);
omega = x(:,n+1:2*n);

figure;
subplot(1,2,1);
plot(t,rad2deg(delta-delta0'),'LineWidth',1.2);
grid on;
xlabel('Time (s)');
ylabel('Angle Deviation (deg)');
title('LQR Controlled Rotor Angles');

% 8. Plot frequency deviations
subplot(1,2,2);
plot(t,omega/(2*pi),'LineWidth',1.2);
hold off;
xlabel('Time (s)');
ylabel('Frequency Deviation (Hz)');
title('LQR Controlled Frequency');

function dx = f_lqr(~,x,M,d,W,ei,ej,u0,K,S,R,B,xe)

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

% Deviation from nominal equilibrium
xdev = x-xe;

% LQR tracking control
du = -K*xdev - R\(B'*S);

% Total mechanical input
u = u0 + du;

% Nonlinear dynamics
ddelta = omega;
domega = (u-d.*omega-Pe)./M;

dx = [ddelta; domega];
end