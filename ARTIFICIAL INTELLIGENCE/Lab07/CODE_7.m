% Clear variables
clear; clc;

% Define input sentence
text = "The movie was fantastic and the visuals were breathtaking.";

% Define word lists
positiveWords = ["good", "great", "excellent", "fantastic", "amazing", "breathtaking"];
negativeWords = ["bad", "terrible", "awful", "boring", "worst", "dull"];

% Tokenize text
words = lower(strsplit(text));

% Count positive and negative words
posCount = sum(ismember(words, positiveWords));
negCount = sum(ismember(words, negativeWords));

% Determine sentiment
if posCount > negCount
    sentiment = "Positive";
elseif negCount > posCount
    sentiment = "Negative";
else
    sentiment = "Neutral";
end

% Display result
disp("Sentiment:");
disp(sentiment);
