%Calculate the statistical significance of the difference in scores
% for each trial (between interstimulus interval and stimulus flashing
% period)

function p_vals = ttest_canon_corr(canon_corr_stim_t, canon_corr_ISI_t)

p_vals = zeros(size(canon_corr_stim_t,[1,2]));

for i=1:size(canon_corr_stim_t,1)
    for j=1:size(canon_corr_stim_t,2)
        cca_vals_trial = squeeze(canon_corr_stim_t(i,j,:))';

        %If it is not the first trial in the run, include the CCA values
        %from before the stimulus flashing period 
        if j ~= 1
            cca_vals_beforetrial = squeeze(canon_corr_ISI_t(i,j-1,:))';
        else
            cca_vals_beforetrial = [];
        end

        %If it is not the last trial in the run, include the CCA from after
        %the stimulus flashing period
        if j <= size(canon_corr_ISI_t,2)
            cca_vals_aftertrial = squeeze(canon_corr_ISI_t(i,j,:))'; %j+1
        else
            cca_vals_aftertrial = [];
        end

        cca_vals_ISI = [cca_vals_beforetrial, cca_vals_aftertrial];

       [~, p_vals(i, j)] = ttest2(cca_vals_trial, cca_vals_ISI, 'tail','right','Vartype','unequal');

    end
end
