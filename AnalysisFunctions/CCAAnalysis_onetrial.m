function [r_t, t, canon_corr] = CCAAnalysis_onetrial(trial, pad_before, trial_time, samplingRate, ...
    windowLength, overlapTime, channels, target_freq, harmonics)

pad_before_samples = ceil(pad_before*samplingRate);
trial_time_samples = ceil(trial_time*samplingRate);


%Create ccaVars according to length of CCA analysis performed
ccaVar_stimulation_seg = createCCAVars(windowLength*samplingRate,target_freq,harmonics,samplingRate)';
ccaVar_stimulation = createCCAVars(trial_time*samplingRate,target_freq,harmonics,samplingRate)';

sampleSelect = (pad_before_samples:(pad_before_samples+trial_time_samples) - 1);
trial = trial(sampleSelect,:);

[segments, t] = generate_segments(trial, windowLength, samplingRate, overlapTime);

%r_t stores changes in r over time for particular trial      
r_t = zeros(1,size(segments,1)); 

for k=1:size(segments,1)   
  %Extract segment and store canon_corr value
  seg = squeeze(segments(k,:,:)); 
  if all(all(~seg))
      r_t(k) = 0;
  else
    r_t(k) = max(canoncorr_reduced(seg(:,channels),ccaVar_stimulation_seg));
  end
end

%Find overall CCA score for 20 second mid-interval
r = canoncorr_reduced(trial, ccaVar_stimulation);
r = max(r);
canon_corr = r;