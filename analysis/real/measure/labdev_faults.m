clc;
clear all;
close all;

addpath("../:../data/")

%------------------------------------------------------------------------------%
%% Packages 
pkg load signal

%------------------------------------------------------------------------------%
%% Module setups
fs = 1e9;
v_c = 3*10^8; % [m/s]
v_factor = 0.695; % [-]; velocity factor

%------------------------------------------------------------------------------%
%% load real data
% antenna (conditions: order10, 500mV, 400Mbit/s) 
gen_open = load('forward_lfsr9_3m.txt'); 
meas_open = load('back_lfsr9_3m.txt');

% antenna (conditions: order11, 50mV, 20Mbit/s)
gen_short = load('forward_short_lfsr9_3m.txt'); 
meas_short = load('back_short_lfsr9_3m.txt');

xc_open = xcorr(meas_open, gen_open);
bound = (length(xc_open) - 1)/(2*fs);
xd = v_c*v_factor*[-bound:1/fs:bound]/2;

xc_short = xcorr(meas_short, gen_short);

%------------------------------------------------------------------------------%
%%Plot

figure(1)
plot(xd, xc_short, 'linewidth', 2)
hold on
plot(xd, xc_open, 'linewidth', 2, 'linestyle', '-.')
xlim([-1, 8])
xlabel('{Vzdálenost [m]}')
ylabel('{Korelační amplituda [-]}')
grid on

orient('landscape')
h = legend({'   vedení nakrátko',... 
            '   vedení naprázdno'},'Location','northeast');

set (h, 'fontsize', 20, 'position', [0.66,0.79,0.24,0.13]);
set(gca, 'fontsize', 20,...
    'gridlinestyle', '--',... 
    'linewidth', 1,...
    'ytick', [-150:35:200],...
    'xtick', [-1:0.9:8]);

%------------------------------------------------------------------------------%
%%Plot
target = '../../../doc/outputs/real/'
name = 'labdev_faults.tex'
name_inc = 'labdev_faults-inc.eps'

print(name, '-dtex');

path = strcat(target, name)
path_inc = strcat(target, name_inc)

movefile(name, path)
movefile(name_inc, path_inc)

