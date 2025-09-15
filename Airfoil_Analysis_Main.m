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
fileLoc = '15 mps Data Files/';
list = dir([fileLoc, '*AoA*']); % This lists all files in fileLoc with 'WTData' in the file name
numFiles = length(list);

for i = 1:numFiles
    fileNames15{i} = [fileLoc, list(i).name]; % This makes a string of the complete file name with the path in front of it
    AoA15(i) = str2num(char(extractBetween(list(i).name, 'AoA_', '.csv'))); % Finds the angle of attack value in the name and make it a usable number
end
fileNames15 = string(fileNames15); % Convert to char array from cell array
AoA_Count15 = length(AoA15); %Counts number of AoAs tested

% --- 30mps ---
fileLoc = '30 mps Data Files/';
list = dir([fileLoc, '*AoA*']); % This lists all files in fileLoc with 'WTData' in the file name
numFiles = length(list);

for i = 1:numFiles
    fileNames30{i} = [fileLoc, list(i).name]; % This makes a string of the complete file name with the path in front of it
    AoA30(i) = str2num(char(extractBetween(list(i).name, 'AoA_', '.csv'))); % Finds the angle of attack value in the name and make it a usable number
end
fileNames30 = string(fileNames30); % Convert to char array from cell array
AoA_Count30 = length(AoA30); %Counts number of AoAs tested

%% Ingest Data Files and Data Conditioning
% Averaging Raw Data Samples for each Velocity & AOA Tested
% Derived Values for each Velocity & AoA tested
    % Average Test Section Static Pressure (done by student code)
    % Average Airfoil Port Local Velocity (done by student code)
    % Average Airfoil Port Local Static Pressure (done by student code)

% Initialize Storage Arrays
Data15 = zeros(numFiles,25); %Conditioned wind tunnel data file 15 m/s
Data30 = zeros(numFiles,25); %Conditioned wind tunnel data file 30 m/s

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
% Lift & Coefficient of Lift Velocity & AoA tested (done by student code)

%% Plots
% Velocity vs normalized chord (x/c)
% Coefficient of Pressure vs normalized chord (x/c)
% Coefficient of Lift vs Angle of Attack









