clc;
clear all;
close all;

addpath("../")

%packages
pkg load signal;
pkg load miscellaneous;

fs_analog  =  10e9;     % [Hz]
fs_adc     =  125e6;    % [Hz]
vf         =  0.695;    % [-]
bitrate    =  50e6;     % [bit/s]
cable_len  =  3*2.919;  % cable length [m]
cable_gain =  -9;       % gain of the cable [dB]
repeat     =  3;        % signal repetitions

% generate sequence
[G,t] = lfsrgen(bitrate, 4, 1, fs_analog);
[G2, t2] = repeater(G, t, repeat);

% cable delay
[S_back, t_back] = cable(G2, t, cable_len, cable_gain, vf);

% addition of signal 'S_forward' and reflected signal 'S_back'
S_out = [G2, zeros(1, length(S_back)-length(G2))] + S_back;
t_out = t_back; % length(t_back) == length(S_out)

%correlation
[xG, xd] = xcorrela(G, S_out, fs_analog, repeat, vf, bitrate);

figure(1)
subplot(2,1,1)
plot(t, G)
grid on
subplot(2,1,2)
plot(t2, G2)
grid on

figure(2)
plot(xd, xG)
grid on
