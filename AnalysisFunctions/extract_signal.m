%Function takes in the directory of the trials of interest, asks the user
%to select a filename and extract and the signal and sampling rate from the
%data collected in the file

%Inputs:
%fileListing: directory where trials are stored
%filterCutoffs: upper and lower frequencies of applied filter
%use_all_trials: a boolean which is true if all trials should be used when calculating accuracy scores. if it is false, the user is prompted to select a particular trial

%Outputs
%signal: signal measured from file
%states: stores whether the stimulus is on or off
%samplingRate: sampling rate recorded from file
%filename: the name of the file selected by the user
function [signal, states, samplingRate, filename] = extract_signal(fileListing, filterCutoffs, use_all_trials)

%Select directory
valid_files = {};
idx = 1;


for i = 1:size(fileListing, 1)
    if strcmp(fileListing(i).name, '.') || strcmp(fileListing(i).name, '..')
        continue;
    elseif strcmp(fileListing(i).name, 'Test.dat') || strcmp(fileListing(i).name, 'test.dat')
        continue;
    elseif strcmp(fileListing(i).name, 'bad.dat') || strcmp(fileListing(i).name, 'bAD.dat') 
        continue;
    elseif strcmp(fileListing(i).name, 'bad1.dat') || strcmp(fileListing(i).name, 'Bad.dat') 
        continue;
    end 
    
    fprintf("%d. %s\n",idx, fileListing(i).name);
    valid_files{idx} = fileListing(i).name; idx = idx + 1;
end



if use_all_trials
    signal = cell(numel(valid_files),1);
    states = cell(numel(valid_files),1);
    for i=1:numel(valid_files)
        path = fullfile(fileListing(i).folder, valid_files{i});
        [signal_i, states_i, parameters] = load_bcidat(path);
        samplingRate = parameters.SamplingRate.NumericValue; 
        signal_i = double(signal_i);
        [b, a] = createFilter(filterCutoffs, samplingRate);
        signal_i = filtfilt(b, a, signal_i);
        signal{i} = signal_i;
        states{i} = states_i.Stimulus; %delete .Stimulus if it doesn't work
    end

    filename = 'NA';

else 
    %Choose filename
    prompt = sprintf("Please type in the selected file number\n");
    valid_selected = false;
    while ~valid_selected
        filenum = input(prompt);
        try
            filename = valid_files{filenum};
            valid_selected = true;
        catch
            fprintf("Invalid input, please enter a listed number.\n");
        end
    end

    %Load file, extract signal/sampling rate and apply filter
    path = fullfile(fileListing(1).folder, filename);
    [signal, states, parameters] = load_bcidat(path);
    samplingRate = parameters.SamplingRate.NumericValue;
    [b, a] = createFilter(filterCutoffs, samplingRate);

    notchcutoffs = [9.5, 11.5]; 

    if ~isempty(notchcutoffs)
        [b_notch, a_notch] = createNotchFilter(notchcutoffs, samplingRate);
    end

    signal = double(signal);
    signal = filtfilt(b, a, signal);

    if ~isempty(notchcutoffs)
        signal = filtfilt(b_notch, a_notch, signal);
    end

end



end

function [b, a] = createFilter(cutoffs, samplingRate)
    % FILTER
    fc = cutoffs;
    fs = samplingRate;
    [b,a] = butter(6,fc/(fs/2),'bandpass');    
end % function filterSignal 


function [b, a] = createNotchFilter(cutoffs, samplingRate)
    % FILTER
    fc = cutoffs;
    fs = samplingRate;
    [b,a] = butter(6,fc/(fs/2),'stop');    
end % function filterSignal 