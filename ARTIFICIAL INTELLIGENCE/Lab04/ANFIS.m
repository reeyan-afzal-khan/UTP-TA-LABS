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
