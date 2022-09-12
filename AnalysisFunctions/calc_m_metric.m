%Function calculates the m-metrics for a series of thresholds for a given
%vector of scores

%Inputs: scores_t - a list of score values over time
%Inputs: states_stimulus - a list of states (stimulus on or off) over time

%Outputs: M_metrics - calculated M_metrics for each threshold in list
%Outputs: max_M - the maximum M_metric for the list of threholsds
%Outputs: thresholds - the thresholds at which the M_metric was calculated

function [M_metrics, thresholds, max_M, max_thresh, ...
    M_comthresh, M_indvthresh] = calc_m_metric(scores_t, states_stimulus)

%Resize so that states_stimulus vector is the same size as the scores
%vector
[actual_on, scores_t, scores_t_cell, actual_on_cell] = resize_actual_on(scores_t, states_stimulus);

%Determine list of thresholds
thresholds = linspace(min(scores_t), max(scores_t), 100);

M_metrics = zeros(size(thresholds));


for i=1:numel(thresholds)
    classify_on = scores_t >= thresholds(i);
    
     %Note due to shape of states_stimulus vector it must be transposed for
     %actual_on to match shape of classify_on
    M = calc_M(classify_on, actual_on);

    M_metrics(i) = M;


end

[max_M, max_idx] = max(M_metrics);
max_thresh = thresholds(max_idx);

%%% In this section we calculate the overall threshold that results in the
%%% best averaged M-metric among all trials 
trial_M_metrics = zeros(numel(scores_t_cell),numel(thresholds,1));

if ~isempty(scores_t_cell)
    for i=1:numel(thresholds)
        threshold = thresholds(i);
        for trial=1:numel(scores_t_cell)
            trial_scores = scores_t_cell{trial};
            trial_actual_on = actual_on_cell{trial};
            classify_on = trial_scores >= threshold;
            M = calc_M(classify_on, trial_actual_on); 
            trial_M_metrics(trial,i) = M;
        end        
    end
end

mean_M_alltrial= mean(trial_M_metrics);
[M_comthresh.mean_max_M , max_idx] = max(mean_M_alltrial);
M_comthresh.max_M = trial_M_metrics(:,max_idx);
M_comthresh.max_thresh = thresholds(max_idx);
M_comthresh.sd_max_M = std(M_comthresh.max_M,0,1);
M_comthresh.sem_max_M = M_comthresh.sd_max_M/numel(M_comthresh.max_M);


%%% In this section we calculate the individual thresholds that results in the
%%% best individual M-metric for each trials 
max_M_metrics = zeros(numel(scores_t_cell),numel(thresholds,1));
trial_M_metrics = zeros(numel(scores_t_cell),numel(thresholds,1));

M_indvthresh.max_M = zeros(numel(scores_t_cell),1);
M_indvthresh.max_thresh = zeros(numel(scores_t_cell),1);

if ~isempty(scores_t_cell)
    for trial=1:numel(scores_t_cell)
        trial_scores = scores_t_cell{trial};
        trial_actual_on = actual_on_cell{trial};
        thresholds = linspace(min(trial_scores), max(trial_scores), 100);

        for i=1:numel(thresholds)
            threshold = thresholds(i);
            classify_on = trial_scores >= threshold;
            M = calc_M(classify_on, trial_actual_on); 
            trial_M_metrics(trial,i) = M;            
        end

        [M_indvthresh.max_M(trial), max_idx] = max(trial_M_metrics(trial,:));
        M_indvthresh.max_thresh(trial) = thresholds(max_idx);            
    end    
    
end

M_indvthresh.mean_max_M  = mean(M_indvthresh.max_M);
M_indvthresh.sd_max_M  = std(M_indvthresh.max_M);
M_indvthresh.sem_max_M  = M_indvthresh.sd_max_M/numel(M_indvthresh.max_M);



end

