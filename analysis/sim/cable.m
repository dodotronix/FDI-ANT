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

function signal_out = cable(signal_in, fs, delay)
  % shift signal right
  offset = 2*delay*fs;
  signal_out = [zeros(1, offset), signal_in(1:end-offset)];
endfunction
