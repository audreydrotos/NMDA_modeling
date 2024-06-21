function plotMTFsmodel()

% what AMPA & NMDA conductances do we want to use?
g_syn1 = 0.25;
g_syn2_list = [0 g_syn1*0.25];
g_l = 0.7; % VIP neuron

% set params as the same we ran for the fMod
fModStart = 16;
fModEnd = 512;
fModSteps = 4;

% Generate a vector of modulation frequencies
fMod = 2 .^ [log2(fModStart):1/fModSteps:log2(fModEnd)];

% how many freqs?
numFreqs = length(fMod);

% make blank vectors to hold the data
spikeCounts_AMPA = [];
synchrony_AMPA = [];
phase_AMPA = [];

spikeCounts_NMDA = [];
synchrony_NMDA = [];
phase_NMDA = [];

% run the model between start and end freqs and store spiketimes from each
% model
for j = 1:length(g_syn2_list)
    for i = 1:numFreqs
        % calculate the number of spikes at that fMod
        spiketimes = NMDAmodel(fMod(i), g_syn1, g_syn2_list(j), g_l);
        spiketimes = spiketimes - 10;
        count = length(spiketimes);
    
        % pull out the fMod 
        fm = fMod(i);
    
        % convert spike times to radians to calculate vector strength
        spikeRads = mod(spiketimes/1000, 1/fm) * 2 * pi * fm; % spike times need to be in s for this and code gives in ms
        
        % second, calculate vector strength. p2 of Goldberg and Brown 1969
        % method
        x = cos(spikeRads);
        y = sin(spikeRads);
        r = sqrt(sum(x)^2 + sum(y)^2)/length(x);

        % add to the appropriate vector
        if j == 1
            spikeCounts_AMPA(i) = count;
            synchrony_AMPA(i) = r;
            phase_AMPA(i) = mean(spikeRads);
        else
            spikeCounts_NMDA(i) = count;
            synchrony_NMDA(i) = r;
            phase_NMDA(i) = mean(spikeRads);
        end
    end
end

%% plot the rate MTF
figure('Position', [0 0 1000 500])
subplot(1, 3, 1)
plot(log2(fMod), spikeCounts_AMPA(:), 'Color', '#2a9d8f');
hold on
plot(log2(fMod), spikeCounts_NMDA(:), 'Color', '#e76f51');

% label x axis ticks to show 3 tick labels
xticks([log2(fMod(1)) log2(fMod(ceil(length(fMod)/2))) log2(fMod(end))]);
xticklabels({num2str(fMod(1)) num2str(round(fMod(ceil(length(fMod)/2)))) num2str(fMod(end))});

% label x and y axes
xlabel('mod. freq. (Hz)')
ylabel('# spikes');
title('Rate MTF')

legend('AMPA only', 'AMPA + NMDA'); % Add legend

%% plot the temporal MTF
subplot(1, 3, 2)
plot(log2(fMod), synchrony_AMPA(:), 'Color', '#2a9d8f');
hold on
plot(log2(fMod), synchrony_NMDA(:), 'Color', '#e76f51');
 
% set y lim
ylim([0 1]);

% label x axis ticks to show 3 tick labels
xticks([log2(fMod(1)) log2(fMod(ceil(length(fMod)/2))) log2(fMod(end))]);
xticklabels({num2str(fMod(1)) num2str(round(fMod(ceil(length(fMod)/2)))) num2str(fMod(end))});

% label x and y axes
xlabel('mod. freq. (Hz)')
ylabel('vector strength');
title('Temporal MTF')
hold off

%% plot the phase
subplot(1, 3, 3);

% create the third subplot space in the same 1x3 grid layout at position 3
% and retrieve its position.
subplotHandle = subplot(1, 3, 3);
pos = get(subplotHandle, 'Position'); % Get the position to use for the polar axes

% delete the empty third Cartesian axes created by the previous `subplot` to make room for the polar plot
delete(subplotHandle);

% create the polar axes manually and place it where the last subplot would be
pax = polaraxes('Position', pos);

% continue plot
hold(pax, 'on');
logFreqs = log2(fMod);

for i = 1:length(phase_AMPA)
    polarplot(pax, phase_AMPA(i), logFreqs(i), 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', '#2a9d8f');
end

for i = 1:length(phase_NMDA)
    polarplot(pax, phase_NMDA(i), logFreqs(i), 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', '#e76f51');
end

hold(pax, 'off');
title(pax, 'Phase MTF');
set(pax, 'ThetaDir', 'clockwise');

end % for function
