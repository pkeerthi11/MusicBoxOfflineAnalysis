
%Inputs:
%trial - trial data
%cutoffs - define upper and lower bounds of set of frequency bins
%channels - optional entry for which channels should be averaged - if not
%included, average all channels

%Outputs
%vector of relative powers for all pairs of cutoffs given

function relative_powers = calc_power(trial, cutoffs, samplingRate, channels)

if size(cutoffs,1) == 2
    dim = 2;
elseif size(cutoffs,2) == 2
    dim = 1;
else
    fprintf("Invalid input for cutoffs")
    relative_powers = [];
end

if ~exist('channels', "var")
    channels = 1:8;
end

%Index data at appropriate run/trial
td_ave = average_channels(trial, channels);

%Perform FFT
samplesCount = 4096;

spectrum = fft(td_ave, samplesCount); 
spectrum = abs(spectrum/samplesCount);
spectrum(2:end-1) = 2 * spectrum(2:end-1);
spectrum = spectrum(1:samplesCount/2+1);
frequency = samplingRate*(0:(samplesCount/2))/samplesCount; 

relative_powers = zeros(1, size(cutoffs, dim));

for idx = 1:size(cutoffs, dim)
    if dim == 1
        low_cutoff = cutoffs(idx,1);
        high_cutoff = cutoffs(idx,2);
    elseif dim == 2
        low_cutoff = cutoffs(1, idx);
        high_cutoff = cutoffs(2, idx);
    end

    spectrum_idx = (frequency > low_cutoff & frequency < high_cutoff);
    bandpower = trapz(spectrum(spectrum_idx));
    totalpower = trapz(spectrum);

    relative_powers(idx) = bandpower/totalpower;
end


end