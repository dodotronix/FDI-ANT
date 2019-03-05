%
% This function is sampling an input signal
% 
% -- USAGE : [signal_out, t] = sampler(signal_in, t)
%     returns sampled signal and its time vector   
%
% -- PARAMETERS
%      * signal_in   : signal input
%      * t           : signal input time vector
%      * fs_des      : desired sampling frequency [Hz]
%			            _____________
%            fs_des -->|             |
%    [signal_in, t] -->|   SAMPLER   |--> [signal_out, t]
%             fs_in -->|_____________|
%
% need below package for proper working
% pkg load signal

function [signal_out, t_out] = sampler(signal_in, t_in, fs_des) 

  Ts = t_in(2)-t_in(1); %sampling period of input signal
  fs = 1/Ts;
  fs_ratio = fs/fs_des;
  
  % sampling
  signal_out = signal_in(1:fs_ratio:end);
  t_out = t_in(1:fs_ratio:end);

endfunction
