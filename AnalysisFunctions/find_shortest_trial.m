%Iterate through all trials/runs in data to find the shortest length trial

%Inputs
%data: multi-dimensional array storing trials/runs in first two dimensions
%samplingRate: sampling rate in Hz

%Outputs
%shortest_time: the length of the shortest trial (in seconds)
%non_zero_samps: a 2D array storing the number of non-zero samples (trial length) for each trial/run

function [shortest_time, non_zero_samps] = find_shortest_trial(data, samplingRate)

%Store the number of non-zero samples
non_zero_samps = zeros(size(data,1:2));

%The maximum number of samples correspond to the size of data along the
%time dimension
max_samples = size(data,3);

%Start min_samples at max and decreasewhen necessary 
min_samples = max_samples;

for i=1:size(data,1)
    for j=1:size(data,2)

        trial = squeeze(data(i,j,:,1));

        %The non-zero samples (corresponding to when the trial is actually
        %running - are the length of the array subtracted by the
        %zero-valued samples
        nonzero_samples = max_samples - sum(trial == 0);
        non_zero_samps(i,j) = nonzero_samples;
        
        if (nonzero_samples < min_samples)
            min_samples = nonzero_samples;
        end
    end
end

%Get time from the minimum number of samples
shortest_time = (min_samples/samplingRate);
