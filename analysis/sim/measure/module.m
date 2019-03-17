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
%% Simulation setups
order = 10;         % [-]
bitrate = 25e6;    % [b/s]
fs_adc = 125e6;    % [Hz]
fs_dac = fs_adc;    % [Hz]
fs_analog = 10e9;  % [Hz]
res_adc = 8;       % [b]
adc_range = 1;   % 
cable_len = 11;    % [m]
cable_att = 0;     % [dB/100m]

v_c = 3e8;
v_factor = 0.695;

%------------------------------------------------------------------------------%
%%D/A converter 

% Generate PRBS
S = prbs_gen(order);
S2 = repeater(S, 3);

% DAC output signal
Tx_data = sampler(S2, bitrate, fs_dac);

% DAC output filter
%Tx_data_filter = dac_output(Tx_data, fs_dac);
Tx_data_filter = Tx_data;

% DAC output signal (analog)
Tx_signal_dac = sampler(Tx_data_filter, fs_dac, fs_analog);

%------------------------------------------------------------------------------%
%% Cable

% Cable attenuation forward
Tx_cable_att = attenua(Tx_signal_dac, cable_len, cable_att);

% Termination type
%TODO (Antena, Short)

% Cable attenuation backward
Rx_cable_att = attenua(Tx_cable_att, cable_len, cable_att);

% Cable signal shift + reference signal
Rx_signal_shifted = cable(Rx_cable_att, fs_analog, cable_len, v_factor, v_c);
Rx_signal_cable = Rx_signal_shifted + Tx_signal_dac; 

%------------------------------------------------------------------------------%
%% A/D converter 

% Quantization
adc_max = max(abs(Rx_signal_cable)) / adc_range;
Rx_data_adc_qant = uquant(Rx_signal_cable,res_adc, adc_max);

% ADC output
Rx_data_adc = sampler(Rx_data_adc_qant, fs_analog, fs_adc); 

%------------------------------------------------------------------------------%
%% Correlator
Ref_data = sampler(S, bitrate, fs_adc);

delta = length(Ref_data);
bitw = fs_dac/bitrate;
xd = [-2*bitw:delta-bitw]/fs_adc*v_c*v_factor/2;

xOpen = xcorr(Rx_data_adc, Ref_data)(4*delta-2*bitw:5*delta-bitw);

%------------------------------------------------------------------------------%
%% Plot

figure(1)
plot(xd,xOpen, 'o-')
grid on
