function inputs = createInputVector(modFreq)

% Time duration of the simulation
t_final=1000; % duration of simulation in msec

% Create vector with inputs evenly spaced
% inputs = linspace(0, t_final, modFreq+1);
inputs = 0:1000/modFreq:t_final;

% Add +/- 3ms jitter to each input
% First, generate vector of n = modFreq numbers from a gaussian
% distribution
jitter = randn(1, length(inputs))*1;

% Add these together
inputs = inputs + jitter;

% shift inputs by 10 for start time
inputs = inputs + 10;

end % for function