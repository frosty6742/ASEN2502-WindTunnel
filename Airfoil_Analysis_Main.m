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
    Data15(j,5) = mean(RawData15(:,3));% rho (calced density)
    Data15(j,6) = mean(RawData15(:,5));% q_test (test section dynamic pressure)
    Data15(j,7) = Data15(j,3) - Data15(j,6);  % P_static_test = Patm - q

    % Ports 1 through 9: Raw differential is (P_port - P_static_test)
    % Convert to absolute P_port = (P_port - P_static_test) + P_static_test.
    for k = 8:16                      % k indexes output columns; 8 to port1, ..., 16 to port9
        deltaP = mean(RawData15(:,k+7));   % raw col 15..23
        Data15(j,k) = deltaP + Data15(j,7);
    end

    % Trailing edge assumed static test section
    Data15(j,17) = Data15(j,7);

    % Ports 10..16
    for k = 18:24                      % k indexes output columns; 18 to port10, ..., 24 to port16
        deltaP = mean(RawData15(:,k+6));   % raw col 24..30
        Data15(j,k) = deltaP + Data15(j,7);
    end

    Data15(j,25) = Data15(j,8); % Repeat port 1 

end
Data15 = sortrows(Data15,1); % Sorts data by increasing Ao

%% --- Ingest & condition: 30mps ---
for j = 1:numFiles30
    RawData30 = readmatrix(fileNames30(j),'NumHeaderLines',1);

    Data30(j,1) = AoA30(j);            % AoA
    Data30(j,2) = mean(RawData30(:,4));% V_test
    Data30(j,3) = mean(RawData30(:,2));% Patm
    Data30(j,4) = mean(RawData30(:,1));% Tatm
    Data30(j,5) = mean(RawData30(:,3));% rho
    Data30(j,6) = mean(RawData30(:,5));% q_test
    Data30(j,7) = Data30(j,3) - Data30(j,6);  % P_static_test

    % Ports 1..9
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

    Data30(j,25) = Data30(j,8);  % Repeat port 1
end
Data30 = sortrows(Data30,1);  % Sorts data by increasing AoA

%% Determine Forces & Analyze Results
% Pressure Distribution for each Velocity & AoA tested (done by student code)
% Normal and Axial Force components Velocity & AoA tested (done by student code)
% variables
N15 = zeros(numFiles15,1);
A15 = zeros(numFiles15,1); 

for i = 1:numFiles15
    for j = 1:9
        N15(i) = N15(i) - 0.5*(Data15(i,j+7)+Data15(i,j+8))*Segments.DeltaX(j);
        A15(i) = A15(i) + 0.5*(Data15(i,j+7)+Data15(i,j+8))*Segments.DeltaY(j);
    end
    for j = 1:8
        N15(i) = N15(i) + 0.5*(Data15(i,mod(18-j,17)+8)+Data15(i,mod(17-j,17)+8))*Segments.DeltaX(j+9);
        A15(i) = A15(i) - 0.5*(Data15(i,mod(18-j,17)+8)+Data15(i,mod(17-j,17)+8))*Segments.DeltaY(j+9);
    end
end

N30 = zeros(numFiles30,1);
A30 = zeros(numFiles30,1); 

for i = 1:numFiles30
    for j = 1:9
        N30(i) = N30(i) - 0.5*(Data30(i,j+7)+Data30(i,j+8))*Segments.DeltaX(j);
        A30(i) = A30(i) + 0.5*(Data30(i,j+7)+Data30(i,j+8))*Segments.DeltaY(j);
    end
    for j = 1:8
        N30(i) = N30(i) + 0.5*(Data30(i,mod(18-j,17)+8)+Data30(i,mod(17-j,17)+8))*Segments.DeltaX(j+9);
        A30(i) = A30(i) - 0.5*(Data30(i,mod(18-j,17)+8)+Data30(i,mod(17-j,17)+8))*Segments.DeltaY(j+9);
    end
end

% Lift & Coefficient of Lift Velocity & AoA tested (done by student code)
% variables
L15 = zeros(numFiles15,1);
CL15 = zeros(numFiles15,1);

for i = 1:numFiles15
    L15(i) = N15(i)*cos(pi/180*Data15(i,1))-A15(i)*sin(pi/180*Data15(i,1));
    CL15(i) = L15(i)/Data15(i,6);
end

L30 = zeros(numFiles30,1);
CL30 = zeros(numFiles30,1);

for i = 1:numFiles30
    L30(i) = N30(i)*cos(pi/180*Data30(i,1))-A30(i)*sin(pi/180*Data30(i,1));
    CL30(i) = L30(i)/Data30(i,6);
end



%% Plots
x_ports_all = Ports.X_m(1:16).';  

Cp15_front = (Data15(:, 8:16)  - Data15(:, 7)) ./ Data15(:, 6);   % ports 1..9
Cp15_back  = (Data15(:, 18:24) - Data15(:, 7)) ./ Data15(:, 6);   % ports 10..16
Cp15_all   = [Cp15_front, Cp15_back];

Cp30_front = (Data30(:, 8:16)  - Data30(:, 7)) ./ Data30(:, 6);
Cp30_back  = (Data30(:, 18:24) - Data30(:, 7)) ./ Data30(:, 6);
Cp30_all   = [Cp30_front, Cp30_back];

% Velocity vs normalized chord (x/c)
figure; hold on;
for j = 1:size(Data15, 1)
    plot(x_ports_all, Data15(j, 2) * ones(size(x_ports_all)), 'DisplayName', sprintf('15 m/s  AoA = %.1f°', Data15(j, 1)));
end
for j = 1:size(Data30, 1)
    plot(x_ports_all, Data30(j, 2) * ones(size(x_ports_all)), 'DisplayName', sprintf('30 m/s  AoA = %.1f°', Data30(j, 1)));
end
xlabel('Normalized Chord, x/c');
ylabel('Velocity (m/s)');
title('Velocity vs x/c for 15 m/s and 30 m/s');
set(gca, 'FontSize', 40);
legend('show','Location','best');
grid on;
hold off;

% Coefficient of Pressure vs normalized chord (x/c)
figure; hold on;
for j = 1:size(Cp15_all,1)
    plot(x_ports_all, Cp15_all(j,:), 'DisplayName', sprintf('15 m/s  AoA = %.1f°', Data15(j,1)));
end
for j = 1:size(Cp30_all,1)
    plot(x_ports_all, Cp30_all(j,:), 'DisplayName', sprintf('30 m/s  AoA = %.1f°', Data30(j,1)));
end
set(gca,'YDir','reverse'); % conventional Cp plotting (more negative Cp higher on the plot)
xlabel('Normalized Chord, x/c');
ylabel('Pressure Coefficient, C_p');
title('C_p vs x/c for 15 m/s and 30 m/s');
set(gca, 'FontSize', 40);
legend('show','Location','best');
grid on;
hold off;

% Coefficient of Lift vs Angle of Attack
figure; hold on;
plot(Data15(:,1), CL15, 'DisplayName', '15 mps');
plot(Data30(:,1), CL30, 'DisplayName', '30 mps');

ylabel('Coefficient of Lift');
xlabel('AoA');
title('Coefficient of Lift vs Angle of Attack');
set(gca, 'FontSize', 40);
legend('show','Location','best');
grid on;
hold off;


