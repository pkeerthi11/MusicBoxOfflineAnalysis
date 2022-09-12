%Generates 2 trial plots given the data and the selected indices

%Inputs:
%data: multidimensional data storing all trials/runs/channels
%samplingRate: sampling rate (Hz)
%trial_idx: the index corresponding to the trial 
%run_idx: the index corresponding to the run
%channels: the channels selected for analysis

%no outputs


function create_trial_plots(data, samplingRate, run_idx, trial_idx, channels)

%Index data at appropriate run/trial
trial = squeeze(data(run_idx, trial_idx,:,:));
td_ave = average_channels(trial, channels);

%Perform FFT
samplesCount = 4096;

spectrum = fft(td_ave, samplesCount); 
spectrum = abs(spectrum/samplesCount);
spectrum(2:end-1) = 2 * spectrum(2:end-1);
spectrum = spectrum(1:samplesCount/2+1);
frequency = samplingRate*(0:(samplesCount/2))/samplesCount; 


%Plot FFT
figure;
hold on;
plot(frequency, spectrum, linewidth=2);
xlabel("Frequency (Hz)");
ylabel("Magnitude");
hold off;
grid on
%    xline(7.5*[1, 2, 3, 4, 5], linewidth=4, linestyle=':', color='r');
xlim([0, 40]);
set(gca, 'FontSize', 16);

ttl = sprintf("Spectrum: Trial #%d, Run #%d", trial_idx, run_idx);
title(ttl);

%Plot Spectrogram
windowLength =2;
FFTLength = windowLength*samplingRate;
n_overlap_perc = 0.9;
n_overlap = floor(FFTLength*n_overlap_perc);

[stft_out, f, t] = stft(td_ave,samplingRate,'Window',hamming(FFTLength),'OverlapLength', ...
          n_overlap,'FFTLength',FFTLength,'FrequencyRange','onesided');
stft_out = abs(stft_out/FFTLength);
stft_out = squeeze(stft_out.^2);

figure;
%Plot only frequencies less than 40Hz
f_fplot = f(f<40);
stft_out_plot = stft_out(f<40,:);
contourf(f_fplot,t,stft_out_plot',5); 
hold on;
ttl = sprintf("Spectrogram of EEG signal Over Selected Trial: #%d, Run #%d", trial_idx, run_idx);
title(ttl);
xlabel("Frequency (Hz)");
ylabel("Time (s)");
hold off;
