% Clear everything
clear; clc;

% Sample paragraph
text = "Data science involves extracting insights from structured and unstructured data using statistical and machine learning techniques.";

% Tokenize and preprocess
document = tokenizedDocument(text);
document = removeStopWords(document);
document = erasePunctuation(document);

% Bag of words model
bow = bagOfWords(document);

% Sort words by frequency
[sortedCounts, sortedIndex] = sort(bow.Counts, 'descend');
sortedWords = bow.Vocabulary(sortedIndex);

% Extract top 5 keywords
keywords = sortedWords(1:min(5, end));

% Display
disp("Extracted Keywords:");
disp(keywords);
