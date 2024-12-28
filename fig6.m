% Define parameters
lambda = 1.1e-10;   % Base transmission coefficient
alpha = 0.85;       % Progression rate to chronic infection
tau = 0.005;        % Treatment rate
gamma = 0.85;       % Treatment recovery rate
% Seasonal transmission rates
lambda_high = 3 * lambda; % High transmission during peak periods
lambda_low = lambda;  % Low transmission during off-peak periods
% Time periods for high and low transmission (in days)
t_high_start = 90;   % Start of high-transmission period (e.g., spring)
t_high_end = 180;    % End of high-transmission period (e.g., summer)
% Initial conditions
Ia0 = 27421;                % Acutely infected population
Ic0 = 1209654;              % Chronically infected population
T0 = 500000;                % Treated population
R0 = 0;                     % Recovered population
N = 104000000;              % Total population
S0 = N - Ia0 - Ic0 - T0 - R0; % Susceptible population
% Initial state vector
y0 = [S0, Ia0, Ic0, T0, R0];
% Time span (3 years)
tspan = [0, 3*365];
% Time-dependent transmission rate (lambda)
lambda_stepwise = @(t) (t >= t_high_start & t <= t_high_end) * lambda_high + ...
                      (t < t_high_start | t > t_high_end) * lambda_low;
% Define the system of differential equations using an anonymous function
hcv_model = @(t, y) [
   -(lambda_stepwise(t) * y(1)) * (y(2) + y(3));           % dS/dt
   (lambda_stepwise(t) * y(1) * (y(2) + y(3))) - alpha * y(2); % dIa/dt
   (alpha * y(2)) - (tau * y(3));                          % dIc/dt
   (tau * y(3)) - (gamma * y(4));                          % dT/dt
   gamma * y(4);                                           % dR/dt
];
% Solve the system using ode45
[t, y] = ode45(hcv_model, tspan, y0);
% Extract solutions
S = y(:, 1);
Ia = y(:, 2);
Ic = y(:, 3);
T = y(:, 4);
R = y(:, 5);
% Plot the results
figure;
plot(t/365, S, 'b', 'LineWidth', 1.5); hold on;
plot(t/365, Ia, 'r', 'LineWidth', 1.5);
plot(t/365, Ic, 'm', 'LineWidth', 1.5);
plot(t/365, T, 'g', 'LineWidth', 1.5);
plot(t/365, R, 'k', 'LineWidth', 1.5);
hold off;
% Add labels and legend
xlabel('Time (years)');
ylabel('Population');
title('HCV Dynamics Over Time with Seasonal Variation');
legend('Susceptible (S)', 'Acutely Infected (I_a)', ...
      'Chronically Infected (I_c)', 'Treated (T)', ...
      'Recovered (R)', 'Location', 'Best');
grid on;
fprintf('Sensitivity to lambda (increase by 1%%): %.2f%%\n',lambda_stepwise);