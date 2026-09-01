%% Code 9: keyword extraction by frequency
%
% Tokenize -> drop stop words and punctuation -> count -> take the top 5.
%
% Two preprocessing details decide whether the answer means anything.

clear; clc;

text = "Data science involves extracting insights from structured and " + ...
       "unstructured data using statistical and machine learning techniques.";

document = tokenizedDocument(text);

% (1) LOWERCASE FIRST.
% tokenizedDocument is case sensitive, so "Data" at the start of the
% sentence and "data" in the middle are two different tokens. In this
% paragraph "data" occurs 3 times but is counted as Data=2 and data=1,
% understating the single most important keyword by a third while every
% other word sits at 1. Remove this line and compare the two rankings.
document = lower(document);

% (2) ORDER MATTERS: strip punctuation BEFORE removing stop words.
% A token still carrying a full stop does not match the stop-word list,
% so "and." would survive a removal that "and" would not.
document = erasePunctuation(document);
document = removeStopWords(document);

bow = bagOfWords(document);

[sortedCounts, sortedIndex] = sort(bow.Counts, 'descend');
sortedWords = bow.Vocabulary(sortedIndex);

n = min(5, numel(sortedWords));
keywords = sortedWords(1:n);
counts   = sortedCounts(1:n);

disp("Extracted keywords:");
disp(table(keywords', counts', 'VariableNames', {'Keyword', 'Count'}));

%% Read the counts, not just the words
% Print them, because a ranking where everything ties at 1 is not a
% ranking --- it is vocabulary order wearing a ranking's clothes. Only
% "data" should stand above the rest here; the remaining four entries are
% chosen by tie-breaking, and a different tokenizer would list different
% ones. Say so in your report rather than presenting all five as findings.
