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
res_adc   =  8;      % adc resolution [b]
fs_dac    =  125e6;  % adc (dac) sampling frequency [Hz]
bitrate   =  25e6;   % [b/s]
bw_dac    =  50e6;   % dac bandwidth [Hz]
range_adc =  1;      % adc voltage range [V]
cable_len =  25;     % length of cable [m]
cable_att =  9;      % cable attenuation [dB/100m]
amp       =  1;      % signal stimulus amplitude [V]

% constants
v_c = 3e8;
v_factor = 0.695;
th = 100;

order = [6, 8];      % order of the PN - sequence [-]
SNR = [5:0.5:30-1];
rlen = 5; % relative delay

%------------------------------------------------------------------------------%
%% Measure influence of wave delay
result = [];
result1 = [];
delay = cable_len/(v_c*v_factor);

% calculate analog sampling frequency
fs_analog =  20*lcm(fs_dac, bitrate);  

for n = 1:length(order)
  y = [];
  y1 = [];

  %% Generate PRBS (Stimulus)
  S = amp*prbs_gen(order(n));

  for i = 1:length(SNR)
    % delay and length setup
    del_set = round(delay*fs_dac)/fs_dac;
    len_set = v_c*v_factor*del_set;
    
    % get correlation function
    [xc, xd] = fdi_module(S, len_set, cable_att, fs_dac, bw_dac,
    range_adc, res_adc, bitrate,  SNR(i), term='Open', del_set);

    % meas peaks - raw
    [~, xpos] = get_position(xc, xd, th, 'none');
    len_meas = xpos(2)-xpos(1);
    delta = (len_set-len_meas)/len_set*100;
    y = [y, delta];

    % meas peaks - interpolation
    [~, xpos] = get_position(xc, xd, th, 'hyper');
    len_meas = xpos(2)-xpos(1);
    delta = (len_set-len_meas)/len_set*100;
    y1 = [y1, delta];
  end
  result = [result; y];
  result1 = [result1; y1];
end

%------------------------------------------------------------------------------%
%% Plot results

figure(1)
%plot(SNR, result(1, :), '--', 'linewidth', 2)
%hold on
plot(SNR, result(2, :), '--', 'linewidth', 2)
hold on
%plot(SNR, result1(1, :), '--', 'linewidth', 2)
%hold on
plot(SNR, result1(2, :), '--', 'linewidth', 2)
xlim([SNR(1), SNR(end)])

ylabel('{\Large Odchylka vzdálenosti [%]}')
xlabel('{\Large poměr signál/šum [dB]}')
grid on

%------------------------------------------------------------------------------%
%% plot exporting setups
target = '../../../doc/outputs/sim/';
name = 'accuracy_snr.tex';
name_inc = 'accuracy_snr-inc.eps';

print(name, '-dtex');

path = strcat(target, name);
path_inc = strcat(target, name_inc);

movefile(name, path);
movefile(name_inc, path_inc);
