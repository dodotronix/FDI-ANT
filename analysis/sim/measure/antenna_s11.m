clc
clear all;
close all;

addpath("../:../antenna:../antenna/VNA")

file_s11 = 'antenna/VNA/K8.dat';

s11    = load(file_s11);
freq   = s11(:, 1)*1e-6;
module = s11(:, 2);
phase  = s11(:, 3);

%------------------------------------------------------------------------------%
%% Plots
% subplot 1
figure(1)
subplot(2,1,1)
plot(freq, module, 'linewidth', 2)
ylabel('{S11 [dB]}')
xlabel('{Frekvence [MHz]}')
grid on

orient('landscape')
set(gca, 'fontsize', 20,...
    'gridlinestyle', '--',... 
    'linewidth', 1,...
    'xtick', [0:50:500],...
    'ytick', [-40:10:0]);

% subplot 2
subplot(2,1,2)
plot(freq, phase,'r', 'linewidth', 2)
ylim([-180, 180])
ylabel('{Fáze [$^\circ$]}')
xlabel('{Frekvence [MHz]}')
grid on

orient('landscape')
set(gca, 'fontsize', 20,...
    'gridlinestyle', '--',... 
    'linewidth', 1,...
    'xtick', [0:50:500],...
    'ytick', [-180:90:180]);

%------------------------------------------------------------------------------%
%% plot exporting setups
target = '../../../doc/outputs/sim/';
name = 'antenna_s11.tex';
name_inc = 'antenna_s11-inc.eps';

print(name, '-dtex');

path = strcat(target, name);
path_inc = strcat(target, name_inc);

movefile(name, path);
movefile(name_inc, path_inc);
