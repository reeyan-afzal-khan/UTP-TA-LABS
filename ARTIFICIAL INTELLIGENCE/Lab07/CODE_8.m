% Clear all
clear; clc;

% Input sentence
text = "Bonjour, comment allez-vous aujourd'hui?";

% Define language-specific keywords
english = ["the", "and", "hello", "good"];
french = ["bonjour", "comment", "vous", "aujourd'hui"];
german = ["hallo", "wie", "geht", "ihnen"];

% Tokenize
words = lower(strsplit(text));

% Count matching words
enCount = sum(ismember(words, english));
frCount = sum(ismember(words, french));
deCount = sum(ismember(words, german));

% Detect language
[~, idx] = max([enCount, frCount, deCount]);
languages = ["English", "French", "German"];
disp("Detected Language:");
disp(languages(idx));
