%which_trials = 1: use data from full run
%which_trials = 2: use only best trials, from pre-defined percentage
%which_trials =3: use only worst trials, from pre-defined percentage 


function [AUC_CCA, M_comthresh, M_indvthresh] = simulate_classification_offline(fileListing, which_trials, analysis_type_struct)

%analysis_code = 1: use ssvep_score (sum of harmonics) to classify best/worst trials
%analysis_code = 2: use CCA score to classify best/worst trials
if ~exist('analysis_type_struct',"var")
    smooth_span = 0;
    analysis_code = 2;
    percGoodBadTrials = 0.1;
    trialselectionmethod = 0;
else
    if isfield(analysis_type_struct,'smooth_span')
        smooth_span = analysis_type_struct.smooth_span;
    else
        smooth_span = 0;
    end

    if isfield(analysis_type_struct, 'analysis_code')
        analysis_code = analysis_type_struct.analysis_code;
    else
        analysis_code = 2;
    end

    if isfield(analysis_type_struct, 'percGoodBadTrials')
        percGoodBadTrials = analysis_type_struct.percGoodBadTrials;
    else
        percGoodBadTrials = 0.1;
    end

    if isfield(analysis_type_struct, 'trialselectionmethod')
        trialselectionmethod = analysis_type_struct.trialselectionmethod;
    else
        trialselectionmethod = 0;
    end

    if isfield(analysis_type_struct, 'flashing_frequency')
        
        target_freq = analysis_type_struct.flashing_frequency;
    else
        target_freq = 7.5; %The frequency of the flashing stimulus
    end 

    if isfield(analysis_type_struct, 'filter_cutoffs')
        filterCutoffs = analysis_type_struct.filter_cutoffs; %Lower and upper filter cutoffs in Hz
    else
        filterCutoffs = [5, 50]; %Lower and upper filter cutoffs in Hz
    end

    if isfield(analysis_type_struct, 'channels')
        channels = analysis_type_struct.channels;
    else
        %Fc, Cz, P3, Pz, P4, PO7, Po8, Oz
        channels = [1:8]; %Channels used when averaging
    end
    

end

%detected intervals where music correctly on/off without interuption
%begin describing results
%Function simulate trial

%Plots to Include:
plot_scores = true;
plot_ROC = false;
plot_PRC = false;
use_all_trials = true; %If which_trials = 1 and this is true, will use all trials

%Define Parameters
harmonics = 4; %The number of harmonics used for ssvep_score analysis
harmonicsCCA = 6; %Number of harmonics used for CCA score analysis
windowLength = 2; %window of analysis in seconds
overlap_ratio = 0.5; %what percentage of window overlaps with previous
overlapTime = windowLength*overlap_ratio;
samplingRate = 256; %sampling rate in Hz





if which_trials == 1
    [signal, states, samplingRate, filename] = extract_signal(fileListing, filterCutoffs, use_all_trials);
elseif which_trials == 2
    %create segment_best_worst_trials functions - include best as argument
    %output should have signal, states, samplingRate in cell array
    best_trials = true;
    [signal, states] = segment_bestworst_trials(fileListing, filterCutoffs, samplingRate, percGoodBadTrials, channels, analysis_code, best_trials, target_freq, trialselectionmethod);
elseif which_trials == 3
    %create segment_best_worst_trials functions
    %output should have signal, states, samplingRate in cell array
    best_trials = false;
    [signal, states] = segment_bestworst_trials(fileListing, filterCutoffs, samplingRate, percGoodBadTrials, channels, analysis_code, best_trials, target_freq, trialselectionmethod);
end

windowSamples = samplingRate*windowLength; %window of analysis in samples
overlap_samples = samplingRate*windowLength*overlap_ratio; %num samples that overlap
non_overlap_sample = samplingRate*windowLength*(1-overlap_ratio); %num samples that don't overlap

%Perform short-time fourier transform to get magnitude at various
%frequencies at various time points
if iscell(signal)

    ssvep_score_t = cell(numel(signal),1);
    r_t = cell(numel(signal),1);
    t_stft = cell(numel(signal),1);
    t_CCA = cell(numel(signal), 1);
    states_stimulus = cell(numel(signal), 1);

    for i=1:numel(signal)

        signal_i = signal{i};
        states_i = states{i};

        [stft_out, f, t_stft_i] = stft(signal_i,samplingRate,'Window',hamming(windowSamples), ...
        'OverlapLength', overlap_samples,'FFTLength',windowSamples,'FrequencyRange','onesided');
        stft_mag = abs(average_channels(stft_out, channels)/windowSamples);
        ssvep_score_t_i = calc_ssvep_score(stft_mag, target_freq, f, harmonics);
        
        %Perform CCA analysis and get accuracy scores
        ccaVar_stimulation_seg = createCCAVars(windowLength*samplingRate,target_freq,harmonicsCCA,samplingRate)';
        [segments, t_CCA_i] = generate_segments(signal_i, windowLength, samplingRate, overlapTime);
        
        %CCA scores over time
        r_t_i = zeros(1,size(t_CCA_i,1));
        for k=1:size(segments,1)   
            %Extract segment and store canon_corr value
            seg = squeeze(segments(k, :, :)); 
            if all(all(~seg))
                r_t_i(k) = 0;
            else
                r_t_i(k) = max(canoncorr_reduced(seg(:,channels),ccaVar_stimulation_seg));
            end
        end

        ssvep_score_t{i} = ssvep_score_t_i;

        if smooth_span ~= 0
            r_t{i} = smooth(r_t_i, smooth_span)'; %force vector to horizontal
        else
            r_t{i} = r_t_i;
        end

        t_stft{i} = t_stft_i;
        t_CCA{i} = t_CCA_i;
        states_stimulus{i} = states_i; %.Stimulus;

    end

else 

    [stft_out, f, t_stft] = stft(signal,samplingRate,'Window',hamming(windowSamples), ...
        'OverlapLength', overlap_samples,'FFTLength',windowSamples,'FrequencyRange','onesided');
    stft_mag = abs(average_channels(stft_out, channels)/windowSamples);
    ssvep_score_t = calc_ssvep_score(stft_mag, target_freq, f, harmonics);
    
    %Perform CCA analysis and get accuracy scores
    ccaVar_stimulation_seg = createCCAVars(windowLength*samplingRate,target_freq,harmonicsCCA,samplingRate)';
    [segments, t_CCA] = generate_segments(signal, windowLength, samplingRate, overlapTime);
    
    %CCA scores over time
    r_t = zeros(1,size(t_CCA,1));
    for k=1:size(segments,1)   
        %Extract segment and store canon_corr value
        seg = squeeze(segments(k, :, :)); 
        r_t(k) = max(canoncorr_reduced(seg(:,channels),ccaVar_stimulation_seg));
    end

    if smooth_span ~= 0
        r_t = smooth(r_t, smooth_span)';
    end

    states_stimulus = states.Stimulus;

end

%%Note - calc_accuracy fails for best/worst trials: look into this
% [M_ssvep, thresholds_SSVEP, max_M_ssvep, thresh_max_M_ssvep] = calc_m_metric(ssvep_score_t, states_stimulus);
% 
% [max_thresh_ssvep_score, accuracy_ssvep_score, ...
%     TP_ssvep_score, TN_ssvep_score, thresholds_SSVEP, AUC_ssvepscore] = calc_accuracy(t_stft, ssvep_score_t, ...
%     states_stimulus, thresh_max_M_ssvep, plot_scores, plot_ROC, plot_PRC, 'SSVEP');

[M_CCA, thresholds_CCA, max_M_CCA, thresh_max_M_CCA, ...
    M_comthresh, M_indvthresh] = calc_m_metric(r_t, states_stimulus);

[max_thresh_CCA, accuracy_CCA, ...
    TP_CCA, TN_CCA, thresholds_CCA, AUC_CCA] = calc_accuracy(t_CCA, r_t, states_stimulus, ...
    thresh_max_M_CCA, plot_scores, plot_ROC,plot_PRC, 'MCC');