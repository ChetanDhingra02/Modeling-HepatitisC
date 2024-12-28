% Define parameters
lambda = 1.1e-10;   % Transmission coefficient
alpha = 0.8;        % Progression rate to chronic infection
gamma = 0.85;       % Treatment recovery rate
N = 104000000;      % Total population
target_level = 0.0; % Target chronic infection level (5% of total population)
% Initial conditions
Ia0 = 27421;        % Acutely infected population
Ic0 = 1209654;      % Chronically infected population
T0 = 0;             % Treated population
R0 = 0;             % Recovered population
S0 = N - Ia0 - Ic0 - T0 - R0; % Susceptible population
% Initial state vector
y0 = [S0, Ia0, Ic0, T0, R0];
% Time span (8 years)
tspan = [0, 8*365]; % Time in days (8 years)
% Function to simulate the model and return the chronic infection level
simulateModel = @(tau) ode45(@(t, y) [
   -(lambda * y(1)) * (y(2) + y(3));                       % dS/dt
   (lambda * y(1) * (y(2) + y(3))) - alpha * y(2);         % dIa/dt
   (alpha * y(2)) - (tau * y(3));                            % dIc/dt
   (tau * y(3)) - (gamma * y(4));                            % dT/dt
   gamma * y(4)                                          % dR/dt
], tspan, y0);
% Array to store chronic infection levels for different tau values
treatment_rates = linspace(0.001, 0.05, 100); % Vary treatment rate from 0.1% to 5%
chronic_levels = zeros(size(treatment_rates));
% Loop over treatment rates and simulate the model
for i = 1:length(treatment_rates)
   tau = treatment_rates(i);
   [~, y] = simulateModel(tau);  % Run the model for current tau
   chronic_levels(i) = y(end, 3) / N;  % Chronic infection level at the end of the period
end
% Find the treatment rate that brings chronic infection below the target level
required_tau = interp1(chronic_levels, treatment_rates, target_level, 'linear', 'extrap');
% Plot the results
figure;
plot(treatment_rates, chronic_levels, '-o');
xlabel('Treatment Rate (\tau)');
ylabel('Chronic Infection Level (I_c / N)');
title('Chronic Infection Level vs Treatment Rate');
grid on;
% Display the required treatment rate to achieve the target chronic infection level
fprintf('Required treatment rate to achieve %.2f chronic infection level: %.3f\n', target_level, required_tau);