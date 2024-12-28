% Define parameters
lambda = 1.1e-10;   % Transmission coefficient
alpha = 0.8;        % Progression rate to chronic infection
gamma = 0.85;       % Treatment recovery rate
u = 0.9;            % Uptake factor (proportion of diagnosed individuals treated)
% Diagnosis rate (delta): Varying to see the effect
delta_values = [0.001, 0.005, 0.01]; % Different diagnosis rates to test
colors = ['r', 'g', 'b'];           % Colors for the plots
% Initial conditions
Ia0 = 27421;                % Acutely infected population
Ic0 = 1209654;              % Chronically infected population
T0 = 500000;                     % Treated population
R0 = 0;               % Recovered population
N = 104000000;              % Total population
S0 = N - Ia0 - Ic0 - T0 - R0; % Susceptible population
% Time span (3 years)
tspan = [0, 3*365];
figure; hold on;
for i = 1:length(delta_values)
   delta = delta_values(i);         % Current diagnosis rate
   tau = delta * u;                 % Calculate treatment rate
   % Define the system of differential equations
   hcv_model = @(t, y) [
       -(lambda * y(1)) * (y(2) + y(3));                   % dS/dt
       (lambda * y(1) * (y(2) + y(3))) - alpha * y(2);     % dIa/dt
       (alpha * y(2)) - (tau * y(3));                      % dIc/dt
       (tau * y(3)) - (gamma * y(4));                      % dT/dt
       gamma * y(4)                                       % dR/dt
   ];
   % Initial state vector
   y0 = [S0, Ia0, Ic0, T0, R0];
   % Solve the system using ode45
   [t, y] = ode45(hcv_model, tspan, y0);
   % Extract solutions
   S = y(:, 1);
   Ia = y(:, 2);
   Ic = y(:, 3);
   T = y(:, 4);
   R = y(:, 5);
   % Plot chronic infections for each diagnosis rate
   plot(t/365, Ic, colors(i), 'LineWidth', 1.5, 'DisplayName', ...
        sprintf('\\delta = %.3f', delta));
end
% Add labels and legend
xlabel('Time (years)');
ylabel('Chronic Infected Population (I_c)');
title('Impact of Diagnosis Rate on Chronic Infections');
legend('Location', 'Best');
grid on;
hold off;



