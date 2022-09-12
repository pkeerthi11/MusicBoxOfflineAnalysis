%Generates multiple 4D arrays of each run, trial, storing data from all time points and channels
%The arrays are stored in cell arrays where each cell stores data from a
%different state (i.e. stimulus flashing versus interstimulus interval)

%Inputs
% filelisting: The directory the subject data is stored 
% filterCutoffs: The upper and lower frequencies of the bandpass filter
% samplingRate: sampling rate (Hz)
%Outputs
% state_codes: A list of the codes related to each type of trial
% allTrials: a cell-array storing all the trials of a particular state in each cell (including between all runs of the subject)

function [state_codes, allTrials, samplingRate] = getAllTrialsAlt(fileListing, filterCutoffs, ...
    samplingRate)
    
    notchcutoffs = []; 
    
    [b, a] = createFilter(filterCutoffs, samplingRate);

    if ~isempty(notchcutoffs)
        [b_notch, a_notch] = createNotchFilter(notchcutoffs, samplingRate);
    end
 
    filesIncluded = 0;

    for i = 1:size(fileListing, 1) %change to account for folder having non-DAT files
        path = fullfile(fileListing(i).folder, fileListing(i).name);
        
        if strcmp(fileListing(i).name, '.') || strcmp(fileListing(i).name, '..')
            continue;
        elseif strcmp(fileListing(i).name, 'Test.dat') || strcmp(fileListing(i).name, 'test.dat')
            continue;
        elseif strcmp(fileListing(i).name, 'bad.dat') || strcmp(fileListing(i).name, 'Bad.dat') 
            continue;
        elseif strcmp(fileListing(i).name, 'bad1.dat') || strcmp(fileListing(i).name, 'Bad.dat') 
            continue;
        end 

        try
            [signal,states,parameters] = load_bcidat(path);
        catch
            continue;
        end 

        signal = double(signal);
        signal = filtfilt(b, a, signal);     

        if ~isempty(notchcutoffs)
            signal = filtfilt(b_notch, a_notch, signal);
        end

        samplingRate = parameters.SamplingRate.NumericValue;

        try
            [state_codes, trials] = extractTrialsAlt(signal, states);

            if ~exist('allTrials','var')
                allTrials = cell([numel(state_codes), 1]);
                for j=1:numel(allTrials)
                    allTrials{j} = [];
                end
            end

            for j=1:numel(allTrials)
                padsize = size(trials{j},2)-size(allTrials{j},3);

                if ~isempty(allTrials{j})
                    if padsize > 0
                        allTrials{j} = padarray(allTrials{j},padsize*[0,0,1,0],"post");             
                    elseif padsize < 0
                        trials{j} = padarray(trials{j},-padsize*[0,1,0],"post");         
                    end
                end
                
                allTrials{j}(filesIncluded+1, :, :, :) = trials{j};

            end    

        catch
            continue
        end

        filesIncluded = filesIncluded + 1;        
    end % for i
end % function getAllTrials 


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