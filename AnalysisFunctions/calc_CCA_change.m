function [mCC_diff, mCC_diff_ratio, r_tstim, r_tISI, canon_corr_stim, canon_corr_ISI] = calc_CCA_change(seg, seg_state, pad_before, trial_time, samplingRate, ...
    windowLength, overlapTime, channels, target_freq, harmonics)


[SFI_seg, ISI_segs] = separate_ISI_SFI(seg, seg_state);

if numel(ISI_segs) == 2
    [r_tISI1, ~, canon_corr_ISI1] = CCAAnalysis_onetrial(ISI_segs{1}, pad_before(2), trial_time(2), samplingRate, ...
    windowLength, overlapTime, channels, target_freq, harmonics);
    
    [r_tISI2, ~, canon_corr_ISI2] = CCAAnalysis_onetrial(ISI_segs{2}, pad_before(2), trial_time(2), samplingRate, ...
    windowLength, overlapTime, channels, target_freq, harmonics);

    canon_corr_ISI = (canon_corr_ISI1 + canon_corr_ISI2)/2;

    r_tISI = [r_tISI1, r_tISI2];

    
else
    [r_tISI, ~, canon_corr_ISI] = CCAAnalysis_onetrial(SFI_seg, pad_before(2), trial_time(2), samplingRate, ...
    windowLength, overlapTime, channels, target_freq, harmonics);

end

[r_tstim, ~, canon_corr_stim] = CCAAnalysis_onetrial(SFI_seg, pad_before(1), trial_time(1), samplingRate, ...
    windowLength, overlapTime, channels, target_freq, harmonics);

mCC_diff = canon_corr_stim - canon_corr_ISI;
mCC_diff_ratio = canon_corr_stim/canon_corr_ISI;