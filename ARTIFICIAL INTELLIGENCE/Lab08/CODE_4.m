clc; clear;

%% * Items (weights and values)
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

%% * Plot
figure;
plot(1:maxGen, bestFitness, 'm-', 'LineWidth', 2);
xlabel('Generation'); ylabel('Max Value');
title('GA for Knapsack Problem');
grid on;

%% ---------- Report the solution ----------
% Re-evaluate the final population, then DECODE the winning chromosome
% back into a list of items -- a binary string is not an answer.
finalFitness = zeros(popSize, 1);
for i = 1:popSize
    w = sum(pop(i,:) .* weights);
    if w <= capacity
        finalFitness(i) = sum(pop(i,:) .* values);
    else
        finalFitness(i) = 0;
    end
end
[bestVal, bestIdx] = max(finalFitness);
best = pop(bestIdx,:);

fprintf('\n=== Result: 0-1 knapsack, capacity %d ===\n', capacity);
fprintf('  chromosome     : [%s]\n', num2str(best));
fprintf('  items chosen   : %s\n', mat2str(find(best)));
fprintf('  total weight   : %d / %d\n', sum(best .* weights), capacity);
fprintf('  total value    : %d\n', bestVal);

% Brute force is feasible at 4 items (16 combinations) and proves whether
% the GA actually found the optimum. Always check a small case this way.
bestBrute = 0; bestSet = [];
for mask = 0:(2^chromLength - 1)
    pick = bitget(mask, 1:chromLength);
    if sum(pick .* weights) <= capacity && sum(pick .* values) > bestBrute
        bestBrute = sum(pick .* values);
        bestSet = pick;
    end
end
fprintf('  brute-force optimum : %d  (items %s)\n', bestBrute, mat2str(find(bestSet)));
if bestVal == bestBrute
    fprintf('  -> GA found the optimum\n');
else
    fprintf('  -> GA fell short by %d\n', bestBrute - bestVal);
end
