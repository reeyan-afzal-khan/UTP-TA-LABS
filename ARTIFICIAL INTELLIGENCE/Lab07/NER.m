clc; clear;

% Sample input sentence
text = "Barack Obama was born in Hawaii and served as the 44th President of the United States.";

% Define simple rule-based dictionaries
personList = ["Barack Obama"];
locationList = ["Hawaii", "United States"];
organizationList = ["United Nations", "Google", "Microsoft"];

% Tokenize
tokens = split(text);
disp("Named Entities Identified:");

for i = 1:length(tokens)
    word = erase(tokens{i}, '.'); % Remove punctuation
    if any(strcmp(word, personList))
        fprintf("Person: %s\n", word);
    elseif any(strcmp(word, locationList))
        fprintf("Location: %s\n", word);
    elseif any(strcmp(word, organizationList))
        fprintf("Organization: %s\n", word);
    end
end
