%Plotting FFT and Spectrogram of best and worst trials from particular
%subject

%Change directory to match where appropriate functions are saved
addpath('..\AnalysisFunctions\');
addpath(genpath('..\ssvep_musicbox\'));

fileListing = dir('..\MLS_Session2_7.5');
filterCutoffs = [5, 50];
samplingRate = 256;
percGoodBadTrials = 0.1;
channels = 1:8;
analysis_code = 2;
best_trials = true;
target_freq = 7.5;

 [~, ~, ...
  best_i, best_j, ...
  worst_i, worst_j] = segment_bestworst_trials(fileListing, filterCutoffs, ...
  samplingRate, percGoodBadTrials, channels, analysis_code, best_trials, target_freq);

[~, allTrials] = getAllTrialsAlt(fileListing, filterCutoffs, samplingRate);

data = allTrials{2};

fprintf("There are %d runs and %d trials\n", size(data,1), size(data,2));

if percGoodBadTrials ~= 1
    best_trials = [best_i, best_j];
    worst_trials = [worst_i, worst_j];

    for i=1:size(best_trials,1)
        create_trial_plots(data, samplingRate, best_trials(i,1), best_trials(i,2), channels);
    end

    for i=1:size(worst_trials,1)
        create_trial_plots(data, samplingRate, worst_trials(i,1), worst_trials(i,2), channels);
    end

else
    best_trials = [best_i, best_j];

    for i= size(best_trials,1)
        create_trial_plots(data, samplingRate, best_trials(i,1), best_trials(1,2), channels);
    end
end
