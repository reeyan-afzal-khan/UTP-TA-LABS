%% ANFIS on a medical dataset (Pima diabetes) --- standalone extract
%
% This is Examples 12-14 of Lab_4_code.m, kept separate so the dataset
% part can be run on its own. Requires the Fuzzy Logic Toolbox and
% diabetes.csv in the current folder.

clc; clear; close all;

%% Load
% Columns 1-8 are features, column 9 (Outcome) is the 0/1 label.
data3 = readmatrix('diabetes.csv');

% ---- Know the data before modelling it -------------------------------
% A physically impossible 0 is this dataset's MISSING-VALUE code:
%     Insulin        374 of 768 rows are 0   (49%)
%     SkinThickness  227 of 768 rows are 0   (30%)
%     BloodPressure   35,  BMI 11,  Glucose 5
% Nobody has zero blood pressure. Left as numbers they pull every mean
% and every membership function toward zero. Check before you model:
%     sum(data3 == 0)

%% Scale the FEATURES to [0, 1]; leave the LABEL as 0/1
% normalize(X) with no options is Z-SCORE standardisation (mean 0,
% std 1) -- it does NOT map to [0, 1]. Run it over the whole matrix and
% the 0/1 Outcome becomes {-0.732, 1.365}, which is no longer a label.
% 'range' is the option that actually gives [0, 1].
features = normalize(data3(:, 1:8), 'range');
labels   = data3(:, 9);

%% Train / test split
% ANFIS creates one rule per MF combination: 2 inputs x 2 MFs = 4 rules.
% Using all 8 features would be 2^8 = 256 rules, far beyond what 500
% rows can support.
trainSet = [features(1:500, [1 2]), labels(1:500)];      % Pregnancies, Glucose
testSet  = [features(501:end, [1 2]), labels(501:end)];  % never trained on

%% Train, and plot the training error from the SAME call
[anfisFIS, trainError] = anfis(trainSet, 2);

figure;
plot(trainError);
title('ANFIS Training Error');
xlabel('Epochs');
ylabel('Error');

%% Evaluate on held-out rows --- the number that actually means something
predicted = evalfis(anfisFIS, testSet(:, 1:2));
testRMSE  = sqrt(mean((predicted - testSet(:, 3)).^2));

disp(['Training RMSE (final epoch): ', num2str(trainError(end))]);
disp(['Held-out RMSE             : ', num2str(testRMSE)]);
% Held-out error much worse than training error means overfitting.

%% Turning a regression output into a decision
% ANFIS regresses the 0/1 label, so its output is continuous. Reading it
% as a class needs a THRESHOLD, and 0.5 is a choice rather than a law.
% Compare against the majority-class baseline before claiming success:
% 500 of 768 patients are Outcome 0, so always predicting 0 scores ~65%.
% A model that cannot beat that has learned nothing useful.
predictedClass = predicted >= 0.5;
accuracy = mean(predictedClass == testSet(:, 3));
baseline = max(mean(testSet(:, 3)), 1 - mean(testSet(:, 3)));

disp(['Accuracy at threshold 0.5 : ', num2str(accuracy)]);
disp(['Majority-class baseline   : ', num2str(baseline)]);
