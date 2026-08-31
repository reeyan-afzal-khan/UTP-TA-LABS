clc; clear; close all;

%% * Function with roots at -2 and 3
fitnessFunc = @(x) (x - 3).^2 .* (x + 2).^2;

popSize = 30;
maxGen = 100;
pop = -5 + 10 * rand(popSize, 1);  % Range: [-5, 5]
mutRate = 0.1;

bestFitness = zeros(maxGen, 1);

for gen = 1:maxGen
    fitness = -fitnessFunc(pop);  % Maximize negative of function (minimize original)

    %% Selection
    prob = fitness - min(fitness) + eps;
    prob = prob / sum(prob);
    cumProb = cumsum(prob);
    newPop = zeros(size(pop));
    for i = 1:popSize
        r = rand;
        idx = find(cumProb >= r, 1);
        newPop(i) = pop(idx);
    end

    %% Crossover
    for i = 1:2:popSize
        if i+1 <= popSize
            alpha = rand;
            newPop(i) = alpha * newPop(i) + (1-alpha) * newPop(i+1);
            newPop(i+1) = alpha * newPop(i+1) + (1-alpha) * newPop(i);
        end
    end

    %% Mutation
    for i = 1:popSize
        if rand < mutRate
            newPop(i) = newPop(i) + 0.5 * randn;
            newPop(i) = max(-5, min(5, newPop(i)));
        end
    end

    pop = newPop;
    bestFitness(gen) = min(fitnessFunc(pop));
end

%% * Plot
figure;
plot(1:maxGen, bestFitness, 'k-', 'LineWidth', 2);
xlabel('Generation'); ylabel('Best f(x)');
title('GA: Find Minimum of (x-3)^2(x+2)^2');
grid on;

%% ---------- Report the solution ----------
finalObj = fitnessFunc(pop);                 % the ORIGINAL objective
[bestVal, bestIdx] = min(finalObj);
bestX = pop(bestIdx);

fprintf('\n=== Result: minimise (x-3)^2 (x+2)^2 ===\n');
fprintf('  best x         : %.6f\n', bestX);
fprintf('  f(x)           : %.6e\n', bestVal);

% Part D of the lab asks which root the run converged to. Answer it here
% rather than leaving the student to eyeball a plot.
if abs(bestX - 3) < abs(bestX + 2)
    fprintf('  converged nearer to root :  3\n');
else
    fprintf('  converged nearer to root : -2\n');
end

nearThree = sum(abs(pop - 3) < abs(pop + 2));
fprintf('  population split : %d near 3, %d near -2\n', nearThree, popSize - nearThree);
fprintf('\nBoth roots are global minima with f = 0. Which one a run finds\n');
fprintf('depends entirely on random initialisation -- rerun and compare.\n');
