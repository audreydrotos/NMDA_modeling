function [rise_time_10_90, decay_tau] = calcNMDAriseAndDecay(v, t)

% find the kinetics of this response
% first pull out v at the time points we care about
epsp = v(400:end);
time = t(400:end);

% Find the index for time 500
index_start = find(time >= 500, 1, 'first');

% Calculate baseline as average signal before time 500
baseline = mean(epsp(1:index_start));

% Now find the peak value of the EPSP
[peak_value, index_peak] = max(epsp(index_start:end));

% Correct index_peak to align with the full EPSP vector
index_peak = index_peak + index_start - 1;

% Calculate 10% and 90% rise times relative to the baseline
amplitude_10 = baseline + 0.1 * (peak_value - baseline);
amplitude_90 = baseline + 0.9 * (peak_value - baseline);

% Find the indices where the EPSP first crosses these two amplitudes
index_10 = find(epsp >= amplitude_10 & time >= time(index_start), 1, 'first');
index_90 = find(epsp >= amplitude_90 & time >= time(index_start), 1, 'first');

% Calculate 10-90% rise time
rise_time_10_90 = time(index_90) - time(index_10);

% Find the index for time 800 where decay fit should end
index_end = find(time >= 700, 1, 'first');

% For decay Tau, fit exponential decay to the falling phase after the peak
% We assume that the decay phase starts immediately after the peak
x_decay = time(index_peak:index_end);  % Time points during decay
y_decay = epsp(index_peak:index_end);  % EPSP values during decay

% Perform the fit using a single-term exponential model
fit_type = 'exp1';
[decay_fit, ~] = fit(x_decay, y_decay, fit_type);

% Extract the tau (time constant) from the fit parameters
decay_tau = -1 / decay_fit.b;

% Display results
fprintf('The 10-90%% rise time of the EPSP is %f ms\n', rise_time_10_90);
fprintf('The decay tau of the EPSP is %f ms\n', decay_tau);

% Plot the data and fit for visualization
figure;
plot(time, epsp, 'b-', 'LineWidth', 1.5); % Original data
hold on;
plot(decay_fit, x_decay, y_decay, 'g'); % Exponential decay fit
hold on;
% plot(time(index_10:index_90), epsp(index_10:index_90), 'r.'); % Highlight rise times

legend('EPSP Data', 'Exponential Decay Fit', 'Location', 'Best');
xlabel('Time (ms)');
ylabel('EPSP Amplitude (mV)');
title('EPSP and Decay Fit');
grid on;

end % for function