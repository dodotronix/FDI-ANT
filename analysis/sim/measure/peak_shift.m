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
SNR       =  100;     % Signal noise ratio [-]
amp       =  0.5;      % signal stimulus amplitude [V]
th = 300;

v_c = 3e8;
v_factor = 0.695;

fs_analog =  20*lcm(fs_dac, bitrate);  

delay = cable_len/(v_c*v_factor);


%% Generate PRBS (Stimulus)
S = amp*prbs_gen(order);

%------------------------------------------------------------------------------%
%% filter + noise + attenuation +
d = round(delay*fs_dac)/fs_dac;
cable_len = v_c*v_factor*d;

[xc_filter, xd_filter] = fdi_module(S, cable_len, cable_att, fs_dac, bw_dac,
  range_adc, res_adc, bitrate,  SNR, term='Open');

%% filter + noise + attenuation + 
del_set0 = round(delay*fs_dac)/fs_dac+20/fs_analog;
len_set0 = v_c*v_factor*del_set0;

[xc_shift0, xd_shift0] = fdi_module(S, len_set0, cable_att, fs_dac, bw_dac,
  range_adc, res_adc, bitrate,  SNR, term='Open');

%% filter + noise + attenuation + 
del_set1 = round(delay*fs_dac)/fs_dac+14/fs_analog;
len_set1 = v_c*v_factor*del_set1;

[xc_shift1, xd_shift1] = fdi_module(S, len_set1, cable_att, fs_dac, bw_dac,
  range_adc, res_adc, bitrate,  SNR, term='Open');
%------------------------------------------------------------------------------%
%%interpolation
%[py, px] = findpeaks(xc_filter,'DoubleSided','MinPeakHeight', th);
[py, px] = findpeaks(xc_shift1,'DoubleSided','MinPeakHeight', th);

% interpolation bounds
v_y = xc_shift1(px(2)-1:px(2)+1);
v_x = xd_shift1(px(2)-1:px(2)+1);

% interpolation
bit_w = fs_analog/bitrate;
pp = polyfit(v_x, v_y, 2);
z = roots(pp);

xx = [z(2):0.01:z(1)];
yy = polyval(pp, xx);

%% interpolated peak
[yiter, xinter] = get_position(xc_shift1, xd_shift1, th, 'hyper');

%------------------------------------------------------------------------------%
%% Plot

figure(1)
plot(xd_filter, xc_filter, '-o', 'linewidth', 1.2, 'markersize', 5 )
hold on
plot(xd_shift1, xc_shift1, '-o', 'linewidth', 1.2, 'markersize', 5)
hold on
plot(xd_shift0, xc_shift0, '-o', 'linewidth', 1.2, 'markersize', 5)
hold on
plot(xx, yy, '-.', 'linewidth', 1, 'color', [0.8, 0.1, 0.1])
hold on
plot(xinter, yiter, 'xr', 'linewidth', 2, 'markersize', 8)

text(xinter(2)-0.1, yiter(2)+43, sprintf('%.2f m', xinter(2)), 'interpreter', 'latex', 'fontsize', 20)
ylabel('{Korelační amplituda [-]}')
xlabel('{Vzdálenost [m]}')
xlim([20, 35])
ylim([-100, 450])
grid on

orient('landscape')
h = legend({sprintf('  vzdálenost %.2f m', cable_len),...
            sprintf('  vzdálenost %.2f m', len_set1),...
            sprintf('  vzdálenost %.2f m', len_set0),...
            '  interpolace'},'Location','northeast');

set (h, 'fontsize', 20, 'position', [0.6,0.72,0.3,0.2]);
set(gca, 'fontsize', 20,...
    'gridlinestyle', '--',... 
    'minorgridlinestyle', '--',...
    'linewidth', 1,...
    'xtick', [20:1.5:35],...
    'ytick', [-100:55:450]);


%------------------------------------------------------------------------------%
%% plot exporting setups
target = '../../../doc/outputs/sim/'
name = 'peak_shift.tex'
name_inc = 'peak_shift-inc.eps'

print(name, '-dtex');

path = strcat(target, name);
path_inc = strcat(target, name_inc);

movefile(name, path);
movefile(name_inc, path_inc);
