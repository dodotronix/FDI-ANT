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

order     =  8;      % order of the PN - sequence [-]
res_adc   =  4;      % adc resolution [b]
fs_dac    =  125e6;  % adc (dac) sampling frequency [Hz]
bitrate   =  25e6;   % [b/s]
bw_dac    =  50e6;   % dac bandwidth [Hz]
range_adc =  1;      % adc voltage range [V]
cable_len =  25;     % length of cable [m]
cable_att =  9;      % cable attenuation [dB/100m]
SNR       =  3;     % Signal noise ratio [-]
amp       =  1;      % signal stimulus amplitude [V]

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
grid on

orient('landscape')
h = legend({'STDR', 'TDR'},'Location','northeast');
set (h, "fontsize", 16);
set (ax(1),'fontsize', 20, 'ycolor', 'k');
set (ax(2),'fontsize', 20, 'ycolor', [0.8 0 0.01]);
set(y1, 'color', 'black')
set(y2, 'color', [0.5 0 0.01])

%------------------------------------------------------------------------------%
%% plot exporting setups
%target = '../../../doc/outputs/sim/';
%name = 'compare.tex';
%name_inc = 'compare-inc.eps';

%print(name, '-dtex');

%path = strcat(target, name);
%path_inc = strcat(target, name_inc);

%movefile(name, path);
%movefile(name_inc, path_inc);
