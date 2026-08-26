% Text Similarity using Word Embeddings


% Clear previous variables and console
clear; clc;

text1 = "She enjoys playing the piano every evening.";
text2 = "She likes to play piano at night.";

% text1 = "The government passed a new law on education.";
% text2 = "Apples and oranges are both healthy fruits.";

% text1 = "He completed his homework before dinner.";
% text2 = "He finished all his assignments ahead of the meal.";

% Define two English sentences for comparison
% text1 = "The quick brown fox jumps over the lazy dog.";
% text2 = "A fast brown animal leaps above a sleeping dog.";

% Tokenize the text (split into words, remove punctuation)
documents = tokenizedDocument([text1, text2]);

% Load pre-trained FastText word embeddings (if not downloaded, MATLAB will prompt)
emb = fastTextWordEmbedding;

% Extract unique vocabulary (words) from each sentence
words1 = string(documents(1).Vocabulary);
words2 = string(documents(2).Vocabulary);

% Filter out words that are not present in the embedding vocabulary
words1 = words1(isVocabularyWord(emb, words1));
words2 = words2(isVocabularyWord(emb, words2));

% Convert each word to its corresponding vector representation
vecs1 = word2vec(emb, words1);  
vecs2 = word2vec(emb, words2);

% Compute the average (mean) word vector to represent the whole sentence
vec1 = mean(vecs1, 1);
vec2 = mean(vecs2, 1);

% Calculate cosine similarity between the two sentence vectors
similarity = dot(vec1, vec2) / (norm(vec1) * norm(vec2));

% Display the similarity result
fprintf("Cosine Similarity between the two texts: %.4f\n", similarity);
