%Returns a matrix of the ssvep_score generated in each run and trial for
%the length of the trial, the short-time fourier transform averaged along
%all runs and trials, and the average ssvep score changes over time

%This function assumes the signal has been segmented into different runs
%and should not be used for simulating the offline analysis

%Inputs:
%allTrials: a 4D array storing 1) all files 2)all runs 3) all channels
%4)time points
%samplingRate: sampling rate of signal
%FFTLength: the window length of the performed short-time fourier transform (FT)
%n_overlap: the number of overlapping samples between each FT
%channels: vector storing the channels that are kept during averaging
%harmonics: the number of harmonics summed together when calculating the


%Outputs:
%ssvep_scores: the overall ssvep score from the entire trial/run
%stft_ave: the short-time FT averaged among all trials/runs and selected
%channels
%ssvep_score_t: the average ssvep score at each time point (averaged
%between all trials and runs
%t: the times at which ssvep_score_t was evaluated (same length as
%ssvep_score_t)
%f: the frequencies at which the FT is calculated


function [ssvep_scores, stft_ave, ssvep_score_t, t, f] = frequency_analysis(allTrials, ...
    samplingRate, FFTLength, n_overlap, channels, target_freq, harmonics)

ssvep_scores = zeros(size(allTrials,1:2));
stft_arr = [];
%Perform stft for all trials/runs and and store output to 4D array
for i=1:size(allTrials,1)
    for j=1:size(allTrials,2)
      trial = squeeze(allTrials(i,j,:,:));
         
      %Note that harmonic peaks are not as clear when window is shortened
      [stft_out, f, t] = stft(trial,samplingRate,'Window',hamming(FFTLength), ...
          'OverlapLength', n_overlap,'FFTLength',FFTLength,'FrequencyRange','onesided');
      mag_out = abs(average_channels(stft_out, channels)/FFTLength);

      %Calculate the overall SSVEP score for the FFT performed over the
      %entire trial
      ssvep_scores(i,j) = gen_trial_ssvep_score(trial, samplingRate, ...
          channels, target_freq, harmonics);

      stft_arr(i,j,:,:) = mag_out; 
    end
end
%Take average of all runs and trials
stft_ave = squeeze(mean(stft_arr, [1, 2]).^2);

ssvep_score_t = calc_ssvep_score(stft_ave, target_freq, f, harmonics);