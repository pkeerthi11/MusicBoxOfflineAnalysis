%Input the data from all runs and trials to calculate the overall canonical
%correlation in the entire trial and the change in the CCA over time

%Inputs
%allTrials: multidimensional array storing data from all
%trials/runs/channels
%pad_before: How much of the beginning of the trial to remove
%trial_time: how many seconds of the trial to include
%samplingRate (samples/s, Hz)
%windowLength: length of the moving window over which CCA is calculated
%overlapTime: amount of overlap (in seconds) between each moving window segment
%channels: which channels to use in the analysis
%target_freq: the frequency of the flashing stimulus
%harmonics: the amount of harmonics to use in CCA analysis

%Outputs
%canon_corr_stimulation: 2D array storing the overall CCA score from each trial and run
%canon_corr_t_ave: vector storing the CCA score over time averaged between all trials/runs
%t: the times at which the CCA score was evaluated for the sliding window analysis 


function [canon_corr_stimulation, canon_corr_t_ave, t, canon_corr_t_std, canon_corr_stim_t] = CCAAnalysis(allTrials, ...
    pad_before, trial_time, samplingRate, windowLength, overlapTime, channels, target_freq, ...
    harmonics)

%Convert to whole-number amount of samples
pad_before_samples = ceil(pad_before*samplingRate);
trial_time_samples = ceil(trial_time*samplingRate);

canon_corr_stimulation = zeros(size(allTrials,1:2));

%Create ccaVars according to length of CCA analysis performed
ccaVar_stimulation_seg = createCCAVars(windowLength*samplingRate,target_freq,harmonics,samplingRate)';
ccaVar_stimulation = createCCAVars(trial_time*samplingRate,target_freq,harmonics,samplingRate)';

%Perform CCA for all trials/runs and and store output to 4D array
for i=1:size(allTrials,1)
    for j=1:size(allTrials,2)
      
      %Extract pre-specified trial_time ranging from time = pad_before to
      %time = pad_before + trial_time 
      trial = squeeze(allTrials(i,j,:,:));
      sampleSelect = (pad_before_samples:(pad_before_samples+trial_time_samples) - 1);
      trial = trial(sampleSelect,:);

      %Segment trial into same length as window length
      %Must ensure windowLength divides evenly into total trial, otherwise
      %this line will throw an exception
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

      %Define canonical correlation vector across time (each interval is of
      %windowLength)
      if ~exist('canon_corr_stim_t','var')
          canon_corr_stim_t = zeros(size(allTrials,1), size(allTrials,2),size(segments,1));
      end
      %3D vector: separated into runs, trials, and time points
      canon_corr_stim_t(i,j,:) = r_t;
      
      %Find overall CCA score for 20 second mid-interval
      r = canoncorr_reduced(trial, ccaVar_stimulation);
      r = max(r);
      canon_corr_stimulation(i,j) = r;
    end
end

%Take average canonical correlation in each 2 sec interval across all
%trials/runs
canon_corr_t_ave = squeeze(mean(canon_corr_stim_t,[1,2]));
canon_corr_t_std = squeeze(std(canon_corr_stim_t,0,[1,2]));