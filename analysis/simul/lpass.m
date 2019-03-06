%
% This function simulates output of Siglent SDG66022X generator
%
% -- S = lpass(signal_in, t)
%      returns filtered signal (0 - 150Mhz)
%
% -- PARAMETERS:
%      signal_in : signal input 
%              t : input signal time matrix
%      signal_out : signal output
%                 ____________
%                |            |
%   signal_in -->|  LOW-PASS  |--> signal_out
%		         |   FILTER   |
%		         |  (50Mhz)   |
%		         |____________|
%
% need below package for proper working
% pkg load signal
%

function signal_out = lpass(signal_in, fs)
  f_cut = 50e6; %50MHz

  if(f_cut > fs)
    error("The cutoff frequency is greater than sampling frequency.")
  else
    [b, a] = butter(6, f_cut/fs);
    signal_out = filter(b, a, signal_in);
  endif

endfunction
