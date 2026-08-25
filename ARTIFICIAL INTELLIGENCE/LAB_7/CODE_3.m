clc; clear;

inputSentence = "She go to school every day.";

% Define correction rules
patterns = ["go to school"];
corrections = ["goes to school"];

% Apply correction
corrected = inputSentence;
for i = 1:length(patterns)
    corrected = strrep(corrected, patterns(i), corrections(i));
end

disp("Original:");
disp(inputSentence);
disp("Corrected:");
disp(corrected);
