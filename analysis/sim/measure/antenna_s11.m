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
plot(freq, module, 'linewidth', 3)
ylabel('{\Large S11 [dB]}')
xlabel('{\Large Frekvence [MHz]}')
grid on

orient('landscape')
h=get(gcf, "currentaxes");
set(h, "fontsize", 16);
grid on

% subplot 2
subplot(2,1,2)
plot(freq, phase,'r', 'linewidth', 3)
ylim([-180, 180])
ylabel('{\Large fáze [$^\circ$]}')
xlabel('{\Large Frekvence [MHz]}')
grid on

orient('landscape')
h=get(gcf, "currentaxes");
set(h, "fontsize", 16);
grid on

target = '../../../doc/outputs/sim/';
name = 'antenna_s11.tex';
name_inc = 'antenna_s11-inc.eps';

print(name, '-dtex');

path = strcat(target, name);
path_inc = strcat(target, name_inc);

movefile(name, path);
movefile(name_inc, path_inc);
