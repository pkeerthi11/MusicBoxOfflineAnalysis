%Simulate classification offline for all particiapnts
clear all; close all; clc

%Change directory to match where appropriate functions are saved
addpath('..\AnalysisFunctions\');
addpath(genpath('..\ssvep_musicbox\'));

%Health Partipcant data
fileListings{1} = dir('..\ssvep_musicbox\ssvep_musicbox\Data\Prelim Data\S150\3-27-19\Raw_Data');
fileListings{2} = dir('..\ssvep_musicbox\ssvep_musicbox\Data\Prelim Data\S200\3-19-19\Raw_Data');
fileListings{3} = dir('..\ssvep_musicbox\ssvep_musicbox\Data\Prelim Data\S250\2-19-19\raw data');
fileListings{4} = dir('..\ssvep_musicbox\ssvep_musicbox\Data\Prelim Data\S300\4-29-19\Raw Data');

%ALS data:
%fileListings_ALS{1} = dir('..\als_participantdata');
fileListings_ALS{1} = dir('..\NHL');
%fileListings_ALS{1} = dir('..\als_participantdata_afterbreak\day1');
%fileListings_ALS{1} = dir('..\als_participantdata_afterbreak\day2');

analysis_type_struct.smooth_span = 5;
analysis_type_struct.percGoodBadTrials = 0.05;
analysis_type_struct.trialselectionmethod = 1;

if analysis_type_struct.smooth_span ~= 0
    titstr_smooth = 'Smoothed MCC, ';
else
    titstr_smooth = 'Unsmoothed MCC, ';
end

if analysis_type_struct.trialselectionmethod == 0
    titstr_trialselection = ' p-value selection method, ';
else
    titstr_trialselection = ' max mCC selection method, ';
end

titstr_percenttrials = sprintf(' Top and Bottom %d%% of trials', analysis_type_struct.percGoodBadTrials*100);


max_M_indvthresh = cell(2,1);
max_M_comthresh = cell(2,1);
best_indvthresh = cell(4,2);
best_comthresh = zeros(4,2);

AUC_PRC = cell(2,1);
AUC_ROC = cell(2,1);

max_M_indvthresh_als = cell(2,1);
max_M_comthresh_als = cell(2,1);
AUC_PRC_als = cell(2,1);
AUC_ROC_als = cell(2,1);

best_indvthresh_als = cell(1,2);
best_comthresh_als = zeros(1,2);


max_M_indvthresh_bar = zeros(5,2);
max_M_comthresh_bar = zeros(5,2);
AUCPRC_bar = zeros(5,2);
AUCROC_bar = zeros(5,2);

max_M_indvthresh_sem = zeros(5,2);
max_M_comthresh_sem = zeros(5,2);
AUCPRC_sem = zeros(5,2);
AUCROC_sem = zeros(5,2);

max_M_indvthresh_sd = zeros(5,2);
max_M_comthresh_sd = zeros(5,2);
AUCPRC_sd = zeros(5,2);
AUCROC_sd = zeros(5,2);

max_M_indvthresh_errhigh = zeros(5,2);
max_M_comthresh_errhigh = zeros(5,2);
AUCPRC_errhigh = zeros(5,2);
AUCROC_errhigh = zeros(5,2);

max_M_indvthresh_errlow = zeros(5,2);
max_M_comthresh_errlow = zeros(5,2);
AUCPRC_errlow = zeros(5,2);
AUCROC_errlow = zeros(5,2);


%Iterate through best trials (2) and worst trials (3) and store AUCs and
%M-metrics from individual trials 
for which_trials = 2:3
    for i=1:numel(fileListings)
        [AUC_CCA, M_comthresh, ...
            M_indvthresh] = simulate_classification_offline(fileListings{i}, which_trials, analysis_type_struct);
        
        max_M_indvthresh{which_trials-1} = [max_M_indvthresh{which_trials-1}; M_indvthresh.max_M];
        max_M_comthresh{which_trials-1} = [max_M_comthresh{which_trials-1}; M_comthresh.max_M];

        best_comthresh(i, which_trials-1) = M_comthresh.max_thresh;
        best_indvthresh{i, which_trials-1} = M_indvthresh.max_thresh;

        AUC_PRC{which_trials-1}  = [AUC_PRC{which_trials-1}, AUC_CCA.PRC_indvtrial];
        AUC_ROC{which_trials-1}  = [AUC_ROC{which_trials-1}, AUC_CCA.ROC_indvtrial];

        max_M_indvthresh_bar(i, which_trials -1) = mean(M_indvthresh.max_M);
        max_M_comthresh_bar(i, which_trials -1) = mean(M_comthresh.max_M);
        AUCPRC_bar(i, which_trials -1) = mean(AUC_CCA.PRC_indvtrial);
        AUCROC_bar(i, which_trials -1) = mean(AUC_CCA.ROC_indvtrial);

        max_M_indvthresh_sem(i, which_trials -1) = std(M_indvthresh.max_M)/numel(M_indvthresh.max_M);
        max_M_comthresh_sem(i, which_trials -1) = std(M_comthresh.max_M)/numel(M_comthresh.max_M);
        AUCPRC_sem(i, which_trials -1) = std(AUC_CCA.PRC_indvtrial/numel(AUC_CCA.PRC_indvtrial));
        AUCROC_sem(i, which_trials -1) = std(AUC_CCA.ROC_indvtrial)/numel(AUC_CCA.ROC_indvtrial);

        max_M_indvthresh_sd(i, which_trials -1) = std(M_indvthresh.max_M);
        max_M_comthresh_sd(i, which_trials -1) = std(M_comthresh.max_M);
        AUCPRC_sd(i, which_trials -1) = std(AUC_CCA.PRC_indvtrial);
        AUCROC_sd(i, which_trials -1) = std(AUC_CCA.ROC_indvtrial);
    end

    for i=1:numel(fileListings_ALS)
        [AUC_CCA, M_comthresh, ...
            M_indvthresh] = simulate_classification_offline(fileListings_ALS{i}, which_trials, analysis_type_struct);

        max_M_indvthresh_als{which_trials-1} = [max_M_indvthresh_als{which_trials-1}; ...
            M_indvthresh.max_M];

        max_M_comthresh_als{which_trials-1} = [max_M_comthresh_als{which_trials-1}; ...
            M_comthresh.max_M];

        best_indvthresh_als{i, which_trials-1} = M_indvthresh.max_thresh;
        best_comthresh_als(i, which_trials-1) = M_comthresh.max_thresh;

        AUC_PRC_als{which_trials-1}  = [AUC_PRC_als{which_trials-1}, AUC_CCA.PRC_indvtrial];
        AUC_ROC_als{which_trials-1}  = [AUC_ROC_als{which_trials-1}, AUC_CCA.ROC_indvtrial];

        max_M_indvthresh_bar(i+4, which_trials -1) = mean(M_indvthresh.max_M);
        max_M_comthresh_bar(i+4, which_trials -1) = mean(M_comthresh.max_M);
        AUCPRC_bar(i+4, which_trials -1) = mean(AUC_CCA.PRC_indvtrial);
        AUCROC_bar(i+4, which_trials -1) = mean(AUC_CCA.ROC_indvtrial);

        max_M_indvthresh_sem(i+4, which_trials-1) = std(M_indvthresh.max_M)/numel(M_indvthresh.max_M);
        max_M_comthresh_sem(i+4, which_trials-1) = std(M_comthresh.max_M)/numel(M_comthresh.max_M);
        AUCPRC_sem(i+4, which_trials-1) = std(AUC_CCA.PRC_indvtrial/numel(AUC_CCA.PRC_indvtrial));
        AUCROC_sem(i+4, which_trials-1) = std(AUC_CCA.ROC_indvtrial)/numel(AUC_CCA.ROC_indvtrial);

        max_M_indvthresh_sd(i+4, which_trials-1) = std(M_indvthresh.max_M);
        max_M_comthresh_sd(i+4, which_trials-1) = std(M_comthresh.max_M);
        AUCPRC_sd(i+4, which_trials-1) = std(AUC_CCA.PRC_indvtrial);
        AUCROC_sd(i+4, which_trials-1) = std(AUC_CCA.ROC_indvtrial);

    end
end


%https://stackoverflow.com/questions/59256136/add-error-bars-to-grouped-bar-plot-in-matlab

X = categorical({'S1','S2','S3','S4','S5 (ALS)'});
figure;
subplot(2,1,1);
if analysis_type_struct.percGoodBadTrials == 1
    y = max_M_indvthresh_bar(:,1);
    err = max_M_indvthresh_sd(:,1);
else
    y = max_M_indvthresh_bar;
    err = max_M_indvthresh_sd; %max_M_indvthresh_sem;
end

b1 = bar(y, 'FaceColor','flat');
hold on;
for k = 1:size(y,2)
    % get x positions per group
    xpos = b1(k).XData + b1(k).XOffset;
    % draw errorbar
    er1 = errorbar(xpos, y(:,k), err(:,k), 'LineStyle', 'none', ... 
        'Color', 'k', 'LineWidth', 1);  
    er1.Color = [0 0 0];                            
    er1.LineStyle = 'none';  
end
xticklabels(X)

titlestr = strcat(titstr_smooth, "Maximum M Obtained Using Optimal Threshold Individual to Each Trial");
title(titlestr);



xlabel('Participant')
ylabel('M')

bar1_cols = [0, 0.4470, 0.7410; ...
            0, 0.4470, 0.7410; ...
            0, 0.4470, 0.7410; ...
            0, 0.4470, 0.7410; ...
            0.8500, 0.3250, 0.0980]; %0.8500, 0.3250, 0.0980

bar2_cols = [0, 0.2235 , 0.3705; ...
             0, 0.2235 , 0.3705; ...
             0, 0.2235 , 0.3705; ...
             0, 0.2235 , 0.3705; ...
             0.4250, 0.1625, 0.0490];

b1(1).CData = bar1_cols;
b1(1).FaceAlpha = 1;

if analysis_type_struct.percGoodBadTrials ~= 1
    b1(2).CData = bar1_cols; %bar2_cols;
    b1(2).FaceAlpha = 0.5;
end


if analysis_type_struct.percGoodBadTrials ~= 1
    lgd1 = legend("Best Trials Healthy", "Worst Trials Healthy", "Best Trials ALS", "Worst Trials ALS");
    lgd1.Location = 'bestoutside';
else
    lgd1 = legend("Healthy", "ALS");
    lgd1.Location = 'bestoutside';
end

hold off;

subplot(2,1,2);
if analysis_type_struct.percGoodBadTrials == 1
    y = max_M_comthresh_bar(:,1);
    err = max_M_comthresh_sd(:,1); %max_M_comthresh_sem
else
    y = max_M_comthresh_bar;
    err = max_M_comthresh_sd;
end

b2 = bar(y, 'FaceColor','flat');
hold on;
for k = 1:size(y,2)
    % get x positions per group
    xpos = b1(k).XData + b1(k).XOffset;
    % draw errorbar
    er2 = errorbar(xpos, y(:,k), err(:,k), 'LineStyle', 'none', ... 
        'Color', 'k', 'LineWidth', 1);  
    er2.Color = [0 0 0];                            
    er2.LineStyle = 'none';  
    
end

titlestr = strcat(titstr_smooth, "Maximum M Obtained Using Optimal Threshold Common to All Trials");
title(titlestr)
if analysis_type_struct.percGoodBadTrials ~= 1
    lgd1 = legend("Best Trials Healthy", "Worst Trials Healthy", "Best Trials ALS", "Worst Trials ALS");
    lgd1.Location = 'bestoutside';
else
    lgd1 = legend("Healthy", "ALS");
    lgd1.Location = 'bestoutside';
end
xlabel('Participant')
ylabel('M')
xticklabels(X)

b2(1).CData = bar1_cols;
b2(1).FaceAlpha = 1;

if analysis_type_struct.percGoodBadTrials ~= 1
    b2(2).CData = bar1_cols; %bar2_cols;
    b2(2).FaceAlpha = 0.5;
end



hold off;

sgtitle(strcat(titstr_smooth, titstr_trialselection, titstr_percenttrials));


mean_indv_thresh = cellfun(@mean,best_indvthresh);
sd_indv_thresh = cellfun(@std,best_indvthresh);
mean_indv_thresh_als = cellfun(@mean,best_indvthresh_als);
sd_indv_thresh_als = cellfun(@std,best_indvthresh_als);

all_max_Ms = {max_M_indvthresh, max_M_comthresh, AUC_PRC, AUC_ROC, ...
    max_M_indvthresh_als, max_M_comthresh_als, AUC_PRC_als, AUC_ROC_als};

for i=1:numel(all_max_Ms)
    for j=1:2
        if j == 1
            prefix = "best";
        else
            prefix = "worst";
        end

        if mod(i,4)==1 
            midfix = "indvthresh";
        elseif mod(i,4) == 2
            midfix = "comthresh";
        elseif mod(i,4) == 3 
            midfix = 'PRC';
        elseif mod(i,4) == 0
            midfix = 'ROC';
        end

        if i<5
            suffix = 'healthy';
        else
            suffix = 'als';
        end
        
        name = strcat(prefix, '_', midfix, '_', suffix);


        metrics = all_max_Ms{i}{j};
        stat_struct = get_stats(metrics);
        stat_struct.name = name;
        
        if ~exist("stat_array", 'var')
            stat_array = [stat_struct];
        else
            stat_array(end+1) = stat_struct;
        end

    end
end

T = struct2table(stat_array);

function stat_struct = get_stats(metrics)
    stat_struct.mean = mean(metrics);
    stat_struct.sd = std(metrics);
    stat_struct.sem = stat_struct.sd/numel(metrics);
end
