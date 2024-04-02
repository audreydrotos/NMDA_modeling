function [x_decay, y_decay, rise_time_10_90, decay_tau_1] = calcNMDAriseAndDecay(v, t)

v = v - v(40); % baseline data so the fit works

% find the kinetics of this response
% first pull out v at the time points we care about
epsp = v(400:end);
time = t(400:end);

% Find the index for time 500
index_start = find(time >= 500, 1, 'first');

% calculate baseline as average signal before time 500
baseline = mean(epsp(1:index_start));

% find the peak value of the EPSP
[peak_value, index_peak] = max(epsp(index_start:end));

% correct index_peak to align with the full EPSP vector
index_peak = index_peak + index_start - 1;

% calculate 10% and 90% rise times relative to the baseline
amplitude_10 = baseline + 0.1 * (peak_value - baseline);
amplitude_90 = baseline + 0.9 * (peak_value - baseline);

% find the indices where the EPSP first crosses these two amplitudes
index_10 = find(epsp >= amplitude_10 & time >= time(index_start), 1, 'first');
index_90 = find(epsp >= amplitude_90 & time >= time(index_start), 1, 'first');

% calculate 10-90% rise time
rise_time_10_90 = time(index_90) - time(index_10);

% find the index for time 600 where decay fit should end
index_end = find(time >= 700, 1, 'first');

% for decay Tau, fit exponential decay to the falling phase after the peak
% we assume that the decay phase starts immediately after the peak
x_decay = time(index_peak+5:index_end);  % Time points during decay
y_decay = epsp(index_peak+5:index_end);  % EPSP values during decay

% perform the fit using a single-term exponential model
% fit_type = 'exp2';
% [decay_fit, gof] = fit(x_decay, y_decay, fit_type);

fit_type = 'exp1';
[decay_fit, gof] = fit(x_decay, y_decay, fit_type);

% % extract the tau (time constant) from the fit parameters
% decay_tau_1 = -1 / decay_fit.b;  % This gives you the first decay time constant
% decay_tau_2 = -1 / decay_fit.d;  % This gives you the second decay time constant

decay_tau_1 = -1 / decay_fit.b;  % This gives you the first decay time constant

% Display the decay constants
fprintf('The first decay time constant (tau_1) of the EPSP is %f ms\n', decay_tau_1);
% fprintf('The second decay time constant (tau_2) of the EPSP is %f ms\n', decay_tau_2);

% Display results
fprintf('The 10-90%% rise time of the EPSP is %f ms\n', rise_time_10_90);

% Plot the data and fit for visualization
figure;
plot(time, epsp, 'b-', 'LineWidth', 1.5); % Original data
hold on;
plot(decay_fit, x_decay, y_decay, 'g'); % Exponential decay fit
hold on;
plot(time(index_10:index_90), epsp(index_10:index_90), 'r.'); % Highlight rise times

legend('EPSP Data', 'Decay Points', 'Exponential Decay Fit', 'Location', 'Best');
xlabel('Time (ms)');
ylabel('EPSP Amplitude (mV)');
title('EPSP and Decay Fit');
grid on;

end % for function