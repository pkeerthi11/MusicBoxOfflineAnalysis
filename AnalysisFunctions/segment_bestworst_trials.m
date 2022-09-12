%generate 
%analysis_code = 1, frequency analysis (sum of harmonics) 
%analysis_code = 2, CCA analysis

%best_trials: boolean, that if true, returns segments of the best trials
%(surrounding by according ISIs), if false returns segments of worst trials
%(surrounding by according ISIs)

%Outputs
%segments: cell-array of the data from best or worst segments (flanked by ISI) based upon input
%argument best_trials 
%segment_states: cell-array of whether the stimulus is on or off
%corresponding to data from segments

function [segments, segment_states, best_i, best_j, worst_i, worst_j] = ...
    segment_bestworst_trials(fileListing, filterCutoffs, samplingRate, ...
    percGoodBadTrials, channels, analysis_code, best_trials, target_freq, trialselectionmethod)

if ~exist('trialselectionmethod')
    trialselectionmethod = 0;
end

[~, allTrials] = getAllTrialsAlt(fileListing, filterCutoffs, samplingRate);

ISITrials = allTrials{1}; %Interstimulation intervals
stimulationTrials = allTrials{2}; %Trials with stimulus flashing

if analysis_code == 1

    %% Frequency Analysis
    windowLength = 2; %windowLength of short-time fourier transform analysis (FFT)
    %target_freq = 7.5; %Target frequency in Hz (stimulus flashing frequency)
    FFTLength = windowLength*samplingRate; %The length of the performed FFT in stft analysis
    n_overlap_perc = 0.9; %The percentage of the window that overlaps in stft analysis
    n_overlap = floor(FFTLength*n_overlap_perc); %The number of overlapping samples in stft analysis
    harmonics = 2; %The number of harmonics to use in the SSVEP score calculation
    
    ssvep_scores_stim = frequency_analysis(stimulationTrials, samplingRate, ...
        FFTLength, n_overlap, channels, target_freq, harmonics);

    %Find best and worst trials according to SSVEP score
    [best_i, best_j, worst_i, worst_j] = find_good_trials(ssvep_scores_stim, percGoodBadTrials);  

elseif analysis_code == 2

    %% CCA Analysis
    
    %Create the CCA variables for a given window length
    pad_before_stimulation = 0.160; %The number of seconds of the stimulus time that are removed at the beginning
    pad_before_ISI = 0.160; %The number of seconds of the inter-stimulus interval that are removed at the beginning
    %target_freq = 7.5; %Target frequency in Hz (stimulus flashing frequency)
    windowLengthCCA = 1; %windowLength time in seconds 
    overlapCCA = 0.5; %Time of overlap in sliding window for CCA
    harmonics = 6; %Number of harmonics used for CCA analysis
    trial_time = 20; %Trial time used for CCA analysis
    trial_time_ISI = floor(find_shortest_trial(ISITrials, samplingRate)); %Select the ISI trial time to correspond to the shortest ISI
    
    [canon_corr_stimulation, canon_corr_stim_t_ave, t, canon_corr_t_std, canon_corr_stim_t] = CCAAnalysis(stimulationTrials, ...
        pad_before_stimulation, trial_time, samplingRate, windowLengthCCA, ...
        overlapCCA, channels, target_freq, harmonics);

    [canon_corr_ISI, canon_corr_ISI_t_ave, t_ISI, canon_corr_ISI_t_std, canon_corr_ISI_t] = CCAAnalysis(ISITrials, ...
        pad_before_ISI, trial_time_ISI, samplingRate, windowLengthCCA, overlapCCA, ...
        channels, target_freq, harmonics);

    if trialselectionmethod == 0
        %Find best and worst trials according to significance of difference in CCA score
        %i represents file (run), j represents trial within file 
        
        p_vals = ttest_canon_corr(canon_corr_stim_t, canon_corr_ISI_t);
        [best_i, best_j, worst_i, worst_j] = find_good_trials((1-p_vals), percGoodBadTrials);
    else
        %Find best and worst trials according to significance of magnitude of trial max CCA score
        [best_i, best_j, worst_i, worst_j] = find_good_trials(canon_corr_stimulation, percGoodBadTrials);
        
    end

end

%%Modify DO NOT AVERAGE CHANNELS

segments = {};
segment_states = {};

if best_trials
    
    for n=1:numel(best_i)
        trial = squeeze(stimulationTrials(best_i(n),best_j(n),:,:));
        trial_state = true(size(trial,1),1);
        
        if (best_j(n) <= 1)
            before_ISI = [];
            before_ISI_state = [];
        else
            before_ISI = squeeze(ISITrials(best_i(n),best_j(n)-1,:,:));
            before_ISI_state = false(size(before_ISI,1),1);
        end
        
        if (best_j(n) >= size(ISITrials,2))
            after_ISI = [];
            after_ISI_state = [];
        else
            after_ISI = squeeze(ISITrials(best_i(n),best_j(n)+1,:,:));
            after_ISI_state = false(size(after_ISI,1),1);
        end
    
        segments{n} = [before_ISI; trial; after_ISI];
        segment_states{n} = [before_ISI_state; trial_state; after_ISI_state];
    
    end

else

    
    for n=1:numel(worst_i)
        trial = squeeze(stimulationTrials(worst_i(n),worst_j(n),:,:));
        trial_state = true(size(trial,1),1);
        
        if (worst_j(n) <= 1)
            before_ISI = [];
            before_ISI_state = [];
        else
            before_ISI = squeeze(ISITrials(worst_i(n),worst_j(n)-1,:,:));
            before_ISI_state = false(size(before_ISI,1),1);
        end
        
        if (worst_j(n) >= size(ISITrials,2))
            after_ISI = [];
            after_ISI_state = [];
        else
            after_ISI = squeeze(ISITrials(worst_i(n),worst_j(n)+1,:,:));
            after_ISI_state = false(size(after_ISI,1),1);
        end
    
        segments{n} = [before_ISI; trial; after_ISI];
        segment_states{n} = [before_ISI_state; trial_state; after_ISI_state];
    
    end

    
end


    
    
    
    