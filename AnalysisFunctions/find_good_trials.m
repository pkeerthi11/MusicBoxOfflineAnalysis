%Function that returns the indexes of the best and worst trials based on
%the scores array which can store scores of any type of metric
%Percent stores the percentage of "top" and "worst" values we want to store

%Inputs
%scores: 2D array storing scores for each trial/run
%percent: what percentage of top and bottom values to store?

%Outputs
%i_best: vector of 1st dimesion indices of best scores
%j_best: vector of 2nd dimesion indices of best scores (must be paired with corresponding element in i_best)
%i_worst: vector of 1st dimesion indices of worst scores
%j_worst: vector of 2nd dimesion indices of worst scores (must be paired with corresponding element in i_worst)

function [i_best, j_best, i_worst, j_worst] = find_good_trials(scores, percent)

[~, idx] = sort(scores(:));
idxtopperc = idx(end-floor(percent*numel(scores))+1:end);

if percent ~= 1
    idxbottomperc = idx(1:floor(percent*numel(scores))+1);
else
    idxbottomperc = idx(1:floor(percent*numel(scores)));
end

[i_best, j_best] = ind2sub(size(scores), idxtopperc);
[i_worst, j_worst] = ind2sub(size(scores), idxbottomperc);

end

