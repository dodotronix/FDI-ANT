%
% This function simulates behaviour of cable without noise
% 
% -- USAGE : signal_out = cable(signal_in, fs, cable_len, v_factor, v_c)
%     returns delayed signal after going through cable     
%
% -- PARAMETERS
%      * signal_in   : signal input
%      * t           : signal input time vector [s]
%      * cable_len   : length of the cable [m]
%      * v_c         : speed of light [m/s]
%      * v_factor    : velocity factor [-]
%                       _____________
%         cable_len -->|             |
%         signal_in -->|    CABLE    |--> [signal_out, l]
%                fs -->|             |
%               v_c -->|             |
%          v_factor -->|_____________|
%
% need below package for proper working
% pkg load signal

function [signal_out, l] = cable(signal_in, fs, cable_len, v_factor, v_c)
  delay = cable_len/(v_c*v_factor); % [s]

  % fix delay value if not divisible by signal period
  delay_fix = round(delay*fs)/fs;
  l = v_c*v_factor*delay_fix;

  if(rem(delay, 1/fs))
    warning('Closest value of submited distance used (%d) [m].\n', l);
  endif

  % shift signal right
  offset = 2*delay_fix*fs;
  %signal_out = [zeros(1, offset), signal_in(1:end-offset)];
  signal_out = [zeros(1, offset), signal_in(1:end-offset)];
endfunction
