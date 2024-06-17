function [rise_time_10_90_list,decay_tau_1_list, current_params] = findBestModelParams()

% param space to test
% g_syn1_list = 0.1:0.2:10;
% tau_d1_list = 10:5:200;
% tau_r1_list = 10:5:200;

% function troubleshooting
g_syn1_list = 1; % hold constant
tau_d1_list = 10:5:50;
tau_r1_list = 20:20:500;

% lists to save vars
rise_time_10_90_list = [];
decay_tau_1_list = [];

% create list to save outputs
numRows = length(g_syn1_list) * length(tau_d1_list) * length(tau_r1_list);
current_params = zeros(numRows, 3);

% start counter
k = 1;

% iterate over the param space
for x = 1:length(g_syn1_list)
    for y = 1:length(tau_d1_list)
        for z = 1:length(tau_r1_list)

            % run the model
            [t,v] = findNMDAkinetics(g_syn1_list(x), tau_d1_list(y), tau_r1_list(z));

            % find the values
            [~, ~, rise_time_10_90, decay_tau_1] = calcNMDAriseAndDecay(v, t);

            % save the values to a list
            rise_time_10_90_list(k) = rise_time_10_90;
            decay_tau_1_list(k) = decay_tau_1;

            % save current params to a list in order of g_syn, tau_d1,
            % tau_r1
            current_params(k, 1) = g_syn1_list(x);
            current_params(k, 2) = tau_d1_list(y);
            current_params(k, 3) = tau_r1_list(z);

            k = k + 1; % update counter

        end
    end
end

end % for function