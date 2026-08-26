
clear all;
clc;



% Scene Text Detection and Offline Translation
% Load another image containing scene text
img = imread('street.jpg');  % Use any image with readable text
imshow(img);
title("Scene Text Image");

% Perform OCR (Optical Character Recognition) to extract text from the image
ocrResult = ocr(img);
detectedText = upper(strtrim(ocrResult.Text));  % Convert to uppercase and remove extra spaces
disp("Detected Text:");
disp(detectedText);

% Define a translation dictionary (English → French)
dictionary = containers.Map;
dictionary("STOP") = "ARRÊT";
dictionary("SPEED LIMIT") = "LIMITATION DE VITESSE";
dictionary("YIELD") = "CÉDEZ LE PASSAGE";
dictionary("NO PARKING") = "STATIONNEMENT INTERDIT";
dictionary("ONE WAY") = "SENS UNIQUE";
dictionary("DO NOT ENTER") = "ENTRÉE INTERDITE";
% dictionary("STREET") = "RUE";  % Make sure to use uppercase to match OCR

% Initialize default translation
translatedText = "Traduction indisponible.";  % Default fallback

% Iterate through dictionary keys and perform replacement if match is found
keys = dictionary.keys;
for i = 1:length(keys)
    if contains(detectedText, keys{i})
        % Replace English term with corresponding French translation
        translatedText = strrep(detectedText, keys{i}, dictionary(keys{i}));
    end
end

% Display the translated text
disp("Translated Text (French):");
disp(translatedText);

% % % % % % % % % % % 



% Example 2: Multi-language dictionary support

% clear; clc;
img = imread('speed.jpg');  % Replace with your own image
imshow(img); title("Road Sign");

ocrText = ocr(img);
text = upper(strtrim(ocrText.Text));
disp("Detected Text:"); disp(text);

% Multi-language dictionary
dictFR = containers.Map("STOP", "ARRÊT");
dictDE = containers.Map("STOP", "HALT");

if isKey(dictFR, text)
    disp("French: " + dictFR(text));
end
if isKey(dictDE, text)
    disp("German: " + dictDE(text));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Example 3: OCR + fuzzy keyword matching

% clear; clc;
img = imread('speed.jpg');
imshow(img); title('Traffic Sign');

ocrText = ocr(img);
text = upper(strtrim(ocrText.Text));
disp("Detected Text: " + text);

% Translate based on partial keywords
if contains(text, "PARK")
    disp("Translation: STATIONNEMENT INTERDIT (No Parking)");
elseif contains(text, "SPEED")
    disp("Translation: LIMITATION DE VITESSE (Speed Limit)");
else
    disp("Translation: Not found.");
end

% % % % % % % % % % % % % % % % 


