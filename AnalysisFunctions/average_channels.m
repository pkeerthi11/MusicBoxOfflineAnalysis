%Average the stft data from all selected channels stored in channel vec

%Inputs:
%data: A multi-dimensional array in which the last dimension corresponds to different channels
%channel_vec: To average channels 1, 4, and 5 channel_vec = [1,4,5]

%Outputs:
%average: the data array averaged across the selected channels

function average = average_channels(data, channel_vec)

%The num_dim accounts for different data dimensions. Assumes that
%the last dimension stores the number of channels

num_dim = numel(size(data));

if num_dim == 1
    average = mean(data(channel_vec), num_dim);
elseif num_dim == 2
    average = mean(data(:,channel_vec), num_dim);
elseif num_dim == 3
    average = mean(data(:,:,channel_vec), num_dim);
elseif num_dim == 4
    average = mean(data(:,:,:,channel_vec), num_dim);
else
    fprintf("Shouldn't come here. \n")
    average = 0;
end
