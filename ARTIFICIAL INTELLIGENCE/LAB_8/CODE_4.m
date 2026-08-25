clc; clear;

%% 🎯 Items (weights and values)
weights = [2 3 4 5];
values = [3 4 5 8];
capacity = 5;

popSize = 20;
chromLength = length(weights);   % 4 items
pop = round(rand(popSize, chromLength));  % Binary representation
maxGen = 50;
mutRate = 0.05;

bestFitness = zeros(maxGen, 1);

for gen = 1:maxGen
    fitness = zeros(popSize, 1);
    for i = 1:popSize
        totalWeight = sum(pop(i,:) .* weights);
        totalValue = sum(pop(i,:) .* values);
        if totalWeight <= capacity
            fitness(i) = totalValue;
        else
            fitness(i) = 0;  % Penalize overweight
        end
    end

    %% Selection
    prob = fitness / sum(fitness + eps);
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
            point = randi(chromLength-1);
            newPop([i, i+1], point+1:end) = newPop([i+1, i], point+1:end);
        end
    end

    %% Mutation
    for i = 1:popSize
        if rand < mutRate
            gene = randi(chromLength);
            newPop(i, gene) = 1 - newPop(i, gene);  % Flip bit
        end
    end

    pop = newPop;
    bestFitness(gen) = max(fitness);
end

%% 📈 Plot
figure;
plot(1:maxGen, bestFitness, 'm-', 'LineWidth', 2);
xlabel('Generation'); ylabel('Max Value');
title('GA for Knapsack Problem');
grid on;
