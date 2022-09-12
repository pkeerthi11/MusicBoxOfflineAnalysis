%Calculate the change in power in each of the spectral bins between the SFI
%(stimulus flashing interval) and ISI (interstimulus interval)

%Note that if two ISIs are included (one before and after trial) - relative
%powers from each are averaged

%Returns the relative_powers solely in the stimulus flashing period, the
%percentatge differences between SFI and ISI, and absolute differences
%(these are vectors storing values for eaching frequency bin set in the
%cutoffs input parameter)

function [relative_powers_SFI, percent_diffs, absolute_diffs] = calc_power_change(seg, seg_state, cutoffs, samplingRate, channels)

[SFI_seg, ISI_segs] = separate_ISI_SFI(seg, seg_state);

if numel(ISI_segs) == 2
    relative_powers_ISI1 = calc_power(ISI_segs{1}, cutoffs, samplingRate, channels);
    relative_powers_ISI2 = calc_power(ISI_segs{2}, cutoffs, samplingRate, channels);
 
    relative_powers_ISI = (relative_powers_ISI1 + relative_powers_ISI2)/2;
    
else
    relative_powers_ISI = calc_power(ISI_segs{1}, cutoffs, samplingRate, channels);
end

relative_powers_SFI = calc_power(SFI_seg, cutoffs, samplingRate, channels);

absolute_diffs = relative_powers_SFI - relative_powers_ISI;

percent_diffs = relative_powers_SFI./relative_powers_ISI;
