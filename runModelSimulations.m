function runModelSimulations()
% create empty vectors
XspikeCounts_AMPA = [];
Xsynchrony_AMPA = []; 
Xphase_AMPA = [];
XspikeCounts_NMDA = [];
Xsynchrony_NMDA = [];
Xphase_NMDA = [];

% set params as the same we ran for the fMod
fModStart = 16;
fModEnd = 512;
fModSteps = 4;

% Generate a vector of modulation frequencies
fMod = 2 .^ [log2(fModStart):1/fModSteps:log2(fModEnd)];

% how many freqs?
numFreqs = length(fMod);

for i = 1:5
    [spikeCounts_AMPA, synchrony_AMPA, phase_AMPA, spikeCounts_NMDA, synchrony_NMDA, phase_NMDA] = plotMTFsmodel();

    % add to vectors
    XspikeCounts_AMPA(i,:) = spikeCounts_AMPA;
    Xsynchrony_AMPA(i,:) = synchrony_AMPA; 
    Xphase_AMPA(i,:) = phase_AMPA;
    XspikeCounts_NMDA(i,:) = spikeCounts_NMDA;
    Xsynchrony_NMDA(i,:) = synchrony_NMDA;
    Xphase_NMDA(i,:) = phase_NMDA;
end

% average across each column
XspikeCounts_AMPA = mean(XspikeCounts_AMPA);
Xsynchrony_AMPA = mean(Xsynchrony_AMPA);
Xphase_AMPA = mean(Xphase_AMPA);
XspikeCounts_NMDA = mean(XspikeCounts_NMDA);
Xsynchrony_NMDA = mean(Xsynchrony_NMDA);
Xphase_NMDA = mean(Xphase_NMDA);

% close all other plots
close all

%% plot the rate MTF
figure('Position', [0 0 1000 500])
subplot(1, 3, 1)
plot(log2(fMod), XspikeCounts_AMPA(:), 'Color', '#2a9d8f');
hold on
plot(log2(fMod), XspikeCounts_NMDA(:), 'Color', '#e76f51');

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
plot(log2(fMod), Xsynchrony_AMPA(:), 'Color', '#2a9d8f');
hold on
plot(log2(fMod), Xsynchrony_NMDA(:), 'Color', '#e76f51');
 
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
    polarplot(pax, Xphase_AMPA(i), logFreqs(i), 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', '#2a9d8f');
end

for i = 1:length(phase_NMDA)
    polarplot(pax, Xphase_NMDA(i), logFreqs(i), 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', '#e76f51');
end

hold(pax, 'off');
title(pax, 'Phase MTF');
set(pax, 'ThetaDir', 'clockwise');