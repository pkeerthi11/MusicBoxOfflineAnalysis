%Produces plots and data for individual subject
%Inputs:
%fileListing: directory in which the subject's raw data is stored

%Outputs:
%stft_ave_stim: averaged short-time Fourier transform magnitiudes
%ssvep_score_t_stim: the averaged SSVEP score at each time point for flashing stimulus
%canon_corr_stim_t_ave: the averaged CCA score at each time point for flashing stimulus
%t_stim: time points at which ssvep score is evaluated for flashing stimulus (STFT is performed)
%f_stim: frequency points at which STFT is performed
%t_stim_cca: time at which CCA score evaluated (when stimulus is flashing)
%t_isi: time points at which ssvep score is evaluated when stimulus non flashing (STFT is performed)
%ssvep_score_t_isi: the averaged SSVEP score at each time point when stimulus not flashing
%t_ISI_cca: time at which CCA score evaluated (when stimulus isn't flashing)
%canon_corr_ISI_t_ave:  the averaged CCA score at each time point for when stimulus not flashing


function [stft_ave_stim, ssvep_score_t_stim, canon_corr_stim_t_ave, ...
    t_stim, f_stim, t_stim_cca, t_isi, ssvep_score_t_isi ...
    t_ISI_cca, canon_corr_ISI_t_ave] = analyze_subject(fileListing)

%Required values for trial extraction
filterCutoffs = [5, 50]; %Upper and lower frequency bins for cutoff
samplingRate = 256; %Sampling rate (Hz)

%For both methods, decide percent of good and bad trials to select
percGoodBadTrials = 0.05; 

% Determine which plots to use by changing to true
%Plot average spectrogram (time-frequency analysis) for all trials/runs
plot_spectrogram = true;
%Plot score change (CCA score and SSVEP score) over time (2 plots)
plot_score_change = false;
%Plot histogram showing the distribution of the CCA scores
plot_cca_distribution = true;

[state_codes, allTrials] = getAllTrialsAlt(fileListing, filterCutoffs, samplingRate);

ISITrials = allTrials{1}; %Interstimulation intervals
stimulationTrials = allTrials{2}; %Trials with stimulus flashing


%% Frequency Analysis
windowLength = 2; %windowLength of short-time fourier transform analysis (FFT)
channels = [6,7,8]; %Create list of channels which will be used for CCA and frequency spectrum analysis
target_freq = 7.5; %Target frequency in Hz (stimulus flashing frequency)
FFTLength = windowLength*samplingRate; %The length of the performed FFT in stft analysis
n_overlap_perc = 0.9; %The percentage of the window that overlaps in stft analysis
n_overlap = floor(FFTLength*n_overlap_perc); %The number of overlapping samples in stft analysis
harmonics = 2; %The number of harmonics to use in the SSVEP score calculation



[ssvep_scores_stim, stft_ave_stim, ssvep_score_t_stim, t_stim, ...
    f_stim] = frequency_analysis(stimulationTrials, samplingRate, ...
    FFTLength, n_overlap, channels, target_freq, harmonics);

[ssvep_scores_isi, stft_ave_isi, ssvep_score_t_isi, t_isi, ...
    f_isi] = frequency_analysis(ISITrials, samplingRate, ...
    FFTLength, n_overlap, channels, target_freq, harmonics);

%Find best and worst trials according to SSVEP score
[best_i_harmonic, best_j_harmonic, worst_i_harmonic, ...
    worst_j_harmonic] = find_good_trials(ssvep_scores_stim, percGoodBadTrials);


if plot_spectrogram
    %Plot Spectrogram of STFT (with averaged data)
    figure;
    %Plot only frequencies less than 40Hz
    f_fplot = f_stim(f_stim < 40);
    stft_ave_plot = stft_ave_stim(f_stim < 40,:);
    contourf(f_fplot,t_stim,stft_ave_plot',5); 
    hold on;
    title("Average Spectrogram of EEG signal Over All Trials");
    xlabel("Frequency (Hz)");
    ylabel("Time (s)");
    hold off;
end

if plot_score_change 
    %Determine an SSVEP score using the first two harmonics
    figure;
    hold on;
    plot(t_stim,ssvep_score_t_stim);
    plot(t_isi,ssvep_score_t_isi);
    title("Change in SSVEP Score Over Time");
    xlabel("Time (s)");
    ylabel("SSVEP Score");
    legend('Flashing','ISI');
    hold off;
end


%% CCA Analysis

%Create the CCA variables for a given window length
pad_before_stimulation = 0.160; %The number of seconds of the stimulus time that are removed at the beginning
pad_before_ISI = 0.160; %The number of seconds of the inter-stimulus interval that are removed at the beginning
windowLengthCCA = 1; %windowLength time in seconds 
overlapCCA = 0.5; %Time of overlap in sliding window for CCA
harmonics = 6; %Number of harmonics used for CCA analysis
trial_time = 20; %Trial time used for CCA analysis
trial_time_ISI = floor(find_shortest_trial(ISITrials, samplingRate)); %Select the ISI trial time to correspond to the shortest ISI

[canon_corr_stimulation, canon_corr_stim_t_ave, t_stim_cca, canon_corr_stim_t_std] = CCAAnalysis(stimulationTrials, ...
    pad_before_stimulation, trial_time, samplingRate, windowLengthCCA, ...
    overlapCCA, channels, target_freq, harmonics);

[canon_corr_ISI, canon_corr_ISI_t_ave, t_ISI_cca, canon_corr_ISI_t_std] = CCAAnalysis(ISITrials, ...
    pad_before_ISI, trial_time_ISI, samplingRate, windowLengthCCA, overlapCCA, ...
    channels, target_freq, harmonics);

%Find best and worst trials according to CCA score
[best_i_cca, best_j_cca, ... 
    worst_i_cca, worst_j_cca] = find_good_trials(canon_corr_stimulation, percGoodBadTrials);

if plot_score_change
    figure;
    hold on;
    
    

    x = t_stim_cca;
    lo = canon_corr_stim_t_ave - canon_corr_stim_t_std;
    hi = canon_corr_stim_t_ave + canon_corr_stim_t_std;
    hp_stim = patch([x'; x(end:-1:1)'; x(1)'], [lo; hi(end:-1:1); lo(1)]', 'b');
    set(hp_stim, 'facecolor', [0.8 0.8 1], 'edgecolor', 'none');
    alpha(hp_stim,.5)
    plot(t_stim_cca, canon_corr_stim_t_ave,'b');

    x = t_ISI_cca;
    lo = canon_corr_ISI_t_ave - canon_corr_ISI_t_std;
    hi = canon_corr_ISI_t_ave + canon_corr_ISI_t_std;
    hp_ISI = patch([x'; x(end:-1:1)'; x(1)'], [lo; hi(end:-1:1); lo(1)]', '');
    set(hp_ISI, 'facecolor', [1 0.8 0.8], 'edgecolor', 'none');
    alpha(hp_ISI,.5)
    plot(t_ISI_cca, canon_corr_ISI_t_ave,'r');

    xlabel("Time (s)");
    ylabel("Maximum CCA Score");
    ylim([0,1]);
    title("CCA Score Change Over Time");
    legend('','Flashing','','ISI');
    hold off;
end

if plot_cca_distribution
    figure;
    subplot(2,1,1);
    histogram(canon_corr_stimulation);
    xlabel('CCA Score');
    ylabel('Frequency');
    title("CCA Coefficient Distribution When Stimulus is flashing");
    subplot(2,1,2);
    histogram(canon_corr_ISI);
    xlabel('CCA Score');
    ylabel('Frequency');
    title("CCA Coefficient Distribution During Interstimulus Interval");
end


