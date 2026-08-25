% Clear workspace
clear; clc;

% Multiple sentences as paragraph
text = [
    "Artificial Intelligence is transforming every industry.", ...
    "Machine learning enables systems to learn patterns from data.", ...
    "Deep learning uses neural networks with many layers.", ...
    "AI helps businesses automate tasks and improve efficiency."
];

% Convert to tokenized documents
documents = tokenizedDocument(text);

% Create bag-of-words model
bag = bagOfWords(documents);

% Convert to TF-IDF
tfidfMatrix = tfidf(bag);

% Find the sentence with the highest sum of TF-IDF scores
score = sum(tfidfMatrix, 2);
[~, idx] = max(score);

% Display summary
disp("Summary Sentence:");
disp(text(idx));
