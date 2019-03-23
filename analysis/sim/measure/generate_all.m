clc;
clear all;
close all;

addpath("../")

%------------------------------------------------------------------------------%
%% launch

% device characteristics
antenna_s11;
%cable_atten;

% method overview
reflections;
compare;
peak_shape;

% accuracy measurement
accuracy_int;
accuracy_res;
accuracy_snr;

