%
% This function make signal conversion like A/D converter (mid-tread)
% using defined resolution and sampling frequency
%
% -- [S, T] = adconv(signal_in, t, f_smp, resolution, u_ref)
%      returns sampled and discrete level signal with corresponding time domain 
%
% -- PAREMETRS
%      * signal_in   : signal on input
%      * t           : time of the signal on input
%      * f_smp       : sampling frequency of A/D converter [Hz]
%      * resolution  : bit resolution of A/D converter [bit]
%      * u_ref       : reference voltage [V]
%
%                     _______________
%          fs_des -->|               |
%       signal_in -->|               |--> [signal_out, t_out]
%      resolution -->| A/D CONVERTER |
%           u_ref -->|               |
%               t -->|_______________|
%

function [signal_out, t_out] = adconv(signal_in, t, fs_des, resolution, u_ref)

  Ts = t(2)-t(1); %sampling period of input signal
  fs = 1/Ts;

  % check divisibility
  if(rem(ceil(fs), fs_des))
    error('Sampling frequency is not divisible by desired sampling frequency.')
  else
    fs_ratio = ceil(fs/fs_des)
  endif

  result = [];
  lvl_num = 2^resolution;
  step = (u_ref)/(lvl_num-1)
  u_lvl = [0:lvl_num-1]*step - u_ref/2 % voltage levels for mid-tread
  %u_lvl = [0:lvl_num-1]*step - u_ref + step/2 % voltage levels for mid-rise
  
  % signal sampling
  signal_in = signal_in(1:fs_ratio:end);
  t_out = t(1:fs_ratio:end);


  for i = 1:length(signal_in)
    % find all lowers -> take the last one
    low = u_lvl(u_lvl <= signal_in(i));  
    % find all higher values -> take the first
    high = u_lvl(u_lvl >= signal_in(i));
    
    % signal excites highest possible level of adc
    if(length(high) == 0)
      result(i) = u_lvl(end);
    elseif(length(low) == 0)
      result(i) = u_lvl(1);
    else
      % find the center value
      avg = mean([low(end), high(1)]);
      if(signal_in(i) >= avg)
        result(i) = high(1);
      else
        result(i) = low(end);
      endif
    endif
  endfor

  signal_out = result;

endfunction

