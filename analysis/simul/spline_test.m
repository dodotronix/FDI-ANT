clc;
clear all;
close all;

%packages
pkg load signal;
pkg load miscellaneous;

fs_analog = 12.5e9;
fs_adc = 125e6;
vf = 0.695;

% generate sequence
[G,t] = lfsrgen(50e6, 9, 1, fs_analog);

% output of generator
S = lpass(G, fs_analog);

% delay on wire
[S_r, t_r] = wire(S, t, 5*2.919, -9, vf);

% addition of signal 'S' and reflected signal 'S_r'
S_add = [S, zeros(1, length(S_r)-length(S))] + S_r;

% sampling signal
S_smp = sampler(S, t, fs_adc);
[S_add_smp, t_smp] = sampler(S_add, t_r, fs_adc);

figure(1)
subplot(2,1,1)
plot(t_r, S_add)
grid on
subplot(2,1,2)
plot(t_smp, S_add_smp)
grid on

%correlation
[corr_S_add, d_S_add] = xcorrela(S, S_add, t, vf);
[corr_S_add_smp, d_S_add_smp] = xcorrela(S_smp, S_add_smp, t_smp, vf); 

figure(2)
xc = corr_S_add/max(corr_S_add);
plot(d_S_add, xc)
hold on
xc_smp = corr_S_add_smp/(max(corr_S_add_smp));
stem(d_S_add_smp, xc_smp)
hold on
plot(d_S_add, ones(1, length(d_S_add))/3) %threshold line
hold on

% spline test
yy = spline(d_S_add_smp, xc_smp, d_S_add);
plot(d_S_add, yy)
hold on

% TODO navzorkovana korelacni funkce a nenavzorkovana maji jinou normovaci
% hodnotu -> zjistit, jak je vyrovnat (spline vypada, ze funguje)
% problem je take se zpusobem odecitani jednotlivych spicek signalu, v pripade,
% ze se sliji dohromady - jak to poznat a jak poznat kolik jich tam je (sirka)??
% idealni by bylo prokladat pouze danou korelacni spicku, jinak regrese nefunguje

% regression test
%p = polyfit(d_S_add_smp, xc_smp, 14);
%y = polyval(p, d_S_add);
%plot(d_S_add, y)
grid on

