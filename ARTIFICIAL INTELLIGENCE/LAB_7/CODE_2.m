clc; clear;

text = "Natural language processing is a subfield of artificial intelligence. It helps computers understand human language. It is widely used in applications such as chatbots, translation, and voice recognition.";

% Split into sentences
sentences = split(text, '.');

% Remove empty entries
sentences = sentences(~cellfun('isempty',sentences));

% Tokenize and compute word frequency
allWords = [];
for i = 1:length(sentences)
    tokens = lower(split(sentences{i}));
    allWords = [allWords; tokens];
end

% Count word frequencies
uniqueWords = unique(allWords);
freq = zeros(size(uniqueWords));
for i = 1:length(uniqueWords)
    freq(i) = sum(strcmp(uniqueWords{i}, allWords));
end

% Score sentences by frequency of their words
scores = zeros(length(sentences), 1);
for i = 1:length(sentences)
    tokens = lower(split(sentences{i}));
    for j = 1:length(tokens)
        idx = find(strcmp(tokens{j}, uniqueWords));
        if ~isempty(idx)
            scores(i) = scores(i) + freq(idx);
        end
    end
end

% Pick sentence with highest score as summary
[~, bestIdx] = max(scores);
summary = sentences{bestIdx};

disp("Summary:");
disp(summary);
