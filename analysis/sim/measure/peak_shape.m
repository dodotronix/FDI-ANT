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
%% Module setups

order     =  9;      % order of the PN - sequence [-]
res_adc   =  14;      % adc resolution [b]
fs_dac    =  125e6;  % adc (dac) sampling frequency [Hz]
bitrate   =  25e6;   % [b/s]
bw_dac    =  50e6;   % dac bandwidth [Hz]
range_adc =  1;      % adc voltage range [V]
cable_len =  25;     % length of cable [m]
cable_att =  9;      % cable attenuation [dB/100m]
SNR       =  6;     % Signal noise ratio [-]
amp       =  0.5;      % signal stimulus amplitude [V]
th = 300;

v_c = 3e8;
v_factor = 0.695;

fs_analog =  20*lcm(fs_dac, bitrate);  

delay = cable_len/(v_c*v_factor);
d = round(delay*fs_dac)/fs_dac;
cable_len = v_c*v_factor*d;

%% Generate PRBS (Stimulus)
S = amp*prbs_gen(order);

%------------------------------------------------------------------------------%
%% Ideal case
[xc_ideal, xd_ideal] = fdi_module(S, cable_len, cable_att, fs_dac, 'none',
  range_adc, 24, bitrate,  1e15, term='Open');

%------------------------------------------------------------------------------%
%% filter + noise + attenuation
[xc_filter, xd_filter] = fdi_module(S, cable_len, cable_att, fs_dac, bw_dac,
  range_adc, res_adc, bitrate,  SNR, term='Open');

%% filter + noise + attenuation
[xc_filter1, xd_filter1] = fdi_module(S, cable_len, cable_att, fs_dac, 28e6,
  range_adc, res_adc, bitrate,  SNR, term='Open');

%% filter + noise + attenuation
[xc_filter2, xd_filter2] = fdi_module(S, cable_len, cable_att, fs_dac, 20e6,
  range_adc, res_adc, bitrate,  SNR, term='Open');

%------------------------------------------------------------------------------%
%% Plot

figure(1)
plot(xd_ideal, xc_ideal, '-', 'linewidth', 1.2)
hold on
plot(xd_filter, xc_filter, '-o', 'linewidth', 1.2, 'markersize', 5 )
hold on
plot(xd_filter1, xc_filter1, '-o', 'linewidth', 1.2, 'markersize', 5 )
hold on
plot(xd_filter2, xc_filter2, '-o', 'linewidth', 1.2, 'markersize', 5 )

ylabel('{Korelační amplituda [-]}')
xlabel('{Vzdálenost [m]}')
xlim([20, 30])
ylim([-100, 450])
grid on

orient('landscape')
h = legend({'  bez filtru',...
            '  s filtrem na 50 MHz',...
            '  s filtrem na 28 MHz',...
            '  s filtrem na 20 MHz'},'Location','northeast');

set (h, 'fontsize', 20, 'position', [0.6,0.72,0.3,0.2]);
set(gca, 'fontsize', 20,...
    'gridlinestyle', '--',... 
    'minorgridlinestyle', '--',...
    'linewidth', 1,...
    'xtick', [20:30],...
    'ytick', [-100:55:450]);

%------------------------------------------------------------------------------%
%% plot exporting setups
target = '../../../doc/outputs/sim/'
name = 'peak_shape.tex'
name_inc = 'peak_shape-inc.eps'

print(name, '-dtex');

path = strcat(target, name);
path_inc = strcat(target, name_inc);

movefile(name, path);
movefile(name_inc, path_inc);
