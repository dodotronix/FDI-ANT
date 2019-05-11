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
SNR       =  -3;     % Signal noise ratio [-]
amp       =  0.5;      % signal stimulus amplitude [V]

v_c = 3e8;
v_factor = 0.695;

delay = cable_len/(v_c*v_factor);
d = round(delay*fs_dac)/fs_dac;
cable_len = v_c*v_factor*d;

% Generate PRBS
S = amp*prbs_gen(order);

% Generate pulse 
P = [ones(1,1), zeros(1, bitrate/1e6-1)]; % f = 1e6

[xc_tdr, xd_tdr] = fdi_module(P, cable_len, cable_att, fs_dac, bw_dac,
  range_adc, res_adc, bitrate,  SNR, term='Open');

[xc_stdr, xd_stdr] = fdi_module(S, cable_len, cable_att, fs_dac, bw_dac,
  range_adc, res_adc, bitrate,  SNR, term='Open');

%------------------------------------------------------------------------------%
%%Plot

figure(1)
[ax, y1, y2] = plotyy(xd_tdr, xc_stdr(1:length(xd_tdr)), xd_tdr, xc_tdr);
set(y1,'linewidth',2, 'linestyle', '-');
set(y2,'linewidth',2, 'linestyle', '-.');

ylabel('{Korelační amplituda [-]}')
xlabel('{Vzdálenost [m]}')

orient('landscape')
h = legend({'  STDR', '  TDR'},'Location','northeast');
set (h, "fontsize", 20, 'position', [0.75,0.80,0.15,0.12]);

set(ax(1), 'fontsize', 20,...
    'gridcolormode', 'manual',...
    'gridlinestyle', '--',... 
    'gridcolor', [0.84, 0.84, 0.84],...
    'linewidth', 1,...
    'xtick', [0:10:100],...
    'ylim',[-400,800],...
    'ytick', [-400:100:800]);

set(ax(2), 'fontsize', 20,...
    'gridlinestyle', '--',... 
    'linewidth', 1,...
    'xtick', [],...
    'ytick', [-4:8],...
    'ylim', [-4,8]);
grid on

%------------------------------------------------------------------------------%
%% plot exporting setups
target = '../../../doc/outputs/sim/';
name = 'compare1.tex';
name_inc = 'compare1-inc.eps';

print(name, '-dtex');

path = strcat(target, name);
path_inc = strcat(target, name_inc);

movefile(name, path);
movefile(name_inc, path_inc);
