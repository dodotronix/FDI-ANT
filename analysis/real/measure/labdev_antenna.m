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
ref10 = load('antena_forward_1023_500mv.txt'); 
meas10 = load('antena_back_1023_500mv.txt');

% antenna (conditions: order11, 50mV, 20Mbit/s)
ref11 = load('antena_forward_11_50mv.txt'); 
meas11 = load('antena_back_11_50mv.txt');


xc10 = xcorr(meas10, ref10);
bound = (length(xc10) - 1)/(2*fs);
xd10 = v_c*v_factor*[-bound:1/fs:bound]/2;

xc11 = xcorr(meas11, ref11);
bound = (length(xc11) - 1)/(2*fs);
xd11 = v_c*v_factor*[-bound:1/fs:bound]/2;

%------------------------------------------------------------------------------%
%%Plot

figure(1)
%subplot(2, 1, 1)
plot(xd10, xc10, "linewidth", 2)
xlim([-10, 80])
xlabel('{Vzdálenost [m]}')
ylabel('{Korelační amplituda [-]}')
grid on

hold on
plot(xd11, xc11, "linewidth", 2)

h = legend({'   konfigurace 1',... 
            '   konfigurace 2'},'Location','northeast');

orient('landscape')
set (h, 'fontsize', 20, 'position', [0.7,0.8,0.20,0.12]);
set(gca, 'fontsize', 20,...
    'gridlinestyle', '--',... 
    'linewidth', 1,...
    'xtick', [-10:10:80],...
    'ytick', [-60:16:100]);

%------------------------------------------------------------------------------%
%%Plot
target = '../../../doc/outputs/real/'
name = 'labdev_antenna.tex'
name_inc = 'labdev_antenna-inc.eps'

print(name, '-dtex');

path = strcat(target, name)
path_inc = strcat(target, name_inc)

movefile(name, path)
movefile(name_inc, path_inc)

