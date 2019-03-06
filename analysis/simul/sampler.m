%
% This function is sampling an input signal
% 
% -- USAGE : [signal_out, t_out] = sampler(signal_in, t_in, fs_des)
%     returns sampled signal and its time vector   
%
% -- PARAMETERS
%      * signal_in   : signal input
%      * t           : signal input time vector
%      * fs_des      : desired sampling frequency [Hz]
%                       _____________
%            fs_des -->|             |
%    [signal_in, t] -->|   SAMPLER   |--> [signal_out, t]
%                      |_____________|
%
% need below package for proper working
% --

function [signal_out, t_out] = sampler(signal_in, t_in, fs_des) 
  Ts = t_in(2) - t_in(1);
  fs_orig = 1/Ts;

  % check divisibility
  if(rem(fs_orig, fs_des))
    error('Original samling frequency is not divisible by desired sampling frequency.')
  elseif(fs_orig < fs_des)
    error('Function Sampler cannot oversampling signal with higher frequency.')
  endif
  
  % calculate frequency ratio
  fs_ratio = fs_orig/fs_des;

  % sampling signal
  signal_out = signal_in(1:fs_ratio:end);
  t_out = t_in(1:fs_ratio:end);

endfunction
