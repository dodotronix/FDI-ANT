clc;
clear all;
close all;

addpath("../:../antenna/:../antenna/VNA/")

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
cable_len =  50;     % length of cable [m]
cable_att =  9;      % cable attenuation [dB/100m]
SNR       =  10;     % Signal noise ratio [-]
amp       =  0.5;      % signal stimulus amplitude [V]

% antenna measured s11
s11 = '../antenna/VNA/K8.dat';

v_c = 3e8;
v_factor = 0.695;

delay = cable_len/(v_c*v_factor);
d = round(delay*fs_dac)/fs_dac;
cable_len = v_c*v_factor*d;

%% Generate PRBS (Stimulus)
S = amp*prbs_gen(order);

%% Module 
% antenna
[xc_ant, xd_ant] = fdi_module(S, cable_len, cable_att, fs_dac, bw_dac,
  range_adc, res_adc, bitrate,  SNR, term=s11);

% Short circuit
[xc_short, xd_short] = fdi_module(S, cable_len, cable_att, fs_dac, bw_dac,
  range_adc, res_adc, bitrate,  SNR, term='Short');

% Open circuit
[xc_open, xd_open] = fdi_module(S, cable_len, cable_att, fs_dac, bw_dac,
  range_adc, res_adc, bitrate,  SNR, term='Open');

%------------------------------------------------------------------------------%
%% estimate peak positions
a = power(amp,2)*(power(2, order)-2)*fs_dac/bitrate;
d_aprox = xd_open(10:75)
g = power(10, d_aprox*-cable_att/1000);
y = a*g;

%------------------------------------------------------------------------------%
%%Plot

figure(1)
plot(d_aprox, y, 'k--', 'linewidth', 1)
hold on
plot(xd_short, xc_short, '-', 'linewidth', 2)
hold on
plot(xd_open, xc_open, '-.', 'linewidth', 2)
hold on
plot(xd_ant, xc_ant, '-', 'linewidth', 2)
hold on
plot(d_aprox, -y, 'k--', 'linewidth', 1)
xlim([-10, 80])
ylabel('{Korelační amplituda [-]}')
xlabel('{Vzdálenost [m]}')
grid on

%% plot exporting setups
orient('landscape')
h = legend({'   teoretický odhad',... 
            '   vedení nakrátko',... 
            '   vedení naprázdno',... 
            '   anténa'},'Location','northeast');

set (h, 'fontsize', 20, 'position', [0.65,0.70,0.25,0.22]);
set(gca, 'fontsize', 20,...
    'gridlinestyle', '--',... 
    'linewidth', 1,...
    'ylim', [-700, 700],...
    'xtick', [-10:10:80],...
    'ytick', [-700:140:700]);
grid on

%% Generate Latex
target = '../../../doc/outputs/sim/'
name = 'reflections.tex'
name_inc = 'reflections-inc.eps'

print(name, '-dtex');

path = strcat(target, name);
path_inc = strcat(target, name_inc);

movefile(name, path);
movefile(name_inc, path_inc);
