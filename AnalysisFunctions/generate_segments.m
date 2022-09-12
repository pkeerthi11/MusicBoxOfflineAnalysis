%Takes a 1D or 2D vector in the time-domain and generates segments the
%length of windowLength with overlap in the segments equal to overlapTime

%If 2D vector, the 2nd dimension stores the number of channels

%Inputs
% data:  1D or 2D vector in the time-domain
% windowLength: the length of the window in seconds
% samplingRate: sampling rate (Hz)
% overlapTime: the length of seconds of overlap between segments

%Outputs
% segments: an array storing data separated into different segments
% t: a time-vector where each element corresponds to the center timepoint of the corresponding segment

function [segments, t] = generate_segments(data, windowLength, samplingRate, overlapTime)

%Find the number of dimensions the data has
dims = size(data);
num_dim = numel(dims);

%Number of samples in data
num_samp = size(data,1);

%Find number of samples in window, round up
wLs = ceil(windowLength*samplingRate);

%Find number of samples in over, round up
oTs = ceil(overlapTime*samplingRate);

%The number of samples between the start of each segment
seg_start_dif = wLs - oTs;

if seg_start_dif < 0 
    fprintf("Invalid input! Overlap time exceeds windowLength\n");
end

seg_start = 1;
seg_end = seg_start + wLs - 1;
seg = 1;

t = [];

if num_dim == 1
    while(seg_end < num_samp)
        segments(seg,:) = data(seg_start:seg_end);

        seg_start = seg_start + seg_start_dif;
        seg_end = seg_start + wLs - 1;

        seg = seg + 1;

        %Find average time of segment and store in time vector
        t(end + 1) = (seg_start + seg_end)/(2*samplingRate);
    end

elseif num_dim == 2

    while(seg_end < num_samp)
        segments(seg,:,:) = data(seg_start:seg_end, :);

        seg_start = seg_start + seg_start_dif;
        seg_end = seg_start + wLs - 1;

        seg = seg + 1;

        %Find average time of segment and store in time vector
        t(end + 1) = (seg_start + seg_end)/(2*samplingRate);
    end

else
    fprintf("Invalid input! Trial data has too many dimensions\n");
    segments = data;
    return;
end


