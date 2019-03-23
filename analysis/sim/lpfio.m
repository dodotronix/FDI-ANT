%
% This function simulates output of redpitaya DAC
%
% -- S = lpfio(signal_in, fs)
%      returns filtered signal (0 - 50Mhz)
%
% -- PARAMETERS:
%       signal_in : signal input 
%              fs : signal sampling frequency
%                 ____________
%   signal_in -->|    LPF     |--> signal_out
%                |  (50Mhz)   |
%                |____________|
%
% need below package for proper working
% pkg load signal
%

function signal_out = lpfio(signal_in, fs, bw=50e6)
  if (~strcmp(bw, 'none'))
    if(bw > fs/2)
      error('The cutoff frequency (%d) is greater than 1/2 of DAC sampling frequency (%d).',bw, fs)
    else
      [b, a] = butter(6, bw/fs);
      signal_out = filter(b, a, signal_in);
    end
  else
    signal_out = signal_in;
  end
end
