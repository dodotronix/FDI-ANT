%
% This functions simulates cable attenuation 
% 
% -- USAGE : signal_out = attenua(signal_in, t, cable_len, cable_att)
%     returns attenuated signal      
%
% -- PARAMETERS
%      * signal_in   : signal input
%      * cable_len   : length of the cable [m]
%      * cable_att   : signal attenuation koeficient on cable [db/100m]
%                       _____________
%         cable_len -->|             |
%         signal_in -->|   ATTENUA   |--> signal_out
%         cable_att -->|_____________|
%
% need below package for proper working
% -

function [signal_out] = attenua(signal_in, cable_len, cable_att)
  att_tmp = power(10,(cable_len*-cable_att/(20*100))); % [m^-1]
  signal_out = att_tmp*signal_in;
end

