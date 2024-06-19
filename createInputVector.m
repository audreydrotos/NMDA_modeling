function inputs = createInputVector(modFreq)

% Time duration of the simulation
t_final=1000; % duration of simulation in msec

% Create vector with inputs evenly spaced
inputs = linspace(0, t_final, modFreq);

% Add +/- 3ms jitter to each input
% First, generate vector of n = modFreq numbers from a gaussian
% distribution
jitter = randn(1, length(inputs));

% Add these together
inputs = inputs + jitter;

end % for function