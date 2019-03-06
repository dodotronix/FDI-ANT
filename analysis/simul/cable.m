%
% This function simulates behaviour of cable without noise
% 
% -- USAGE : [signal_out, t] = cable(signal_in, t, gain, vf)
%     returns delayed signal after going through cable back and forth     
%
% -- PARAMETERS
%      * signal_in   : signal input
%      * t           : signal input time vector [s]
%      * c_length    : length of the cable [m]
%      * vf          : velocity factor [-]
%      * gain        : signal attenuation koeficient on cable [db/100m]
%                       _____________
%      	   c_length -->|             |
%    [signal_in, t] -->|    CABLE    |--> [signal_out, t]
%                vf -->|             |
%              gain -->|_____________|
%
% need below package for proper working
% pkg load signal

function [signal_out, t] = cable(signal_in, t, c_length, gain, vf)
  c        =  3e8;                           % [m/s]
  t_step   =  t(2)-t(1);                     % [s]
  delay    =  2*c_length/(c*vf);             % [s]
  gain_tmp =  (10^(c_length*gain/(20*100))); % [m^-1]

  % check divisibility
  if(delay < t_step)
    l = c*vf*t_step/2;
    printf("Minimum length [m]: '%f'\n", l)
    error("Can't set submited length. Delay is less than sampling period.")
  elseif(rem(delay, t_step))
    % find nearest number of delay
    d = t_step; % d => iteration value to find nearest delay
    while(d < delay)
      d = d + t_step;
    endwhile
    if(delay-d-t_step < d-delay) 
      d = d-t_step;
    endif
    l = c*vf*d/2;
    printf("Near divisible value of length [m]: '%f'\n", l)
    error("Delay is not divisible by t_step variable.")
  endif
  
  % shift signal right
  offset = ceil(delay/t_step)
  signal_out = [zeros(1, offset), signal_in];

  % extention of time vector based on offset value
  t = [t,[t(end)+t_step:t_step:t(end)+offset*t_step]]; 

  % apply gain to signal out (^2 because signal runs back and forth)
  signal_out = (gain_tmp^2)*signal_out;

endfunction
