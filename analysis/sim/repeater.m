%
% This function is repeating input signal
% 
% -- USAGE : signal_out = repeater(signal_in, repeat)
%     returns vector of N-repetitions of input signal and time vector   
%
% -- PARAMETERS
%      * signal_in   : signal input
%      * repeat      : desired number of repetitions (cannot be float)
%      * fs          : signal sampling frequency
%                       _____________
%            repeat -->|             |
%         signal_in -->|  REPEATER   |--> signal_out
%                      |_____________|
%
% need below package for proper working
% --

function signal_out = repeater(signal_in, repeat)
  signal_out = repmat(signal_in, 1, repeat);
end
