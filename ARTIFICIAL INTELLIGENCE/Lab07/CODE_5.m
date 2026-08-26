clc;
clear;

% Sample text data and their labels (1 = Positive, 0 = Negative)
texts = [
    "I love this product", ...
    "This is terrible", ...
    "Very happy with the results", ...
    "It is bad and disappointing", ...
    "Absolutely wonderful experience"
];

labels = [1; 0; 1; 0; 1];  % Sentiment labels

% Define a manual bag-of-words (vocabulary)
bag = ["love", "terrible", "happy", "bad", "wonderful"];

% -------------------------------
% 🛠️ Step 2: Text to Binary Feature Matrix
% -------------------------------

% Initialize feature matrix
features = zeros(length(texts), length(bag));

% Fill in binary features for each text
for i = 1:length(texts)
    for j = 1:length(bag)
        if contains(lower(texts(i)), bag(j))  % use (i) not {i} for string array
            features(i, j) = 1;
        end
    end
end

% Optional: Remove any constant features (to avoid Naive Bayes errors)
features = features(:, var(features) > 0);

% -------------------------------
% 🤖 Step 3: Train Naive Bayes Classifier
% -------------------------------

Mdl = fitcnb(features, labels, 'DistributionNames', 'kernel');  % Use kernel to avoid distribution issues

% -------------------------------
% 🧪 Step 4: Test on New Sentence
% -------------------------------

testText = "The product is wonderful";

% Convert test text into feature vector
testFeat = zeros(1, length(bag));  % 1 row, N features
for j = 1:length(bag)
    if contains(lower(testText), bag(j))
        testFeat(1, j) = 1;
    end
end

% Predict sentiment
pred = predict(Mdl, testFeat);

% Display results
disp("Test Sentence:");
disp(testText);
if pred == 1
    disp("Predicted Sentiment: Positive");
else
    disp("Predicted Sentiment: Negative");
end
