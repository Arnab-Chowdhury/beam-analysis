%% beam.m: Comprehensive Beam Analysis Script

clear; clc; close;

% User input for beam type
beamType = input('Enter beam type (1 for Simply Supported, 2 for Cantilever): ');
L = input('Enter the span of the beam (m): ');
n = 1000; % Number of intervals

% Basic Preallocations
xx = (0:n-1) * L / n;
V = zeros(1, n); % Shear force array
V1 = zeros(1, n); % Auxiliary shear array for moments
M = zeros(1, n); % Bending moment array
u = zeros(1, n); % Deflection array
Z = zeros(1, n); % Corrected shear force array (if applicable)

if beamType == 1
    % Simply Supported Beam
    disp('Analyzing Simply Supported Beam...');

    % Point Load Inputs
    P = input('Enter all point loads (if any) within array []: ');
    x = input('Enter corresponding locations within array []: ');

    for k = 1:length(P)
        [V, u] = forceDiagrams(x(k), P(k), L, V, u, n);
    end

    % UVL Inputs
    Pi = input('Enter starting loads for distributed loads (if any) within array []: ');
    xi = input('Enter corresponding starting positions within array []: ');
    Pf = input('Enter ending loads within array []: ');
    xf = input('Enter corresponding ending positions within array []: ');

    for k = 1:length(Pi)
        xin = ceil(xi(k) * n / L);
        xfn = ceil(xf(k) * n / L);
        m = xfn - xin; % Number of intervals

        % Load distribution calculations
        Pin = Pi(k) * (xf(k) - xi(k)) / m;
        Pfn = Pf(k) * (xf(k) - xi(k)) / m;
        increment = (Pfn - Pin) / m;

        for i = 1:m
            [V, u] = forceDiagrams(xi(k), Pin, L, V, u, n);
            xi(k) = xi(k) + L / n;
            Pin = Pin + increment;
        end
    end

    % Point Moment Inputs
    Mz = input('Enter point moments (if any) within array []: ');
    x = input('Enter corresponding locations within array []: ');

    for k = 1:length(x)
        P1 = n * Mz(k) / L;
        [V, u] = forceDiagrams(x(k), P1, L, V, u, n);
        [V1, u] = forceDiagrams(x(k), P1, L, V1, u, n);
        P2 = -n * Mz(k) / L;
        x(k) = x(k) + L / n;
        [V, u] = forceDiagrams(x(k), P2, L, V, u, n);
        [V1, u] = forceDiagrams(x(k), P2, L, V1, u, n);
        Z = V - V1 + (P1 - P1 * x(k) / L) * ones(1, n);
    end

elseif beamType == 2
    % Cantilever Beam
    disp('Analyzing Cantilever Beam...');

    % Point Load Inputs
    P = input('Enter all point loads (if any) within array []: ');
    x = input('Enter corresponding locations within array []: ');

    for k = 1:length(P)
        [V, u] = forceDiagrams2(x(k), P(k), L, V, u, n);
        M = M - P(k) * x(k) * ones(1, n);
    end

    % UVL Inputs
    Pi = input('Enter starting loads for distributed loads (if any) within array []: ');
    xi = input('Enter corresponding starting positions within array []: ');
    Pf = input('Enter ending loads within array []: ');
    xf = input('Enter corresponding ending positions within array []: ');

    for k = 1:length(Pi)
        xin = ceil(xi(k) * n / L);
        xfn = ceil(xf(k) * n / L);
        m = xfn - xin; % Number of intervals

        % Load distribution calculations
        Pin = Pi(k) * (xf(k) - xi(k)) / m;
        Pfn = Pf(k) * (xf(k) - xi(k)) / m;
        increment = (Pfn - Pin) / m;

        for i = 1:m
            [V, u] = forceDiagrams2(xi(k), Pin, L, V, u, n);
            M = M - (Pin * x(k) * ones(1, n));
            xi(k) = xi(k) + L / n;
            Pin = Pin + increment;
        end
    end

    % Point Moment Inputs
    Mz = input('Enter point moments (if any) within array []: ');
    x = input('Enter corresponding locations within array []: ');

    for k = 1:length(x)
        P1 = n * Mz(k) / L;
        [V, u] = forceDiagrams2(x(k), P1, L, V, u, n);
        [V1, u] = forceDiagrams2(x(k), P1, L, V1, u, n);
        P2 = -n * Mz(k) / L;
        x(k) = x(k) + L / n;
        [V, u] = forceDiagrams2(x(k), P2, L, V, u, n);
        [V1, u] = forceDiagrams2(x(k), P2, L, V1, u, n);
        M = M - Mz(k) * ones(1, n);
        Z = V - V1 + P1 * ones(1, n);
    end

else
    error('Invalid beam type selected. Choose 1 or 2.');
end

% Generate Moment Array
M = M + cumtrapz(xx, V);

% Plot Shear Force Diagram (SFD)
figure;
plot(xx, V, 'b-', 'LineWidth', 2);
grid on;
title('Shear Force Diagram (SFD)');
xlabel('Beam Length (m)');
ylabel('Shear Force (N)');

% Plot Bending Moment Diagram (BMD)
figure;
plot(xx, M, 'r-', 'LineWidth', 2);
grid on;
title('Bending Moment Diagram (BMD)');
xlabel('Beam Length (m)');
ylabel('Bending Moment (N-m)');

% Plot Deflection Curve
figure;
plot(xx, u, 'g-', 'LineWidth', 2);
grid on;
title('Deflection Curve');
xlabel('Beam Length (m)');
ylabel('Deflection (m)');

% Display maximum values
V_max = max(V);
disp(['Maximum Shear Force: ', num2str(V_max), ' N']);

M_max = max(M);
disp(['Maximum Bending Moment: ', num2str(M_max), ' N-m']);

u_max = max(abs(u));
disp(['Maximum Deflection: ', num2str(u_max), ' m']);
