%
% This function generates and add defined level of noise to input signal.
% 
% -- USAGE : [signal_out, signal_back] = noisegen(signal_in, t)
%     returns signal reflected from antena [signal_back] and 
%     signal going through [signal_out]     
%
% -- PARAMETERS
%      * signal_in   : signal input
%      * SNR_dB      : Signal/noise ratio [dB]
%
%                   _____________
%                  |             |
%     signal_in -->|    NOISE    |--> signal_out
%         SNR_dB-->|  GENERATOR  |
%                  |_____________|
%
%

function signal_out = noisegen(signal_in, SNR_dB)
  SNR = 10^(SNR_dB/10);
  P = mean(signal_in.^2);
  n = sqrt(P/SNR)*rand(1, length(signal_in));

  signal_out = signal_in + n;

  %if(s < 0)
   %noise = randn(1, size); 
  %else
    %noise = randn(1, part);
  %endif

  %while(s > part)
    %noise = [noise, randn(1, part)];
    %s = s - part;
  %endwhile
  %noise = level*[noise, randn(1, s)];
endfunction
