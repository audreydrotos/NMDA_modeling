function plotMTFsmodel()

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
for i = 1:numFreqs
    % calculate the number of spikes at that fMod
    spiketimes = NMDAmodel(fMod(i));
    count = length(spiketimes);

    % pull out the fMod 
    fm = fMod(i);

    % convert spike times to radians to calculate vector strength
    spikeRads = mod(spiketimes, 1/fm) * 2 * pi * fm;
    
    % second, calculate vector strength. p2 of GOldberg and Brown 1969
    % method
    x = cos(spikeRads);
    y = sin(spikeRads);
    r = sqrt(sum(x)^2 + sum(y)^2)/length(x);
    
    spikeCounts(i) = count;
    synchrony(i) = r;
    phase(i) = mean(spikeRads);

end

%% plot the rate MTF
figure('Position', [0 0 1000 500])
subplot(1, 3, 1)
plot(log2(fMod), spikeCounts(:));
hold on

% label x axis ticks to show 3 tick labels
xticks([log2(fMod(1)) log2(fMod(ceil(length(fMod)/2))) log2(fMod(end))]);
xticklabels({num2str(fMod(1)) num2str(fMod(ceil(length(fMod)/2))) num2str(fMod(end))});

% label x and y axes
xlabel('mod. freq. (Hz)')
ylabel('# spikes');
title('rate MTF')

%% plot the temporal MTF
subplot(1, 3, 2)
plot(log2(fMod), synchrony(:));
 
% set y lim
ylim([0 1]);

% label x axis ticks to show 3 tick labels
xticks([log2(fMod(1)) log2(fMod(ceil(length(fMod)/2))) log2(fMod(end))]);
xticklabels({num2str(fMod(1)) num2str(fMod(ceil(length(fMod)/2))) num2str(fMod(end))});

% label x and y axes
xlabel('mod. freq. (Hz)')
ylabel('vector strength');
title('temporal MTF')
hold off

%% plot the phase
subplot(1, 3, 3);

% Create the third subplot space in the same 1x3 grid layout at position 3
% and retrieve its position.
subplotHandle = subplot(1, 3, 3);
pos = get(subplotHandle, 'Position'); % Get the position to use for the polar axes

% Now, delete the empty third Cartesian axes created by the previous `subplot` to make room for the polar plot
delete(subplotHandle);

% Create the polar axes manually and place it where the last subplot would be
pax = polaraxes('Position', pos);

% Continue with your plotting as before
hold(pax, 'on');
logFreqs = log2(fMod); % Ensure `fMod` is defined with your frequency data

for i = 1:length(phase)
    polarplot(pax, phase(i), logFreqs(i), 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', '#2a9d8f');
end

hold(pax, 'off');
title(pax, 'Phase MTF');
set(pax, 'ThetaDir', 'clockwise');

end % for function
