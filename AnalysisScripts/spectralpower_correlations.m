clear;
clc;

%Change directory to match where appropriate functions are saved
addpath('..\AnalysisFunctions\');
addpath(genpath('..\ssvep_musicbox\'));

%Change directory of filelisting to appropriate subject
fileListing = dir('..\als_participantdata');
filterCutoffs = [5, 50];
samplingRate = 256; %samplingRate
percGoodBadTrials = 1; %The percentage of good and bad trials to select (if =1, selects all trials)
channels = 1:8; %use channels 1-8 for analysis, change to only include specific electrodes
analysis_code = 2; %Segment good/bad trials according to CCA scores (if =1, segments according to sum of harmonics)
best_trials = true; %returns the best trials in segment_bestworst_trials function


 %Create the CCA variables for a given window length
pad_before_stimulation = 0.160; %The number of seconds of the stimulus time that are removed at the beginning
pad_before_ISI = 0.160; %The number of seconds of the inter-stimulus interval that are removed at the beginning
pad_before = [pad_before_stimulation, pad_before_ISI];
target_freq = 7.5; %Target frequency in Hz (stimulus flashing frequency)
windowLengthCCA = 1; %windowLength time in seconds 
overlapCCA = 0.5; %Time of overlap in sliding window for CCA
harmonics = 6; %Number of harmonics used for CCA analysis
trial_time = 20; %Trial time used for CCA analysis
trial_time_ISI = 15;  %Trial time used for CCA analysis
trial_time = [trial_time, trial_time_ISI];


[segments, segment_states, best_i, best_j, worst_i, worst_j] = ...
    segment_bestworst_trials(fileListing, filterCutoffs, samplingRate, ...
    percGoodBadTrials, channels, analysis_code, best_trials);

cutoffs  = [1,8; 8, 12; 40, 100];

relative_powers_alltrials = zeros(numel(segments), 3); 
mCC_diff_ratios = zeros(numel(segments),1);

for i=1:numel(segments)
    trial = segments{i};
    trial_states = segment_states{i};

    [relative_powers_SFI, percent_diffs, absolute_diffs] = calc_power_change(trial,trial_states, cutoffs, samplingRate, channels);

    relative_powers_alltrials(i,:) = percent_diffs;

    [mCC_diff, mCC_diff_ratio, r_tstim, r_tISI, canon_corr_stim, canon_corr_ISI] = calc_CCA_change(trial, trial_states, ...
        pad_before, trial_time, samplingRate, windowLengthCCA, overlapCCA, channels, target_freq, harmonics);

    mCC_diff_ratios(i) = mCC_diff_ratio;

end

close all;
figure;
subplot(3,1,1);
scatter(relative_powers_alltrials(:,1), mCC_diff_ratios);
hold on;
xlabel('Change in Relative Power Between SFI and ISI in the 1-8Hz Band');
ylabel('CCA Ratio');
hold off;

subplot(3,1,2);
scatter(relative_powers_alltrials(:,2), mCC_diff_ratios);
hold on;
xlabel('Change in Relative Power Between SFI and ISI in the 8-12Hz Band');
ylabel('CCA Ratio');
hold off;

subplot(3,1,3);
scatter(relative_powers_alltrials(:,3), mCC_diff_ratios);
hold on;
xlabel('Change in Relative Power Between SFI and ISI in the 40-100Hz Band');
ylabel('CCA Ratio');
hold off;
