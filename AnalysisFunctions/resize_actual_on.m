function [actual_on, scores_t, all_scores, actual_on_cell] = resize_actual_on(scores_t, states_stimulus)

%If segmenting into multiple trials can store actual on in cell-array that
%corresponds to sizes of individual trials in scores_t (will return empty
%cell-array if scores_t is not a cell array)
actual_on_cell  = {};

if iscell(scores_t)

    all_scores = scores_t;
    scores_t = [];
    actual_on = [];

    for i=1:numel(all_scores)
        scores_t_i = all_scores{i};
        states_stimulus_i = states_stimulus{i};

        %states.Stimulus is different length from ssvep_scores_t so some
        %adjustments must be made when comparing states
        total_samples = numel(states_stimulus_i);
        total_timepoints = numel(scores_t_i);
        
        %Center the first sample
        first_sample = (total_samples/total_timepoints)/2;
        %Space out samples according to number of timepoints
        between_samples = (total_samples/total_timepoints);
        %Last sample
        last_sample = (total_samples/total_timepoints)*total_timepoints;
        
        state_sample_select = round(first_sample:between_samples:last_sample);
        actual_on_i = states_stimulus_i(state_sample_select);
        scores_t = [scores_t, scores_t_i];

        if(size(actual_on_i,1)==1)
            actual_on = [actual_on, actual_on_i];
        else
            actual_on = [actual_on; actual_on_i];
        end

        actual_on_cell{i} = actual_on_i;
    end
    
else
    all_scores = {};
    max_score = min(scores_t);
    min_score = max(scores_t);

    %states.Stimulus is different length from ssvep_scores_t so some
    %adjustments must be made when comparing states
    total_samples = numel(states_stimulus);
    total_timepoints = numel(scores_t);
    
    %Center the first sample
    first_sample = (total_samples/total_timepoints)/2;
    %Space out samples according to number of timepoints
    between_samples = (total_samples/total_timepoints);
    %Last sample
    last_sample = (total_samples/total_timepoints)*total_timepoints;
    
    state_sample_select = round(first_sample:between_samples:last_sample);
    actual_on = states_stimulus(state_sample_select);
   

end