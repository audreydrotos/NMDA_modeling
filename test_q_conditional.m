function [inputs,x] = test_q_conditional()

x = []; % hold qs
t_span = linspace(0, 1000, 1000);
presyn_spike_width = 1;
inputs = createInputVector(8);

for t = 1:length(t_span)
    % calculate the input spike right before the first spike, if there is
    % one
    prior_inputs = inputs(inputs < t);
    if ~isempty(prior_inputs)
        maximum = max(prior_inputs);
        diff = t - maximum;
        if diff <= presyn_spike_width && t > 10.0
            q = 1; % during the spike
        else
            q = 0; % not during the spike
        end
    else
        q = 1; % during the first spike
    end
    
    x(end+1) = q;
end

end %% for function