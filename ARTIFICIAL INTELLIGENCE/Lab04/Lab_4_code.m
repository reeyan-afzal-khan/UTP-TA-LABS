
%% Lab 5: Fuzzy Logic and ANFIS - Full MATLAB Script (Corrected)

clc; clear; close all;

%% Example 1: Create a Basic FIS
fis = mamfis('Name', 'temperatureControl');
disp(fis)

%% Example 2: Add Inputs, Outputs, and Membership Functions
fis = addInput(fis, [0 100], 'Name', 'Temperature');
fis = addMF(fis, 'Temperature', 'trimf', [0 0 50], 'Name', 'Cold');
fis = addMF(fis, 'Temperature', 'trimf', [25 50 75], 'Name', 'Warm');
fis = addMF(fis, 'Temperature', 'trimf', [50 100 100], 'Name', 'Hot');

fis = addOutput(fis, [0 10], 'Name', 'FanSpeed');
fis = addMF(fis, 'FanSpeed', 'trimf', [0 0 5], 'Name', 'Low');
fis = addMF(fis, 'FanSpeed', 'trimf', [3 5 7], 'Name', 'Medium');
fis = addMF(fis, 'FanSpeed', 'trimf', [5 10 10], 'Name', 'High');

%% Example 3: Define Fuzzy Rules (Corrected Format)
ruleList = [
    1 1 1 1;   % IF Cold THEN Low
    2 2 1 1;   % IF Warm THEN Medium
    3 3 1 1    % IF Hot THEN High
];
fis = addRule(fis, ruleList);

%% Example 4: View Rules and Evaluate Output
% ruleviewer(fis);
output = evalfis(fis, 70);
disp(['Fan Speed at 70°C: ', num2str(output)]);

%% Example 5: Surface Viewer
gensurf(fis);

%% Example 6: Create a Sugeno-type FIS
fis2 = sugfis('Name','speedControl');
fis2 = addInput(fis2,[0 100],'Name','Speed');
fis2 = addOutput(fis2,[0 1],'Name','BrakeForce');

fis2 = addMF(fis2,'Speed','gaussmf',[10 20],'Name','Slow');
fis2 = addMF(fis2,'Speed','gaussmf',[10 80],'Name','Fast');
fis2 = addMF(fis2,'BrakeForce','linear',[0.01 0],'Name','Low');
fis2 = addMF(fis2,'BrakeForce','linear',[-0.01 1],'Name','High');
fis2 = addRule(fis2,[1 1 1 1; 2 2 1 1]);

%% Example 7: Load and Modify Existing FIS
fis3 = readfis('tipper');
showrule(fis3);

%% Example 8: ANFIS Training (Single Input)
data1 = [0 0; 5 2.5; 10 5; 15 7.5; 20 10];
anfisFIS1 = anfis(data1, 10);

%% Example 9: ANFIS with Two Inputs
data2 = [0 0 0; 5 2 2.5; 10 5 5; 15 7 7.5; 20 10 10];
anfisFIS2 = anfis(data2, 20);

%% Example 10: Predict with ANFIS
inputVal = [12 6];
predictedOutput = evalfis(anfisFIS2, inputVal);
disp(['Predicted Output: ', num2str(predictedOutput)]);

%% Example 11: Save and Reload Trained FIS
writefis(anfisFIS2, 'trainedFIS');
loadedFIS = readfis('trainedFIS');

%% Example 12: ANFIS on Medical Dataset (Diabetes) - Error-Free
% Load dataset (make sure diabetes.csv is in the current folder)
data3 = readmatrix('diabetes.csv');  % 8 features + 1 output (column 9)

% Normalize the data to [0, 1]
data3 = normalize(data3);

% Use only 2 features and 1 output to reduce rule complexity
dataSubset = data3(1:500, [1 2 9]);  % Columns 1 & 2 as input, column 9 as output

% Train ANFIS model with 2 MFs per input
anfisFIS3 = anfis(dataSubset, 2);

%% Example 13: ANFIS Error Plot
[anfisFIS4, trainError] = anfis(dataSubset, 2);  % Same data and MFs
figure;
plot(trainError);
title('ANFIS Training Error');
xlabel('Epochs');
ylabel('Error');

%% Example 14: Real-Time Application - Smart AC Control
% Training data: Temperature, Humidity → AC Intensity
data4 = [20 30 0.3;
         25 40 0.5;
         30 50 0.7;
         35 60 0.9;
         40 70 1];

% Train ANFIS with 2 MFs per input
anfisFIS5 = anfis(data4, 2);

% Evaluate new condition: 37°C and 65% humidity
result = evalfis(anfisFIS5, [37 65]);
disp(['AC Intensity for 37°C & 65% humidity: ', num2str(result)]);


% % % % % % % %% Example 12: ANFIS on Medical Dataset (Diabetes)
% % % % % % % data3 = readmatrix('diabetes.csv');  % or csvread, readtable
% % % % % % % anfisFIS3 = anfis(data3(1:500,:), 30);
% % % % % % % 
% % % % % % % 
% % % % % % % % load diabetes
% % % % % % % % data3 = [Pima(:,1:7) Pima(:,8)];
% % % % % % % % anfisFIS3 = anfis(data3(1:500,:), 30);
% % % % % % % 
% % % % % % % %% Example 13: ANFIS Error Plot
% % % % % % % [anfisFIS4, trainError] = anfis(data3(1:500,:), 30);
% % % % % % % figure; plot(trainError);
% % % % % % % title('ANFIS Training Error'); xlabel('Epochs'); ylabel('Error');
% % % % % % % 
% % % % % % % %% Example 14: Real-Time Application - Smart AC Control
% % % % % % % % Inputs: Temperature, Humidity; Output: AC Intensity
% % % % % % % data4 = [20 30 0.3; 25 40 0.5; 30 50 0.7; 35 60 0.9; 40 70 1];
% % % % % % % anfisFIS5 = anfis(data4, 25);
% % % % % % % result = evalfis(anfisFIS5, [37 65]);
% % % % % % % disp(['AC Intensity: ', num2str(result)]);

%% Example 15: Fuzzy Logic Designer GUI
% Uncomment below to launch the FIS Designer
% fuzzyLogicDesigner
