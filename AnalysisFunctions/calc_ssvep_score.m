%generates a time-varying "SSVEP score" using the sum of harmonics from the magnitude
%spectrum

%Inputs:
%stft: 2D array - the output of the short-time Fourier transform (frequencies along 1st dimenion, time along 2nd dimension)
%target_freq: the frequency at which the ssvep_score (i.e. if stimulus flashing at 7.5 Hz, check score at target_freq = 7.5
%frequency: a vector corresponding to all the frequencies in the stft
%harmonics: the number of harmonics that are summed 

%Outputs:
%ssvep_score: the ssvep score evaluated as a function of time

function ssvep_score = calc_ssvep_score(stft, target_freq, frequency, harmonics)

%To include more frequencies nearby to target_freq in sum, increase range
range = 0.1;

harmonic_mag = [];
for i=1:harmonics
    %Find indices of frequencies in range of harmonics and sum them up
    idx = frequency >= (i*target_freq - range) & frequency <= (i*target_freq + range);
    if sum(idx) == 1
        harmonic_mag(i,:)= stft(idx,:);
    else 
        harmonic_mag(i,:)= sum(stft(idx,:));
    end
end

%Normalizes ssvep_score to overall power (the sum of all frequency bins)
ssvep_score = sum(harmonic_mag,1)./sum(stft,1);

end