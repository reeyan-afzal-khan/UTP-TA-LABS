%Image Captioning using AlexNet

% Clear environment
clear; clc;

% Load an example image for object recognition
img = imread('speed.jpg');  % Replace with your own image
imshow(img);
title('Input Image');

% Load AlexNet pretrained CNN
net = alexnet;

% Resize image to match the required input size of AlexNet
imgResized = imresize(img, net.Layers(1).InputSize(1:2));

% Extract features from the 'fc7' layer (fully connected)
featureLayer = 'fc7';
features = activations(net, imgResized, featureLayer, 'OutputAs', 'rows');

% Classify the object in the image using AlexNet
[label, scores] = classify(net, imgResized);

% Display predicted class label
disp(['Predicted Object: ', char(label)]);

% Generate a simple caption based on classification result
caption = "This is a picture of a " + lower(char(label)) + ".";

% Display the caption
disp("Generated Caption:");
disp(caption);
