%Index signal to create a multi-dimensional array of all trials
%corresponding to a particular state. Different states are stores in
%different cells of a cell-array (accounts for varying sizes)

%Inputs
%signal: the time-domain signal
%states: stores when each particular type of trial is run

%Outputs
%state_codes: A list of the codes related to each type of trial
%trials: a cell-array storing all the trials of a particular state in each cell

function [state_codes, trials] = extractTrialsAlt(signal, states)

%Allow variable number of states (types of stimulation)
state_codes = unique(states.Stimulus);

num_states = numel(state_codes);

%Each trial has varying length so store in cell array 
trials = cell(num_states,1);

%Collect all the trials in each state
for i=1:num_states
    temp = zeros(length(states.Stimulus), 1);
    temp(states.Stimulus == state_codes(i)) = 1;
    
    %Account for if the first index belongs to this state
    if temp(1) == 1
        first_idx_state = true;
    else
        first_idx_state = false;
    end

    %Account for if the first index belongs to this state
    if temp(length(states.Stimulus)) == 1
        last_idx_state = true;
    else
        last_idx_state = false;
    end

    %Keep track of when the state turns on and off (diff will produce 1 and
    %-1)
    temp = diff(temp);

    %If the last stimulus value is in this state, the last offset occurs at
    %the last index
    if last_idx_state
        temp = [temp; -1];
    else
        temp = [temp; 0];
    end

    %Determine onset indices
    onsets = find(temp == 1) + 1;

    %If the first stimulus value is in this state, the first onset occurs at
    %the first index
    if first_idx_state
        onsets = [1; onsets];
    end

    %Determine offset indices
    offsets = find(temp == -1);

    num_trials = length(onsets);

    if first_idx_state
        start_iterations = 2;
    else
        start_iterations = 1;
    end

    if last_idx_state
        end_iterations = num_trials - 1;
    else
        end_iterations = num_trials;
    end

    num_trials_true = (end_iterations - start_iterations) + 1;

    %Find the maximum length of a trial in this state (the array will store
    %the max value and zero-pad the excess values for shorter trials)
    max_trial_length = max(offsets(start_iterations:end_iterations)-onsets(start_iterations:end_iterations)) + 1;


    trials{i} = zeros(num_trials_true,max_trial_length, size(signal,2)); 



    %For each trial in this state, extract the signal values, zero-pad to
    %match sizes if necessary and include in the total trial array
    for j = start_iterations:end_iterations
        trial = signal(onsets(j):offsets(j), :);
                
        padsize = max_trial_length - size(trial,1);
        trial = padarray(trial,padsize*[1,0],"post");
    
        trials{i}(j - start_iterations + 1, :, :) = trial;
    end

end



