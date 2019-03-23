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
SNR       =  10;     % Signal noise ratio [-]
amp       =  1;      % signal stimulus amplitude [V]
th = 100;

fs_analog =  20*lcm(fs_dac, bitrate);  

%TODO calculate worst case of cable length

%% Generate PRBS (Stimulus)
S = amp*prbs_gen(order);

%------------------------------------------------------------------------------%
%% Ideal case
[xc_ideal, xd_ideal] = fdi_module(S, cable_len, 0, fs_dac, 'none',
  range_adc, 24, bitrate,  1e15, term='Open');

%------------------------------------------------------------------------------%
%% filter + noise + attenuation
[xc_filter, xd_filter] = fdi_module(S, cable_len, cable_att, fs_dac, bw_dac,
  range_adc, res_adc, bitrate,  SNR, term='Open');

%------------------------------------------------------------------------------%
%%interpolation
[py, px] = findpeaks(xc_filter,'DoubleSided','MinPeakHeight', th);

% interpolation bounds
v_y = xc_filter(px(2)-1:px(2)+1);
v_x = xd_filter(px(2)-1:px(2)+1);

% interpolation
bit_w = fs_analog/bitrate;
pp = polyfit(v_x, v_y, 2);
z = roots(pp);

xx = [z(2):0.01:z(1)];
yy = polyval(pp, xx);

%% interpolated peak
[yiter, xinter] = get_position(xc_filter, xd_filter, th, 'hyper');
[yideal, xideal] = get_position(xc_ideal, xd_ideal, th, 'none');

%------------------------------------------------------------------------------%
%% Plot

figure(1)
plot(xd_ideal, xc_ideal, 'o-b')
hold on
plot(xd_filter, xc_filter, 'o-p')
hold on
plot(xx, yy, '--')
hold on
plot(xinter, yiter, '*r', 'linewidth', 4)
text(xinter(2)+0.1, yiter(2)+150, num2str(xinter(2)), 'interpreter', 'latex')
text(xideal(2)+0.1, yideal(2)+150, num2str(xideal(2)), 'interpreter', 'latex')
ylabel('{\Large Korelační amplituda [-]}')
xlabel('{\Large Vzdálenost [m]}')
xlim([20, 30])
grid on

orient('landscape')
h=get(gcf, "currentaxes");
set(h, "fontsize", 16);
grid on

h = legend({'ideální','simulace','interpolace'},'Location','northeast');
set (h, "fontsize", 16);

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
