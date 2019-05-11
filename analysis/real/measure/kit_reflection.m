clc;
clear all;
close all;

addpath("../:../data/")

%------------------------------------------------------------------------------%
%% Packages 
pkg load signal

%------------------------------------------------------------------------------%
%% Module setups
fs = 125e6;
v_c = 3*10^8; % [m/s]
v_factor = 0.695; % [-]; velocity factor

%------------------------------------------------------------------------------%
%% load real data

% antenna (conditions: order9, 500mV, 10Mbit/s)
%gen_ant = load('ant_ord9_10M_82-5m_gen.txt'); 
%meas_ant = load('ant_ord9_10M_82-5m_meas.txt');
gen_ant = load('ant_ord9__20M_gen.txt'); 
meas_ant = load('ant_ord9__20M_meas.txt');

% cable - open (conditions: order9, 500mV, 10Mbit/s)
gen_open = load('open_cab_ord9__20M_gen.txt');
meas_open = load('open_cab_ord9__20M_meas.txt');

% cable - short (conditions: order9, 500mV, 10Mbit/s)
gen_short = load('short_cab_ord9__20M_gen.txt');
meas_short = load('short_cab_ord9__20M_meas.txt');

%------------------------------------------------------------------------------%
delta = length(gen_short)
k = 27
xc_short = xcorr(meas_short, gen_short)(4*delta:5*delta);
xc_open = xcorr(meas_open, gen_open)(4*delta:5*delta);
xc_ant = xcorr(meas_ant, gen_ant)(4*length(gen_ant):5*length(gen_ant));

bound = (length(xc_open) - 1)/(2*fs);
xd = v_c*v_factor*[-k:length(xc_open)-1-k]/(2*fs);
length(xd)
length(xc_open)

%------------------------------------------------------------------------------%
%%Plot
figure(1)
plot(xd, xc_short, "linewidth", 2)
hold on
plot(xd, xc_open, "linewidth", 2, '-.')
hold on
plot(xd, xc_ant, "linewidth", 2)

xlim([-10, 160])
ylim([-50, 120])
xlabel('{Vzdálenost [m]}')
ylabel('{Korelační amplituda [-]}')

orient('landscape')
h = legend({'   vedení nakrátko',... 
            '   vedení naprázdno',... 
            '   anténa'},'Location','northeast');

set (h, 'fontsize', 20, 'position', [0.65,0.70,0.25,0.22]);
set(gca, 'fontsize', 20,...
    'gridlinestyle', '--',... 
    'linewidth', 1,...
    'xtick', [-10:10:160],...
    'ytick', [-50:17:120]);
grid on

%------------------------------------------------------------------------------%
%%Plot
target = '../../../doc/outputs/real/'
name = 'kit_reflections.tex'
name_inc = 'kit_reflections-inc.eps'

print(name, '-dtex');

path = strcat(target, name)
path_inc = strcat(target, name_inc)

movefile(name, path)
movefile(name_inc, path_inc)

