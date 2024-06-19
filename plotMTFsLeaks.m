function plotMTFsLeaks()
%% what g_L conductances do we wnat to use?
startValue = 0.282;
endValue = 14.1;
numPoints = 5;

% Calculate the starting and ending exponents for logspace
startExp = log10(startValue);
endExp = log10(endValue);

% Generate the vector
logSpacedVector = logspace(startExp, endExp, numPoints);

%% what AMPA & NMDA conductances do we want to use?
g_syn1_list = [0.05, 0.185, 0.68, 2.8, 300];
g_syn2_list = g_syn1_list/2; % nmda is 50% of AMPA
g_l_list = logSpacedVector; 

% set params as the same we ran for the fMod
fModStart = 16;
fModEnd = 512;
fModSteps = 4;

% Generate a vector of modulation frequencies
fMod = 2 .^ [log2(fModStart):1/fModSteps:log2(fModEnd)];

% how many freqs?
numFreqs = length(fMod);

% make blank vectors to hold the data
spikeCounts = [];
synchrony = [];
phase = [];

% run the model between start and end freqs and store spiketimes from each
% model
for j = 1:length(g_l_list)
    for i = 1:numFreqs
        % calculate the number of spikes at that fMod
        spiketimes = NMDAmodel(fMod(i), g_syn1_list(j), g_syn2_list(j), g_l_list(j));
        count = length(spiketimes);
    
        % pull out the fMod 
        fm = fMod(i);
    
        % convert spike times to radians to calculate vector strength
        spikeRads = mod(spiketimes/1000, 1/fm) * 2 * pi * fm;
        
        % second, calculate vector strength. p2 of GOldberg and Brown 1969
        % method
        x = cos(spikeRads);
        y = sin(spikeRads);
        r = sqrt(sum(x)^2 + sum(y)^2)/length(x);

        % add to the appropriate vector
        spikeCounts(i) = count;
        synchrony(i) = r;
        phase(i) = mean(spikeRads);
    end
    
    %% plot the rate MTF
    subplot(1, 2, 1)
    plot(log2(fMod), spikeCounts(:));
    hold on

    % label x axis ticks to show 3 tick labels
    xticks([log2(fMod(1)) log2(fMod(ceil(length(fMod)/2))) log2(fMod(end))]);
    xticklabels({num2str(fMod(1)) num2str(round(fMod(ceil(length(fMod)/2)))) num2str(fMod(end))});

    % label x and y axes
    xlabel('mod. freq. (Hz)')
    ylabel('# spikes');
    title('Rate MTF')
    legend(num2str(logSpacedVector(j)))

    %% plot the temporal MTF
    subplot(1, 2, 2)
    plot(log2(fMod), synchrony(:));
    % set y lim
    ylim([0 1]);
    
    % label x axis ticks to show 3 tick labels
    xticks([log2(fMod(1)) log2(fMod(ceil(length(fMod)/2))) log2(fMod(end))]);
    xticklabels({num2str(fMod(1)) num2str(round(fMod(ceil(length(fMod)/2)))) num2str(fMod(end))});
    
    % label x and y axes
    xlabel('mod. freq. (Hz)')
    ylabel('vector strength');
    title('Temporal MTF')
    hold on

end


end % for function
