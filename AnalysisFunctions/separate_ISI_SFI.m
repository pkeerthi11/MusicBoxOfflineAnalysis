%Given signal containing period of stimulus flashing flanked by
%interstimulus interval (at beginning, end, or both), separate the signal
%into the times where the stimulus is flashing (SFI) or the interstimulus
%interval (ISI_segs)

%Input: seg - the trial segment
%Input: seg_state - the state during each sample of the trial

%Output: SFI_seg: the signal during the stimulus flashing interval
%Output: ISI_segs: the signal(s) during the interstimulus interval (ISI) -
%cell array may have two components to account for ISI before SFI and after
%SFI


function [SFI_seg, ISI_segs] = separate_ISI_SFI(seg, seg_state)

seg_state =logical(seg_state);

SFI_seg = seg(seg_state,:);
ISI_state = ~seg_state;

ISI_state = logical(ISI_state);


state_change_idx = find(diff(ISI_state));

if numel(state_change_idx) == 1
    ISI_segs = cell(1,1);

    ISI_segs{1} = seg(ISI_state,:);
else
    ISI_segs = cell(2,1);

    ISI_segs{1} = seg(1:state_change_idx(1),:);
    ISI_segs{2} = seg(state_change_idx(2):end,:);
end