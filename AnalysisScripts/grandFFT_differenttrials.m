%https://ieeexplore.ieee.org/abstract/document/8610084
%https://link.springer.com/chapter/10.1007/978-3-642-25489-5_14
%https://link.springer.com/chapter/10.1007/978-3-319-66905-2_1

clear all; close all; clc; 

%Change directory to match where appropriate functions are saved
addpath('..\AnalysisFunctions\');
addpath(genpath('..\ssvep_musicbox\'));

fileListings{1} = dir('..\ssvep_musicbox\ssvep_musicbox\Data\Prelim Data\S150\3-27-19\Raw_Data');
fileListings{2} = dir('..\ssvep_musicbox\ssvep_musicbox\Data\Prelim Data\S200\3-19-19\Raw_Data');
fileListings{3} = dir('..\ssvep_musicbox\ssvep_musicbox\Data\Prelim Data\S250\2-19-19\raw data');
fileListings{4} = dir('..\ssvep_musicbox\ssvep_musicbox\Data\Prelim Data\S300\4-29-19\Raw Data');

%Required values for trial extraction
filterCutoffs = [5, 50]; %Upper and lower frequency bins for cutoff
samplingRate = 256; %Sampling rate (Hz)

%For both methods, decide percent of good and bad trials to select
percGoodBadTrials = 0.05; 

% Determine which plots to use
plot_spectrogram = true;
plot_score_change = true;
plot_cca_distribution = true;

[state_codes, allTrials] = getAllTrialsAlt(fileListings{1}, filterCutoffs, samplingRate);


%% Frequency Analysis
windowLength = 2; %windowLength of short-time fourier transform analysis (FFT)
channels = [6,7,8]; %Create list of channels which will be used for CCA and frequency spectrum analysis
target_freq = 7.5; %Target frequency in Hz (stimulus flashing frequency)
FFTLength = windowLength*samplingRate; %The length of the performed FFT in stft analysis
n_overlap_perc = 0.9; %The percentage of the window that overlaps in stft analysis
n_overlap = floor(FFTLength*n_overlap_perc); %The number of overlapping samples in stft analysis
harmonics = 2; %The number of harmonics to use in the SSVEP score calculation

%Adjust ISITrials to remove first ISI before 1st trial begins and after
%last trial ends
ISITrials = allTrials{1};
ISITrials = ISITrials(:,2:end-1,:,:);

stimulationTrials = allTrials{2};

[ssvep_scores_stim, stft_ave_stim, ssvep_score_t_stim, t_stim, ...
    f_stim] = frequency_analysis(stimulationTrials, samplingRate, ...
    FFTLength, n_overlap, channels, target_freq, harmonics);

[ssvep_scores_isi, stft_ave_isi, ssvep_score_t_isi, t_isi, ...
    f_isi] = frequency_analysis(ISITrials, samplingRate, ...
    FFTLength, n_overlap, channels, target_freq, harmonics);

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
pad_before_stimulation = 0.160;
pad_before_ISI = 0.160;
windowLengthCCA = 1; %windowLength time in seconds 
overlapCCA = 0.5; %Time of overlap in sliding window for CCA
harmonics = 6; %Number of harmonics used for CCA analysis
trial_time = 20; %Trial time used for CCA analysis
trial_time_ISI = find_shortest_trial(ISITrials, samplingRate);

[canon_corr_stimulation, canon_corr_stim_t_ave, t] = CCAAnalysis(stimulationTrials, ...
    pad_before_stimulation, trial_time, samplingRate, windowLengthCCA, ...
    overlapCCA, channels, target_freq, harmonics);

[canon_corr_ISI, canon_corr_ISI_t_ave, t_ISI] = CCAAnalysis(ISITrials, ...
    pad_before_ISI, trial_time_ISI, samplingRate, windowLengthCCA, overlapCCA, ...
    channels, target_freq, harmonics);

[best_i_cca, best_j_cca, ... 
    worst_i_cca, worst_j_cca] = find_good_trials(canon_corr_stimulation, percGoodBadTrials);

if plot_score_change
    figure;
    hold on;
    plot(t, canon_corr_stim_t_ave);
    plot(t_ISI, canon_corr_ISI_t_ave);
    xlabel("Time (s)");
    ylabel("Maximum CCA Score");
    ylim([0,1]);
    title("CCA Score Change Over Time");
    hold off;
end

if plot_cca_distribution
    figure;
    histogram(canon_corr_stimulation);
    xlabel('CCA Score');
    ylabel('Frequency');
    title("CCA Coefficient Distribution");
end


