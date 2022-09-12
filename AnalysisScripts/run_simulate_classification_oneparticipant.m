%Simulate classification offline for all particiapnts
clear all; close all; clc

%Change directory to match where appropriate functions are saved
addpath('..\AnalysisFunctions\');
addpath(genpath('..\..\ssvep_musicbox\'));

%Change directory to match where participant's session files are stored 
fileListing = dir('..\MLS_Session2_10');

analysis_type_struct.smooth_span = 5; %Number of samples used for smoothing (0 for no smoothing)
%Percentage of good/bad trials to select - to select all trials use 1
%instead of 0.1
analysis_type_struct.percGoodBadTrials = 1; 

%if trialselectionmethod = 1 select trials according to p-value,
% else, find best and worst trials according to CCA score in stimulus
% flashing interval
analysis_type_struct.trialselectionmethod = 1; %

%Change according to flashing frequency used
analysis_type_struct.flashing_frequency = 10;

if analysis_type_struct.percGoodBadTrials == 1
    [AUC_CCA, M_comthresh, M_indvthresh] = simulate_classification_offline(fileListing, 2, analysis_type_struct);
else
    [AUC_CCA_good, M_comthresh_good, M_indvthresh_good] = simulate_classification_offline(fileListing, 2, analysis_type_struct);
    [AUC_CCA_bad, M_comthresh_bad, M_indvthresh_bad] = simulate_classification_offline(fileListing, 3, analysis_type_struct);
end