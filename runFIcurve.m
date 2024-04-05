function [i_ext_list numSpikesList] = runFIcurve()

% i_ext to run
i_ext_list = 1:0.5:40;

% create empty vector to store spikes
numSpikesList = [];

for q = 1:length(i_ext_list)

    % run the model with various i_ext params
    spiketimes = NMDAmodel_FIcurve(0, i_ext_list(q)); % mod freq here is 0

    % how many spikes?
    if isempty(spiketimes)
        numSpikes = 0;
    else
        numSpikes = length(spiketimes);
    end

    % add to vector
    numSpikesList = [numSpikesList numSpikes];

end

plot(i_ext_list, numSpikesList)
xlabel('i external')
ylabel('number of spikes')

