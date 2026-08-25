clc; clear;

sentence = "The dog chased the cat.";

% Simulated POS tags
words = split(sentence);
tags = ["DET", "NOUN", "VERB", "DET", "NOUN"];

disp("Word   -  POS Tag");
for i = 1:length(words)
    fprintf("%-7s -  %s\n", words{i}, tags{i});
end
