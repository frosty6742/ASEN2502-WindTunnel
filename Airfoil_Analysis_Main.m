%%ASEN 2502 Wind Tunnel Lab
% Author:
% Lab Description: Employ basic experimental wind tunnel testing procedures, 
% conduct flow measurements, and develop an awareness for sources of 
% error/error analysis as part of a team.  Validate the AES PILOT 
% Low-SpeedWind Tunnel through the evaluation of a Clark Y-14 airfoil 
% and comparingthe results to the published National Advisory Committee 
% for Aeronautics (NACA) results from 1938.
% 
% Inputs:
% - Raw Wind Tunnel CSV data files for tests
% - Airfoil Static Port Locations
% - Comparison NACA Clark Y Data
% 
% Outputs:
% 
%
%% Intialize Workspace
clear; clc; close all; % Clear workspace, command window, and close all figures

addpath(genpath('15 mps Data Files')); %Adds 15 m/s test data files folder and subfolders
addpath(genpath('30 mps Data Files')); %Adds 30 m/s test data files folder and subfolders

%% Import Airfoil Port Locations
Ports = readtable('Port_Locations.xlsx','Sheet','Port_Locations'); %Read in CSV file with port locations
Segments = readtable('Port_Locations.xlsx','Sheet','Segments'); %Read in segment information from CSV file

% --- Load Clark Y-14 data from Excel (AoA, Cl, Cd) ---
NACA_data = readmatrix('ClarkY14_NACA_TR628.xlsx', 'Range', 'A4:C15');

%% Geometry / chord handling (FIX)
% Use measured chord from the port map so all normalizations are correct
c = max(Ports.X_m);        % [m] chord length from geometry

% Segments.DeltaX/DeltaY appear to already be in **meters** (based on CL
% magnitude check). Use them directly without additional scaling.
dX = Segments.DeltaX;   % [m]
dY = Segments.DeltaY;   % [m]

% Sanity prints to verify scales
fprintf('Chord c = %.4f m | max(DeltaX) = %.5f m | max(DeltaY) = %.5f m\n', c, max(dX), max(dY));

%% Search Data Folders, Pull File Names & Count Data Files
% Get filenames for test data files

% --- 15mps ---
fileLoc15   = '15 mps Data Files/';
list15      = dir(fullfile(fileLoc15, '*AoA*'));
numFiles15  = numel(list15);

fileNames15 = strings(numFiles15,1); % Convert to char array from cell array
AoA15       = zeros(numFiles15,1); %Counts number of AoAs tested

for i = 1:numFiles15
    fileNames15(i) = fullfile(fileLoc15, list15(i).name); % This makes a string of the complete file name with the path in front of it
    AoA15(i)       = str2double(extractBetween(list15(i).name, 'AoA_', '.csv')); % Finds the angle of attack value in the name and make it a usable number
end
AoA_Count15 = numFiles15;

% --- 30mps ---
fileLoc30   = '30 mps Data Files/';
list30      = dir(fullfile(fileLoc30, '*AoA*'));
numFiles30  = numel(list30);
fileNames30 = strings(numFiles30,1);
AoA30       = zeros(numFiles30,1);
for i = 1:numFiles30
    fileNames30(i) = fullfile(fileLoc30, list30(i).name);
    AoA30(i)       = str2double(extractBetween(list30(i).name, 'AoA_', '.csv'));
end
AoA_Count30 = numFiles30;

%% Ingest Data Files and Data Conditioning
% Averaging Raw Data Samples for each Velocity & AOA Tested
% Derived Values for each Velocity & AoA tested
    % Average Test Section Static Pressure (done by student code)
    % Average Airfoil Port Local Velocity (done by student code)
    % Average Airfoil Port Local Static Pressure (done by student code)

% Initialize Storage Arrays
Data15 = zeros(numFiles15,25);  %Conditioned wind tunnel data file 15 m/s
Data30 = zeros(numFiles30,25); %Conditioned wind tunnel data file 30 m/s

%% Ingest and Condition Data
% Averaging Raw Data Samples for each Velocity & AOA Tested
% Derived Values for each Velocity & AoA tested
    % Average Test Section Static Pressure (done by student code)
    % Average Airfoil Port Local Velocity (done by student code)
    % Average Airfoil Port Local Static Pressure (done by student code)

%% --- Ingest & condition: 15mps ---
for j = 1:numFiles15
    RawData15 = readmatrix(fileNames15(j),'NumHeaderLines',1);

    % Map columns
    Data15(j,1) = AoA15(j);            % AoA
    Data15(j,2) = mean(RawData15(:,4));% V_test
    Data15(j,3) = mean(RawData15(:,2));% Patm 
    Data15(j,4) = mean(RawData15(:,1));% Tatm
    Data15(j,5) = mean(RawData15(:,3));% rho
    Data15(j,6) = mean(RawData15(:,5));% q_test
    Data15(j,7) = Data15(j,3) - Data15(j,6);  % P_static_test
    % Ports 1..9 (absolute pressure)
    for k = 8:16
        deltaP = mean(RawData15(:,k+7));   % raw col 15..23
        Data15(j,k) = deltaP + Data15(j,7);
    end

    % Trailing edge assumed static test section
    Data15(j,17) = Data15(j,7);
    % Ports 10..16
    for k = 18:24
        deltaP = mean(RawData15(:,k+6));   % raw col 24..30
        Data15(j,k) = deltaP + Data15(j,7);
    end
    Data15(j,25) = Data15(j,8); % repeat port 1
end
Data15 = sortrows(Data15,1);

%% --- Ingest & condition: 30mps ---
for j = 1:numFiles30
    RawData30 = readmatrix(fileNames30(j),'NumHeaderLines',1);
    Data30(j,1) = AoA30(j);
    Data30(j,2) = mean(RawData30(:,4));
    Data30(j,3) = mean(RawData30(:,2));
    Data30(j,4) = mean(RawData30(:,1));
    Data30(j,5) = mean(RawData30(:,3));
    Data30(j,6) = mean(RawData30(:,5));
    Data30(j,7) = Data30(j,3) - Data30(j,6);
    for k = 8:16
        deltaP = mean(RawData30(:,k+7));   % raw col 15..23
        Data30(j,k) = deltaP + Data30(j,7);
    end

    % Trailing edge assumed static test section
    Data30(j,17) = Data30(j,7);

    % Ports 10..16
    for k = 18:24
        deltaP = mean(RawData30(:,k+6));   % raw col 24..30
        Data30(j,k) = deltaP + Data30(j,7);
    end
    Data30(j,25) = Data30(j,8);
end
Data30 = sortrows(Data30,1);

%% Determine Forces & Analyze Results
% Integrate pressure to get normal (N) and axial (A) force per unit span.
N15 = zeros(numFiles15,1); A15 = zeros(numFiles15,1);
for i = 1:numFiles15
    for j = 1:9
        N15(i) = N15(i) - 0.5*(Data15(i,j+7)+Data15(i,j+8)) * dX(j);
        A15(i) = A15(i) + 0.5*(Data15(i,j+7)+Data15(i,j+8)) * dY(j);
    end
    for j = 1:8
        N15(i) = N15(i) + 0.5*(Data15(i,mod(18-j,17)+8)+Data15(i,mod(17-j,17)+8)) * dX(j+9);
        A15(i) = A15(i) - 0.5*(Data15(i,mod(18-j,17)+8)+Data15(i,mod(17-j,17)+8)) * dY(j+9);
    end
end

N30 = zeros(numFiles30,1); A30 = zeros(numFiles30,1);
for i = 1:numFiles30
    for j = 1:9
        N30(i) = N30(i) - 0.5*(Data30(i,j+7)+Data30(i,j+8)) * dX(j);
        A30(i) = A30(i) + 0.5*(Data30(i,j+7)+Data30(i,j+8)) * dY(j);
    end
    for j = 1:8
        N30(i) = N30(i) + 0.5*(Data30(i,mod(18-j,17)+8)+Data30(i,mod(17-j,17)+8)) * dX(j+9);
        A30(i) = A30(i) - 0.5*(Data30(i,mod(18-j,17)+8)+Data30(i,mod(17-j,17)+8)) * dY(j+9);
    end
end

% Lift & Coefficient of Lift (per-unit-span); normalize by q*c (FIX)
L15 = zeros(numFiles15,1); CL15 = zeros(numFiles15,1);
for i = 1:numFiles15
    L15(i)  = N15(i)*cosd(Data15(i,1)) - A15(i)*sind(Data15(i,1));
    CL15(i) = L15(i) / (Data15(i,6) * c);
end

L30 = zeros(numFiles30,1); CL30 = zeros(numFiles30,1);
for i = 1:numFiles30
    L30(i)  = N30(i)*cosd(Data30(i,1)) - A30(i)*sind(Data30(i,1));
    CL30(i) = L30(i) / (Data30(i,6) * c);
end

%% Plot helpers
x_over_c = Ports.X_m(1:16).' ./ c;  % normalized chord (0..1)

% Split x by surface: ports 1..9 (upper), 10..16 (lower)
xU = x_over_c(1:9); xL = x_over_c(10:16);
[xU_sorted, idxU] = sort(xU,'ascend');
[xL_sorted, idxL] = sort(xL,'ascend');

% Coefficient of pressure arrays (Cp)
Cp15_front = (Data15(:, 8:16)  - Data15(:, 7)) ./ Data15(:, 6);
Cp15_back  = (Data15(:, 18:24) - Data15(:, 7)) ./ Data15(:, 6);
Cp30_front = (Data30(:, 8:16)  - Data30(:, 7)) ./ Data30(:, 6);
Cp30_back  = (Data30(:, 18:24) - Data30(:, 7)) ./ Data30(:, 6);

Cp15U = Cp15_front(:, idxU);  Cp15L = Cp15_back(:,  idxL);
Cp30U = Cp30_front(:, idxU);  Cp30L = Cp30_back(:,  idxL);

%% Selected plot indices (example)
plot15I = [12, 21, 25];
plot30I = [10, 21, 28];
clrs = strings(max([numFiles15 numFiles30]), 1);
clrs(12) = "#890608"; clrs(10) = clrs(12);
clrs(21) = "#8b8d00"; clrs(25) = "#63be1e"; clrs(28) = clrs(25);

%% V/Vinf vs x/c (15 m/s)
VoverV15U = sqrt(max(0, 1 - Cp15U));
VoverV15L = sqrt(max(0, 1 - Cp15L));
figure; hold on;
for j = plot15I
    plot(xU_sorted, VoverV15U(j, :), '-', 'DisplayName', sprintf('15 m/s  AoA = %.1f°', Data15(j,1)), 'Color', clrs(j));
    plot(xL_sorted, VoverV15L(j, :), ':',  'LineWidth', 2, 'HandleVisibility','off', 'Color', clrs(j));
end
xlabel('Normalized Chord, x/c'); ylabel('Velocity Ratio, V/V_\infty');
title('V/V_\infty vs x/c for 15 m/s'); xlim([0 1]); grid on; legend('Location','eastoutside');
if exist('theme','file'); theme(gcf,'light'); end
exportgraphics(gcf, 'figures/VvsXC_15mps.pdf', 'ContentType', 'vector'); hold off;

%% V/Vinf vs x/c (30 m/s)
VoverV30U = sqrt(max(0, 1 - Cp30U));
VoverV30L = sqrt(max(0, 1 - Cp30L));
figure; hold on;
for j = plot30I
    plot(xU_sorted, VoverV30U(j, :), '-', 'DisplayName', sprintf('30 m/s  AoA = %.1f°', Data30(j,1)), 'Color', clrs(j));
    plot(xL_sorted, VoverV30L(j, :), ':',  'LineWidth', 2, 'HandleVisibility','off', 'Color', clrs(j));
end
xlabel('Normalized Chord, x/c'); ylabel('Velocity Ratio, V/V_\infty');
title('V/V_\infty vs x/c for 30 m/s'); xlim([0 1]); grid on; legend('Location','eastoutside');
if exist('theme','file'); theme(gcf,'light'); end
exportgraphics(gcf, 'figures/VvsXC_30mps.pdf', 'ContentType', 'vector'); hold off;

%% Cp vs x/c (15 m/s)
figure; hold on;
for j=plot15I
    plot(xU_sorted, Cp15U(j,:), '-', 'DisplayName', sprintf('15 m/s  AoA = %.1f°', Data15(j,1)),'Color', clrs(j));
    plot(xL_sorted, Cp15L(j,:), ':',  'LineWidth', 2, 'HandleVisibility','off', 'Color', clrs(j));
end
set(gca,'YDir','reverse'); xlabel('Normalized Chord, x/c'); ylabel('Pressure Coefficient, C_p');
title('C_p vs x/c for 15 m/s'); xlim([0 1]); grid on; legend('Location','eastoutside');
if exist('theme','file'); theme(gcf,'light'); end
exportgraphics(gcf, 'figures/CPvsXC_15mps.pdf', 'ContentType', 'vector'); hold off;

%% Cp vs x/c (30 m/s)
figure; hold on;
for j = plot30I
    plot(xU_sorted, Cp30U(j,:), '-', 'DisplayName', sprintf('30 m/s  AoA = %.1f°', Data30(j,1)), 'Color', clrs(j));
    plot(xL_sorted, Cp30L(j,:), ':',  'LineWidth', 2, 'HandleVisibility','off', 'Color', clrs(j));
end
set(gca,'YDir','reverse'); xlabel('Normalized Chord, x/c'); ylabel('Pressure Coefficient, C_p');
title('C_p vs x/c for 30 m/s'); xlim([0 1]); grid on; legend('Location','eastoutside');
if exist('theme','file'); theme(gcf,'light'); end
exportgraphics(gcf, 'figures/CPvsXC_30mps.pdf', 'ContentType', 'vector'); hold off;

%% CL vs AoA with NACA overlay
figure; hold on;
plot(Data15(:,1), CL15, 'o-', 'DisplayName', '15 m/s');
plot(Data30(:,1), CL30, 'o-', 'DisplayName', '30 m/s');
plot(NACA_data(:,1), NACA_data(:,2), 'k-', 'DisplayName', 'NACA TR 628');
ylabel('Coefficient of Lift'); xlabel('AoA (deg)');
title('Coefficient of Lift vs Angle of Attack');
grid on; legend('Location','best');
if exist('theme','file'); theme(gcf,'light'); end
exportgraphics(gcf, 'figures/CLvsAoA.pdf', 'ContentType', 'vector'); hold off;
