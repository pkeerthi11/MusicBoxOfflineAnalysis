%determines accuracy using the true positives and true negatives

%Inputs:
%t: time values at which scores are evaluated (used for plotting
%scores_t: the scores at each time value (same length as t)
%states_stimulus: state codes corresponding to when stimulus is on or off
%plot_scores: boolean that is true if plots of scores over time should be generated
%plot_ROC: boolean that is true if plots of ROC should be generated
%tstr: title used for plots

%Outputs:
%max_thresh: score threshold corresponding to maximum accuracy
%accuracy_rates: accuracy rates generated for each threshold
%TP_rates: true positive rates generated for each threshold
%TN_rates: true negative rates generated for each threshold
%thresholds: vector of thresholds for which accuracy was calculated

function [max_thresh, accuracy_rates, TP_rates, TN_rates, thresholds, AUC] = calc_accuracy(t, scores_t, states_stimulus, ...
    threshold_override, plot_scores, plot_ROC, plot_PRC, tstr)

[actual_on, scores_t, all_scores, actual_on_cell] = resize_actual_on(scores_t, states_stimulus);

thresholds = linspace(min(scores_t), max(scores_t), 100);

accuracy_rates = zeros(size(thresholds));
TP_rates = zeros(size(thresholds));
TN_rates = zeros(size(thresholds));
PPVs = zeros(size(thresholds));

for i=1:numel(thresholds)
    threshold = thresholds(i);

    classify_on = scores_t >= threshold;

    if(all(size(classify_on) ~= size(actual_on)))
        actual_on = actual_on';
    end

    %True positives (when both classified and actual are 1)
    TP = sum(classify_on & actual_on);

    %True negatives (when both classified and actual are 0)
    TN = sum((~classify_on) & (~actual_on));

    %False positves (when classified as 1 and actually 0)
    FP = sum(classify_on & ~actual_on);

    %False negatives (classifed as 0 and actually 1)
    FN = sum((~classify_on) & actual_on);

    TP_rates(i) = TP/(TP+FN); %Sensitivity (recall)
    TN_rates(i) = TN/(TN+FP); %Specificity
    PPVs(i) = TP / (TP + FP);

    accuracy_rates(i) = (TP_rates(i) + TN_rates(i))/2;%(TP+TN)/(TP+TN+FN+FP);

end

[max_accuracy, max_index] = max(accuracy_rates);
max_thresh = thresholds(max_index);

AUC.ROC_indvtrial = [];
AUC.PRC_indvtrial = [];


for trial=1:numel(all_scores)
    trial_scores = all_scores{trial};
    actual_on = actual_on_cell{trial};

    if(all(size(trial_scores) ~= size(actual_on)))
        actual_on = actual_on';
    end

    trial_thresholds = linspace(min(trial_scores), max(trial_scores), 100);

    for i=1:numel(thresholds)
        threshold = trial_thresholds(i);
        classify_on = trial_scores >= threshold;
        %True positives (when both classified and actual are 1)
        TP = sum(classify_on & actual_on);
        %True negatives (when both classified and actual are 0)
        TN = sum((~classify_on) & (~actual_on));
        %False positves (when classified as 1 and actually 0)
        FP = sum(classify_on & ~actual_on);    
        %False negatives (classifed as 0 and actually 1)
        FN = sum((~classify_on) & actual_on);
        
        TP_rates_indv(i) = TP/(TP+FN); %Sensitivity (recall)
        TN_rates_indv(i) = TN/(TN+FP); %Specificity
        PPVs_indv(i) = TP / (TP + FP); %Positive predictive value
    end

    FP_rates_indv = 1 - TN_rates; %1 - specificity

    AUC.ROC_indvtrial(end+1) = trapz(flip(FP_rates_indv),flip(TP_rates_indv));
    AUC.PRC_indvtrial(end+1) = trapz(flip(TP_rates_indv),flip(PPVs_indv));

end



if plot_scores
    figure;
    hold on;
    if iscell(t)
        legend_entries = cell(numel(t),1);

        %Some trials do not include ISI before and after so have to reshift
        %times on plots
        allLengths = cellfun(@numel, all_scores, 'UniformOutput', false);
        allLengths = [allLengths{:}]; 

        %Find the trials that include ISI before and after (maximum length)
        [trial_length, max_idx] = max(allLengths);
        full_trial_actual_on  = actual_on_cell{max_idx};
        %Find the index at which the stimulus first starts flashing
        first_on_idx = find(full_trial_actual_on,1);
        
        for i=1:numel(t)
            if length(all_scores{i}) < trial_length
                if actual_on_cell{i}(1) == 1
                    %Reshift time if the before ISI is not included in the
                    %trial
                    time_vals = t{i} + first_on_idx/(t{i}(1));
                else
                    time_vals = t{i};
                end
            else
                time_vals = t{i};
            end
 
            plot(time_vals, all_scores{i});

            legend_entries{i} = sprintf("Trial %d", i);
        end

        %If there are a small number of trials include the actual_on
        % Can't remember why I only included this for a small number of
        % trials tbh
        if(numel(t) < 10)
            actual_on_onetrial = actual_on_cell{max_idx};
            actual_on_onetrial_t = t{max_idx};
            
            %actual_on_onetrial = actual_on(1:numel(t{1}));

            yyaxis right;
            plot(actual_on_onetrial_t, actual_on_onetrial, 'k', 'LineWidth',2); 
            y_values = [0, 1];
            y_labels ={'Not Flashing', 'Flashing'};
            set(gca, 'Ytick',y_values,'YTickLabel',y_labels);
            set(gca,'YColor','k')
            ylabel('Stimulus')            
            yyaxis left;
        end

        legend(legend_entries);
    else 
        scores_t_accurate_on = scores_t((scores_t >= max_thresh) == actual_on' & (scores_t >= max_thresh));
        scores_t_accurate_off = scores_t((scores_t >= max_thresh) == actual_on' & (scores_t < max_thresh));
        t_accurate_on = t((scores_t >= max_thresh) == actual_on' & (scores_t >= max_thresh));
        t_accurate_off = t((scores_t >= max_thresh) == actual_on' & (scores_t < max_thresh));

        scores_t_inaccurate_on = scores_t((scores_t >= max_thresh) ~= actual_on' & (scores_t >= max_thresh));
        t_inaccurate_on = t((scores_t >= max_thresh) ~= actual_on' & (scores_t >= max_thresh));

        scores_t_inaccurate_off = scores_t((scores_t >= max_thresh) ~= actual_on' & (scores_t < max_thresh));
        t_inaccurate_off = t((scores_t >= max_thresh) ~= actual_on' & (scores_t < max_thresh));

        scatter(t_accurate_on, scores_t_accurate_on, 'go');
        scatter(t_inaccurate_on, scores_t_inaccurate_on, 'ro');
        scatter(t_accurate_off, scores_t_accurate_off, 'gx');
        scatter(t_inaccurate_off, scores_t_inaccurate_off, 'rx');
        yyaxis right;
        plot(t, actual_on,'b'); ylabel('Trial On/Off');
        yyaxis left;
    end
    
%     if threshold_override == 0
%         yline(max_thresh,'k--','DisplayName','Threshold');
%     else
%         yline(threshold_override,'k--','DisplayName','Threshold');
%     end
    hold off;
    xlabel('Time (s)'); ylabel('MCC Score'); %title("MCC Score Over Time");
end

FP_rates = 1-TN_rates; %Specificity
AUC.ROC = trapz(flip(FP_rates),flip(TP_rates));
AUC.PRC = trapz(flip(TP_rates),flip(PPVs));


if plot_ROC
    figure;  
    plot(FP_rates, TP_rates);
    xlim([0,1]); ylim([0,1]);
    xlabel('False Positive Rate (1-Specificity)'); ylabel('TP Rate (Sensitivity)');
    title(sprintf("Receiver Operating Characteristic Curve using %s Score", tstr));
end

if plot_PRC
    figure;
    plot(TP_rates, PPVs);
    xlabel('Recall'); ylabel('Precision');
    xlim([0,1]); ylim([0,1]);
    title(sprintf("Precision Recall Curve using %s Score", tstr));

end