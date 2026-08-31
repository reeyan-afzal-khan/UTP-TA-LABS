clc; clear; close all;

%% * Problem Definition
% Maximize f(x) = x * sin(10*pi*x) + 1 over x  in  [0, 1]
% We use a real-coded GA (continuous values for x)

popSize = 20;         % Number of individuals (solutions)
chromLength = 1;      % One decision variable (x)
maxGen = 50;          % Number of generations (iterations)
crossRate = 0.8;      % Crossover rate (80% of individuals undergo crossover)
mutRate = 0.1;        % Mutation rate (10%)

%% * Step 1: Initialize Population
% Each individual is a random number between 0 and 1
pop = rand(popSize, chromLength);  % Random values of x  in  [0, 1]

%% * Step 2: Define Fitness Function
% The higher the function value, the fitter the individual
fitnessFunc = @(x) x .* sin(10 * pi * x) + 1;

% Track best fitness over generations
bestFitness = zeros(maxGen, 1);

%% * Step 3: Run the GA for multiple generations
for gen = 1:maxGen
    % Step 3.1: Calculate fitness for all individuals
    fitness = fitnessFunc(pop);  % Evaluate the objective for all x values

    %% Step 3.2: Selection (Roulette Wheel)
    % The fitter an individual, the more likely it will be selected
    prob = fitness / sum(fitness);         % Normalize probabilities
    cumProb = cumsum(prob);                % Cumulative probability
    newPop = zeros(size(pop));             % New population (empty)
    for i = 1:popSize
        r = rand;
        idx = find(cumProb >= r, 1, 'first');  % Select individual
        newPop(i,:) = pop(idx,:);
    end

    %% Step 3.3: Crossover (Arithmetic Crossover)
    for i = 1:2:popSize
        if i+1 <= popSize && rand < crossRate
            alpha = rand;  % Blend factor
            % Blend the two parents to create two children
            temp1 = alpha * newPop(i,:) + (1 - alpha) * newPop(i+1,:);
            temp2 = alpha * newPop(i+1,:) + (1 - alpha) * newPop(i,:);
            newPop(i,:) = temp1;
            newPop(i+1,:) = temp2;
        end
    end

    %% Step 3.4: Mutation
    % Slightly change a few genes to maintain diversity
    for i = 1:popSize
        if rand < mutRate
            mutationValue = 0.1 * (rand - 0.5);  % Small change
            newPop(i,:) = newPop(i,:) + mutationValue;
            % Keep the value within [0,1]
            newPop(i,:) = max(0, min(1, newPop(i,:)));
        end
    end

    %% Step 3.5: Replace population
    pop = newPop;

    %% Step 3.6: Record best fitness value
    bestFitness(gen) = max(fitness);
end

%% * Plot the Result
figure;
plot(1:maxGen, bestFitness, 'b-', 'LineWidth', 2);
xlabel('Generation');
ylabel('Best Fitness Value');
title('GA Optimization: f(x) = x sin(10pix) + 1');
grid on;

%% ---------- Report the solution ----------
% The loop above only recorded best fitness per generation. The lab asks
% for the best CHROMOSOME, so evaluate the final population and report it.
finalFitness = fitnessFunc(pop);
[bestVal, bestIdx] = max(finalFitness);      % maximisation problem

fprintf('\n=== Result: maximise f(x) = x*sin(10*pi*x) + 1 ===\n');
fprintf('  best x         : %.6f\n', pop(bestIdx));
fprintf('  best f(x)      : %.6f\n', bestVal);
fprintf('  known optimum  : f(0.8551) ~= 1.8551\n');
fprintf('\nNote: without elitism the best individual can be lost between\n');
fprintf('generations, so the final population may be WORSE than the peak\n');
fprintf('of the convergence plot. Compare the two before concluding.\n');
