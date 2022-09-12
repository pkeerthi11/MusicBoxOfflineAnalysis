
clear all; close all; clc; 

%Change directory to match where appropriate functions are saved
addpath('..\AnalysisFunctions\');
addpath(genpath('..\ssvep_musicbox\'));

% Determine which plots to use
plot_spectrogram = true; %Will plot the average spectrogram from all subjects
plot_score_change = true; %Will plot both the SSVEP score and CCA score against time

%Remove 2 because SSVEP response not evident
fileListings{1} = dir('..\ssvep_musicbox\ssvep_musicbox\Data\Prelim Data\S150\3-27-19\Raw_Data');
fileListings{2} = dir('..\ssvep_musicbox\ssvep_musicbox\Data\Prelim Data\S200\3-19-19\Raw_Data');
fileListings{3} = dir('..\ssvep_musicbox\ssvep_musicbox\Data\Prelim Data\S250\2-19-19\raw data');
fileListings{4} = dir('..\ssvep_musicbox\ssvep_musicbox\Data\Prelim Data\S300\4-29-19\Raw Data');


%ALS
%fileListings{1} = dir('..\als_participantdata');

for i=1:numel(fileListings)
    %analyze_subject used to gather metrics from invidual subjects
    [stft_ave_stim, ssvep_score_t_stim, canon_corr_stim_t_ave, ...
    t_stim, f_stim, t_stim_cca, t_isi, ssvep_score_t_isi, ...
    t_ISI_cca, canon_corr_ISI_t_ave] = analyze_subject(fileListings{i});

    if ~exist('total_stft_stim', 'var')
        total_stft_stim = stft_ave_stim;
        total_ssvep_score_t_stim = ssvep_score_t_stim;
        total_canon_corr_stim_t_ave = canon_corr_stim_t_ave;
        total_ssvep_score_t_isi = ssvep_score_t_isi;
        total_canon_corr_ISI_t_ave = canon_corr_ISI_t_ave;
    else
        total_stft_stim = stft_ave_stim + total_stft_stim;
        total_ssvep_score_t_stim = ssvep_score_t_stim + total_ssvep_score_t_stim;
        total_canon_corr_stim_t_ave = canon_corr_stim_t_ave + total_canon_corr_stim_t_ave;
        total_ssvep_score_t_isi = cat(2, total_ssvep_score_t_isi,ssvep_score_t_isi);
        total_canon_corr_ISI_t_ave = total_canon_corr_ISI_t_ave + canon_corr_ISI_t_ave;
    end
end

total_stft_stim_ave = total_stft_stim/numel(fileListings);
total_ssvep_score_t_stim_ave = total_ssvep_score_t_stim/numel(fileListings);
total_canon_corr_stim_t_ave = total_canon_corr_stim_t_ave/numel(fileListings);
total_ssvep_score_t_isi_ave = mean(total_ssvep_score_t_isi);
total_canon_corr_ISI_t_ave = total_canon_corr_ISI_t_ave/numel(fileListings);


if plot_spectrogram
    %Plot Spectrogram of STFT (with averaged data)
    figure;
    %Plot only frequencies less than 40Hz
    f_fplot = f_stim(f_stim < 40);
    stft_ave_plot = total_stft_stim_ave(f_stim < 40,:);
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
    plot(t_stim,total_ssvep_score_t_stim_ave);
    %Due to inconsistent array sizes, use the average SSVEP score for the
    %ISI
    yline(total_ssvep_score_t_isi_ave, 'r--');
    title("Change in SSVEP Score Over Time");
    xlabel("Time (s)");
    ylabel("SSVEP Score");
    ylim([0 inf]);
    legend('Flashing', 'Interstimulus Interval'); %
    hold off;
end

if plot_score_change
    figure;
    hold on;
    plot(t_stim_cca, total_canon_corr_stim_t_ave);
    plot(t_ISI_cca, total_canon_corr_ISI_t_ave);
    xlabel("Time (s)");
    ylabel("Maximum CCA Score");
    ylim([0,1]);
    title("CCA Score Change Over Time");
    hold off;
end