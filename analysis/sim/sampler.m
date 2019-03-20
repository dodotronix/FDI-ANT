%
% This function is sampling an input signal
% 
% -- USAGE : signal_out = sampler(signal_in, fs_orig, fs_des)
%     returns sampled signal and its time vector   
%
% -- PARAMETERS
%      * signal_in   : signal input
%      * t           : signal input time vector
%      * fs_des      : desired sampling frequency [Hz]
%                       _____________
%            fs_des -->|             |
%         signal_in -->|   SAMPLER   |--> signal_out
%                      |_____________|
%
% need below package for proper working
% --

function signal_out = sampler(signal_in, fs_orig, fs_des) 

  % check divisibility
  if(rem(fs_orig, fs_des) && rem(fs_des, fs_orig))
    error('Non-integer sampling frequency (%d) and desired sampling frequency (%d).',fs_orig,fs_des);
  end

  if(fs_orig < fs_des) % up
    fs_ratio = fs_des/fs_orig;
    signal_out = vec(repmat(signal_in, fs_ratio,1))';
  elseif(fs_orig > fs_des) % down
    fs_ratio = fs_orig/fs_des;
    signal_out = signal_in(1:fs_ratio:end);
  end
end
