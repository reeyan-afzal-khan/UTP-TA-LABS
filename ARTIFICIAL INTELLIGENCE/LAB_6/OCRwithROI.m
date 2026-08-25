% Example 4: OCR with ROI selection for better accuracy

clear; clc;
img = imread('stop.jpg'); 
imshow(img); title("Select Region for OCR");

% Manually select region
roi = drawrectangle;
pause(1);  % Wait for user to draw ROI

ocrRes = ocr(img, roi.Position);
text = upper(strtrim(ocrRes.Text));
disp("Detected Text: " + text);

% Translate
dict = containers.Map("NO PARKING", "STATIONNEMENT INTERDIT");
if isKey(dict, text)
    disp("Translated: " + dict(text));
else
    disp("Translation not found.");
end
