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
%     repetit -->|            |
%     bitrate -->|            |
%          vf -->|____________|
%
% need below package for proper working
% pkg load signal
%

function [x_out, d] = xcorrela(signal_ref, signal_ret, fs, repetit, vf, bitrate)
  Ts = 1/fs; % signal period [s]
  c = 3e8; % speed of light [m/s]

  if(length(signal_ref) > length(signal_ret))
    error('Reference signal is longer than returned signal')
  endif

  % correlate - length is 2-times larger vector
  x_out = xcorr(signal_ret, signal_ref); % (signal_ret = static)

  if(repetit > 1)
    % select first part of correlated signal without changeovers
    bit_w = floor(fs/bitrate);
    delta = length(signal_ret) + length(signal_ref)-bit_w;
    x_out = x_out(delta:length(signal_ref)+delta);
    d = [-bit_w:length(x_out)-1-bit_w]*Ts*c*vf/2; % distance vector
  else
    bound = (length(x_out)-1)/2;
    d = [-1*bound:bound]*Ts*c*vf/2;
  end
endfunction
