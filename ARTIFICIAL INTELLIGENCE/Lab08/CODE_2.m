clc; clear; close all;

%% * Objective: Minimize the Rosenbrock function
popSize = 30;
dims = 2;                      % Two variables: x and y
pop = -2 + 4 * rand(popSize, dims);  % Range: [-2, 2]
maxGen = 100;
mutRate = 0.1;

fitnessFunc = @(v) (1 - v(:,1)).^2 + 100*(v(:,2) - v(:,1).^2).^2;

bestFitness = zeros(maxGen, 1);

for gen = 1:maxGen
    fitness = fitnessFunc(pop);       % Lower is better

    %% Selection: Roulette Wheel (invert fitness for minimization)
    invFitness = 1 ./ (fitness + 1e-6);  
    prob = invFitness / sum(invFitness);
    cumProb = cumsum(prob);
    newPop = zeros(size(pop));
    for i = 1:popSize
        r = rand;
        idx = find(cumProb >= r, 1, 'first');
        newPop(i,:) = pop(idx,:);
    end

    %% Crossover: Single-point
    for i = 1:2:popSize
        if i+1 <= popSize
            point = randi([1, dims]);
            newPop([i, i+1], point:end) = newPop([i+1, i], point:end);
        end
    end

    %% Mutation
    for i = 1:popSize
        if rand < mutRate
            newPop(i,:) = newPop(i,:) + 0.1 * randn(1, dims);
            newPop(i,:) = max(-2, min(2, newPop(i,:)));  % Keep in range
        end
    end

    pop = newPop;
    bestFitness(gen) = min(fitnessFunc(pop));
end

%% * Plotting
figure;
plot(1:maxGen, bestFitness, 'r-', 'LineWidth', 2);
xlabel('Generation'); ylabel('Best Fitness');
title('GA Minimization: Rosenbrock Function');
grid on;

%% ---------- Report the solution ----------
finalFitness = fitnessFunc(pop);
[bestVal, bestIdx] = min(finalFitness);      % minimisation problem

fprintf('\n=== Result: minimise the Rosenbrock function ===\n');
fprintf('  best (x1, x2)  : (%.6f, %.6f)\n', pop(bestIdx,1), pop(bestIdx,2));
fprintf('  best f         : %.6f\n', bestVal);
fprintf('  known optimum  : f(1, 1) = 0\n');
fprintf('\nRosenbrock has a narrow curved valley. Reaching the valley is\n');
fprintf('easy; travelling along it to (1,1) is the hard part. Expect the\n');
fprintf('result to sit in the valley but short of the optimum.\n');
