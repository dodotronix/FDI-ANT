%
% This function for correlation of reference and reflected signal 
%
% -- [S, d] = xcorrela(signal_ref, signal_ret, fs, vf)
%      returns correlation function and distance vector
%
% -- PARAMETERS:
%      signal_in : signal input 
%      xcorr_fun : signal output
%                 ____________
%          fs -->|            |
%  signal_ret -->|  XCORRELA  |--> [xcorr_fun, d]
%  signal_ref -->|            |
%          vf -->|____________|
%
% need below package for proper working
% pkg load signal
%

function [xcorr_fun, d] = xcorrela(signal_ref, signal_ret, fs, vf)
  Ts = 1/fs; % signal period [s]
  c = 3e8; % speed of light [m/s]

  if(length(signal_ref) > length(signal_ret))
    error('Reference signal is longer than returned signal')
  endif

  % correlate - length is 2-times larger vector
  xcorr_fun = xcorr(signal_ret, signal_ref); % (signal_ret = static)
  
  % generate distance vector
  bound = (length(xcorr_fun)-1)/2;
  d = [-1*bound:bound]*Ts*c*vf/2;

endfunction
