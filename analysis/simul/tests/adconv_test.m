
clc; 
clear all;
close all;

addpath("../")

pkg load signal

%% setups
fs =  1e9;            % [Hz]
Ts =  1/fs;           % [s]
f  =  50e4;           % [Hz]
T  =  1/f;            % [s]
t  =  [0:Ts:5*T-Ts];  % [s]

%% application
sig = cos(2*pi*f*t);
signal = sig;

% quantization
[adc_res, t_res] = adconv(signal, t, 125e6, 4, 2); 

plot(t_res, adc_res)
hold on
plot(t, signal)
grid on
xlabel("t [s]")
ylabel("U [V]")
