clc; clear; close all;

%% 🎯 Simulated dataset
x = linspace(0, 10, 100)';
true_w = [2.5, 5];             % True slope and intercept
y = true_w(1)*x + true_w(2) + randn(size(x));  % Add noise

%% GA Settings
popSize = 30;
dims = 2;                     % w1 and w2
pop = -10 + 20 * rand(popSize, dims);  % [-10,10] range
maxGen = 50;
mutRate = 0.1;
fitnessFunc = @(w) mean((y - (w(1)*x + w(2))).^2);  % MSE

bestFitness = zeros(maxGen, 1);

for gen = 1:maxGen
    fitness = zeros(popSize, 1);
    for i = 1:popSize
        fitness(i) = fitnessFunc(pop(i,:));
    end

    %% Selection
    invFitness = 1 ./ (fitness + 1e-6);
    prob = invFitness / sum(invFitness);
    cumProb = cumsum(prob);
    newPop = zeros(size(pop));
    for i = 1:popSize
        r = rand;
        idx = find(cumProb >= r, 1);
        newPop(i,:) = pop(idx,:);
    end

    %% Crossover
    for i = 1:2:popSize
        if i+1 <= popSize
            alpha = rand;
            newPop(i,:) = alpha * newPop(i,:) + (1-alpha) * newPop(i+1,:);
            newPop(i+1,:) = alpha * newPop(i+1,:) + (1-alpha) * newPop(i,:);
        end
    end

    %% Mutation
    for i = 1:popSize
        if rand < mutRate
            newPop(i,:) = newPop(i,:) + 0.5 * randn(1, dims);
        end
    end

    pop = newPop;
    bestFitness(gen) = min(fitness);
end

%% 📈 Plot
figure;
plot(1:maxGen, bestFitness, 'g-', 'LineWidth', 2);
xlabel('Generation'); ylabel('Best MSE');
title('GA Linear Regression Optimization');
grid on;
