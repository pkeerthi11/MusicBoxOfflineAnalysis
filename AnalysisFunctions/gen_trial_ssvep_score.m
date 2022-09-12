%generates an overall SSVEP score for the length of the entire trial
%(rather than SSVEP scores generated in sliding windows)

%Inputs:
%trial: 2D array corresponding to data from each time-point/channel
%samplingRate: sampling rate (Hz)
%channels: which channels are averaged in analysis
%target_freq: frequency of flashing stimulus
%harmonics: number of harmonics summed for the score

%Outputs:
%trial_ssvep_score: overall SSVEP score for the trial

function trial_ssvep_score = gen_trial_ssvep_score(trial, samplingRate, ...
    channels, target_freq, harmonics)

%SSVEP score for trial
samplesCount = 2^(floor(log2(size(trial,1))));
spectrum_total = fft(trial, samplesCount, 1); 
spectrum_total = abs(average_channels(spectrum_total, channels)/samplesCount);
spectrum_total(2:end-1) = 2 * spectrum_total(2:end-1);
spectrum_total = spectrum_total(1:samplesCount/2+1);
frequency = samplingRate*(0:(samplesCount/2))/samplesCount; 

%Calculate the overall SSVEP score for the FFT performed over the
%entire trial
trial_ssvep_score = calc_ssvep_score(spectrum_total ,target_freq, frequency, harmonics);


