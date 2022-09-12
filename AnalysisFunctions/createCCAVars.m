function [ data ] = createCCAVars( winlen,freqs,harmonics,srate )
%CREATECCAVARS Summary of this function goes here
%   Detailed explanation goes here
    params.t = 0:1/srate: (winlen -1)/srate; 
    data = [];
    for ih=1:1:harmonics
        data = [data;sin(ih*2*pi*freqs*params.t);cos(ih*2*pi*freqs*params.t)];
    end
end