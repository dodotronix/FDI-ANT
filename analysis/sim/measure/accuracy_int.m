clc;
clear all;
close all;

addpath("../")

%------------------------------------------------------------------------------%
%% Packages 
pkg load signal
pkg load communications
pkg load ltfat

%------------------------------------------------------------------------------%
%% Setups
order     =  8;      % order of the PN - sequence [-]
res_adc   =  8;      % adc resolution [b]
fs_dac    =  125e6;  % adc (dac) sampling frequency [Hz]
bitrate   =  25e6;   % [b/s]
bw_dac    =  50e6;   % dac bandwidth [Hz]
range_adc =  1;      % adc voltage range [V]
cable_len =  25;     % length of cable [m]
cable_att =  9;      % cable attenuation [dB/100m]
SNR       =  40;     % Signal noise ratio [-]
amp       =  1;      % signal stimulus amplitude [V]

% constants
v_c = 3e8;
v_factor = 0.695;
th = 600;

fs = [fs_dac:50e6:1e9]; 
rlen = 5; % relative delay

%------------------------------------------------------------------------------%
%% Generate PRBS (Stimulus)
S = amp*prbs_gen(order);

%------------------------------------------------------------------------------%
%% Measure influence of wave delay
result = [];
result1 = [];
delay = cable_len/(v_c*v_factor);

for i = 1:length(fs)
  % calculate analog sampling frequency
  fs_analog =  20*lcm(fs(i), bitrate);  

  % delay and length setup
  del_set = round(delay*fs(i))/fs(i)+rlen/fs_analog;
  len_set = v_c*v_factor*del_set;
  
  % get correlation function
  [xc, xd] = fdi_module(S, len_set, cable_att, fs(i), bw_dac,
  range_adc, res_adc, bitrate,  SNR, term='Open', del_set);

  % meas peaks - raw
  [~, xpos] = get_position(xc, xd, th, 'none');
  len_meas = xpos(2)-xpos(1);
  delta = (len_set-len_meas)/len_set*100;
  result = [result, delta];

  % meas peaks - interpolation
  [~, xpos] = get_position(xc, xd, th, 'hyper');
  len_meas = xpos(2)-xpos(1);
  delta = (len_set-len_meas)/len_set*100;
  result1 = [result1, delta];
end

%------------------------------------------------------------------------------%
%% Plot results

figure(1)
fs = fs*1e-6;
plot(fs, result, '--', 'linewidth', 2)
hold on 
plot(fs, result1, '-o', 'linewidth', 2)
fill([fs, fs(end), fs(1)], [result, 0, 0], 'r', 'facealpha', 0.2)
xlim([fs(1), fs(end)])

ylabel('{\Large Odchylka vzdálenosti [%]}')
xlabel('{\Large Vzorkovací frekvence [MHz]}')
grid on

orient('landscape')
h = legend({'bez interpolace', 's interpolací'},'Location','northeast');
set (h, "fontsize", 16);

