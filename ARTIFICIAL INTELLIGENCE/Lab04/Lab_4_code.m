
%% Lab 4: Fuzzy Logic and ANFIS --- full MATLAB script
%
% Two halves, and the difference between them is the point of the lab:
%
%   Examples 1-7   MAMDANI / SUGENO by hand. YOU write the membership
%                  functions and the rules. The system is transparent and
%                  encodes what an expert says, but it learns nothing.
%
%   Examples 8-14  ANFIS. The rule structure is fixed, and the membership
%                  function parameters are LEARNED from data. It fits what
%                  the data says, at the cost of readability.
%
% Requires the Fuzzy Logic Toolbox.

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
% A Sugeno output MF is a FUNCTION of the inputs, not a fuzzy set. For
% 'linear' with one input, MATLAB reads the parameters as [a b], meaning
%
%       output = a * Speed + b
%
% so the coefficient decides which way the consequent slopes. Read the
% numbers, not the label: a rule named "High" whose function DECREASES
% with speed still decreases.
fis2 = sugfis('Name','speedControl');
fis2 = addInput(fis2,[0 100],'Name','Speed');
fis2 = addOutput(fis2,[0 1],'Name','BrakeForce');

fis2 = addMF(fis2,'Speed','gaussmf',[10 20],'Name','Slow');
fis2 = addMF(fis2,'Speed','gaussmf',[10 80],'Name','Fast');

% Both consequents rise with speed, so faster always means more braking.
%   Low  : 0.002*Speed + 0.1   ->  0.10 at rest, 0.30 at 100
%   High : 0.006*Speed + 0.3   ->  0.30 at rest, 0.90 at 100
fis2 = addMF(fis2,'BrakeForce','linear',[0.002 0.1],'Name','Low');
fis2 = addMF(fis2,'BrakeForce','linear',[0.006 0.3],'Name','High');
fis2 = addRule(fis2,[1 1 1 1; 2 2 1 1]);

% Sanity-check the model over its whole input range before trusting it:
%   evalfis(fis2, [20; 60; 100])  ->  approximately 0.140, 0.659, 0.900
% Braking must increase with speed. An earlier version of this example
% used [0.01 0] and [-0.01 1]; that gave 0.200, 0.400 and 0.000, so the
% car braked hardest at a standstill and not at all at top speed. Every
% MATLAB call succeeded --- the code was valid and the model was wrong,
% which is exactly why you plot the response instead of reading one point.
% gensurf(fis2);

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

%% Example 12: ANFIS on a medical dataset (Pima diabetes)
% Load dataset (make sure diabetes.csv is in the current folder).
% Columns 1-8 are features, column 9 (Outcome) is the 0/1 label.
data3 = readmatrix('diabetes.csv');

% ---- Know the data before modelling it -------------------------------
% In this dataset a physically impossible 0 is used as a MISSING-VALUE
% code, not a measurement:
%     Insulin        374 of 768 rows are 0   (49%)
%     SkinThickness  227 of 768 rows are 0   (30%)
%     BloodPressure   35,  BMI 11,  Glucose 5
% Nobody has a blood pressure of zero. Treating these as real numbers
% drags every mean and every membership function toward zero. This lab
% uses columns 1-2 (Pregnancies, Glucose), where 0 pregnancies IS valid
% but 0 glucose is not -- so check, and say what you did.
% Sanity check to run first:
%     sum(data3 == 0)

% ---- Scale the FEATURES to [0, 1], and leave the LABEL alone ---------
% normalize(X) with no options performs Z-SCORE standardisation
% (mean 0, std 1) -- it does NOT map to [0, 1]. Applying it to the whole
% matrix also rescales the 0/1 Outcome column into {-0.732, 1.365},
% which is no longer a label at all.
% 'range' is the option that actually produces [0, 1].
features = normalize(data3(:, 1:8), 'range');   % -> [0, 1]
labels   = data3(:, 9);                         % left as 0/1

% Use only 2 features and 1 output to reduce rule complexity.
% ANFIS builds one rule per MF COMBINATION: 2 inputs x 2 MFs = 4 rules.
% All 8 features with 2 MFs each would be 2^8 = 256 rules -- far more
% parameters than 500 rows can support.
dataSubset = [features(1:500, [1 2]), labels(1:500)];

% Hold out the remaining rows so the model is judged on data it has not
% seen. Reporting only training error says nothing about generalisation.
testSubset = [features(501:end, [1 2]), labels(501:end)];

% Train ANFIS model with 2 MFs per input
anfisFIS3 = anfis(dataSubset, 2);

%% Example 13: ANFIS training error, and error on held-out data
% anfis() returns the training error from the SAME call, so there is no
% need to train a second identical model just to plot it.
[anfisFIS4, trainError] = anfis(dataSubset, 2);
figure;
plot(trainError);
title('ANFIS Training Error');
xlabel('Epochs');
ylabel('Error');

% The number that actually matters: error on rows the model never saw.
predicted = evalfis(anfisFIS4, testSubset(:, 1:2));
testRMSE  = sqrt(mean((predicted - testSubset(:, 3)).^2));
disp(['Training RMSE (final epoch): ', num2str(trainError(end))]);
disp(['Held-out RMSE             : ', num2str(testRMSE)]);
% A held-out error much larger than the training error is overfitting.
%
% Note also what ANFIS is doing here: regressing a 0/1 label, so its
% output is continuous. To read it as a classification you must pick a
% threshold (0.5 is a choice, not a law) and report accuracy against it.

%% Example 14: Real-Time Application - Smart AC Control
% Training data: Temperature, Humidity -> AC Intensity
data4 = [20 30 0.3;
         25 40 0.5;
         30 50 0.7;
         35 60 0.9;
         40 70 1];

% Train ANFIS with 2 MFs per input
anfisFIS5 = anfis(data4, 2);

% Evaluate new condition: 37 C and 65% humidity
result = evalfis(anfisFIS5, [37 65]);
disp(['AC Intensity for 37 C & 65% humidity: ', num2str(result)]);

% ---- Read this result honestly ---------------------------------------
% 5 training rows, 2 inputs, 2 MFs per input = 4 rules. Each Sugeno rule
% carries 3 consequent parameters (a*T + b*H + c), so the model has more
% free parameters than it has data points to fit them with.
%
% It will therefore reproduce the 5 training rows almost exactly and has
% learned nothing that generalises. Note too that Temperature and
% Humidity rise together in every row, so the model cannot tell which
% one drives the output -- perfectly confounded inputs.
%
% [37 65] sits inside the training range, so the answer is interpolation
% and looks plausible. Ask for evalfis(anfisFIS5, [50 90]) instead: that
% is extrapolation beyond anything the model has seen, and it is where
% an overfitted ANFIS gives confident nonsense.
%
% This example demonstrates the ANFIS WORKFLOW. Do not present its
% output as a working controller.

%% Example 15: Fuzzy Logic Designer GUI
% Uncomment below to launch the FIS Designer
% fuzzyLogicDesigner
