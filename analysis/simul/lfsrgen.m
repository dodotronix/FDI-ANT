%
% This function generates lfsr signal waveform from order_s 3 up to 13
%
% -- [s, t] = lfsrgen(bitrate_s, order_s, amp_s, f_smp_s)
%      returns pseudo random bit sequence (PRBS) with sampling frequency f_smp_s
%
% -- PAREMETRS
%      * bitrate_s  : sequence bitrate in bit/Hz
%      * order_s_s  : length of linear shift register (LFSR order)
%      * amp_s      : amplitude of output signal peak to peak 
%      * f_smp_s    : sampling frequency of output signal
%
%      bitrate_s and f_smp_s needs to be multiples!!!
%
%                   _____________
%    bitrate_s  -->|             |
%    order_s    -->|    LFSR     |--> [signal, time]
%    amp_s      -->|  GENERATOR  |
%    f_smp_s    -->|             |
%                  |_____________|
%
% need below package for proper working
% pkg load miscellaneous
%

function [signal_out, time] = lfsrgen(bitrate_s, order_s, amp_s, f_smp_s) 
  seed = [1];
  start_value = [seed, zeros(1, order_s - length(seed))]; % addition of zeros
  lfsr_reg = start_value;

  % mask for particular lengths of lfsr
  if( order_s == 3)
    feedback_mask = [0, 1, 1]; % (2) xor (3) 
  elseif(order_s == 4)
    feedback_mask = [0, 0, 1, 1];
  elseif(order_s == 5)
    feedback_mask = [0, 0, 1, 0, 1];
  elseif(order_s == 6)
    feedback_mask = [0, 0, 0, 0, 1, 1];
  elseif(order_s == 7)
    feedback_mask = [0, 0, 0, 0, 0, 1, 1];
  elseif(order_s == 8)
    feedback_mask = [0, 0, 0, 1, 1, 1, 0, 1];
  elseif(order_s == 9)
    feedback_mask = [0, 0, 0, 0, 1, 0, 0, 0, 1];
  elseif(order_s == 10)
    feedback_mask = [0, 0, 0, 0, 0, 0, 1, 0, 0, 1];
  elseif(order_s == 11)
    feedback_mask = [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1];
  elseif(order_s == 12)
    feedback_mask = [1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1];
  elseif(order_s == 13)
    feedback_mask = [1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1];
  endif

  %% calculate output sequence
  do
    feedback_reg = lfsr_reg & feedback_mask;
    % (x(1) xor x(0)) xor x(2)) xor ... )
    feedback_bit = reduce(@(x,y) xor(x,y), feedback_reg); 
    lfsr_reg = [feedback_bit, lfsr_reg(1:end-1)];

    % save number on next position in signal array
    signal_out(end + 1) = lfsr_reg(1); 
  until (all(lfsr_reg == start_value));

  % check nyquist criterium
  if(f_smp_s <= 2*bitrate_s)
    error('Sampling rate does not fulfill Niquist-Shannon theorem.')
  elseif(mod(f_smp_s, bitrate_s))
    error('Sampling frequency is not dividable by bitrate.')
  endif

  % create output waveform
  bit_width = f_smp_s/bitrate_s
  signal_out = repmat(signal_out, bit_width, 1);
  signal_out = reshape(signal_out(:), 1, length(signal_out(:)));
  signal_out = amp_s*(signal_out-0.5); 

  % create time vector
  step = 1/f_smp_s;
  stop_time = (2^order_s-1)/bitrate_s;
  time = [0:step:stop_time-step];

endfunction
