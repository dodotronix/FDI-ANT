%
% This function is repeating input signal
% 
% -- USAGE : [signal_out, t_out] = repeater(signal_in, t_in, repeat)
%     returns vector of N-repetitions of input signal and time vector   
%
% -- PARAMETERS
%      * signal_in   : signal input
%      * t           : signal input time vector
%      * fs_des      : desired number of repetitions (cannot be float)
%                       _____________
%            repeat -->|             |
%    [signal_in, t] -->|  REPEATER   |--> [signal_out, t]
%                      |_____________|
%
% need below package for proper working
% --

function [signal_out, t_out] = repeater(signal_in, t_in, repeat)
  % get sampling frequency
  Ts = t_in(2) - t_in(1);
  fs = 1/Ts;

  signal_out = repmat(signal_in, 1, repeat);
  t_out = [0:length(signal_out)-1]/fs;

endfunction
