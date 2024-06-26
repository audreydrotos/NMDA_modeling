function plotMTFsLeaksmodel()
%% what g_L conductances do we want to use?
% Generate the vector (pseudo log spaced now)
logSpacedVector = [0.2820, 0.5, 0.7499, 1.9940, 5.3025];

%% what AMPA & NMDA conductances do we want to use?
g_syn1_list = [0.05, 0.13, 0.185, 1, 4];
g_syn2_list = g_syn1_list/4; % nmda is 25% of AMPA
g_l_list = logSpacedVector; 

% set params as the same we ran for the fMod
fModStart = 16;
fModEnd = 512;
fModSteps = 4;

% Generate a vector of modulation frequencies
fMod = 2 .^ [log2(fModStart):1/fModSteps:log2(fModEnd)];

% how many freqs?
numFreqs = length(fMod);

% run the model between start and end freqs and store spiketimes from each
% model
% make blank vectors to hold the data
spikeCounts_AMPA = [];
synchrony_AMPA = [];
phase_AMPA = [];

spikeCounts_NMDA = [];
synchrony_NMDA = [];
phase_NMDA = [];

for j = 1:length(g_l_list)
    disp(['Running leak conductance: ' num2str(j)]);
    for i = 1:numFreqs
        for q = 1:5 % iterate over 5 times
            % calculate the number of spikes at that fMod for AMPA + NMDA
            spiketimes = NMDAmodel(fMod(i), g_syn1_list(j), g_syn2_list(j), g_l_list(j));
            count = length(spiketimes);
        
            % pull out the fMod 
            fm = fMod(i);
            
            if count > 4
                % convert spike times to radians to calculate vector strength
                spikeRads = mod(spiketimes/1000, 1/fm) * 2 * pi * fm; % spike times need to be in s for this and code gives in ms
                
                % second, calculate vector strength. p2 of GOldberg and Brown 1969
                % method
                x = cos(spikeRads);
                y = sin(spikeRads);
                r = sqrt(sum(x)^2 + sum(y)^2)/length(x);
            else
                spikeRads = NaN;
                r = NaN;
            end 
    
            % add to the appropriate vector
            spikeCounts_NMDA(q,i) = count;
            synchrony_NMDA(q,i) = r;
            phase_NMDA(q,i) = mean(spikeRads);
    
            % calculate the number of spikes at that fMod for AMPA only
            spiketimes = NMDAmodel(fMod(i), g_syn1_list(j), 0, g_l_list(j));
            count = length(spiketimes);
        
            % pull out the fMod 
            fm = fMod(i);
    
            if count > 4
                % convert spike times to radians to calculate vector strength
                spikeRads = mod(spiketimes/1000, 1/fm) * 2 * pi * fm; % spike times need to be in s for this and code gives in ms
                
                % second, calculate vector strength. p2 of GOldberg and Brown 1969
                % method
                x = cos(spikeRads);
                y = sin(spikeRads);
                r = sqrt(sum(x)^2 + sum(y)^2)/length(x);
            else
                spikeRads = NaN;
                r = NaN;
            end
    
            % add to the appropriate vector
            spikeCounts_AMPA(q,i) = count;
            synchrony_AMPA(q,i) = r;
            phase_AMPA(q,i) = nanmean(spikeRads);
        end

    end

    % add to vectors to average across each fMod for each iteration
    XspikeCounts_AMPA = mean(spikeCounts_AMPA);
    Xsynchrony_AMPA = mean(synchrony_AMPA);
    Xphase_AMPA = mean(phase_AMPA);
    XspikeCounts_NMDA = mean(spikeCounts_NMDA);
    Xsynchrony_NMDA = mean(synchrony_NMDA);
    Xphase_NMDA = mean(phase_NMDA);

    %% plot the rate MTF
    figure('Position', [0 0 700 150])
    subplot(1, 3, 1)
    plot(log2(fMod), XspikeCounts_AMPA(:), 'Color', '#2a9d8f');
    hold on
    plot(log2(fMod), XspikeCounts_NMDA(:), 'Color', '#e76f51');
    
    % label x axis ticks to show 3 tick labels
    xticks([log2(fMod(1)) log2(fMod(ceil(length(fMod)/2))) log2(fMod(end))]);
    xticklabels({num2str(fMod(1)) num2str(round(fMod(ceil(length(fMod)/2)))) num2str(fMod(end))});
    xlim([log2(fMod(1)) log2(fMod(end))]);

    % label x and y axes
    xlabel('mod. freq. (Hz)')
    ylabel('# spikes');
    title('Rate MTF')
    subtitle(num2str(g_l_list(j)))
    
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
    xlim([log2(fMod(1)) log2(fMod(end))]);

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
    rlim([0 log2(fMod(end))])
    hold off

end


end % for function
