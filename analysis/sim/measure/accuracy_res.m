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
%% Setups
order     =  8;      % order of the PN - sequence [-]
res_adc   =  8;      % adc resolution [b]
fs_dac    =  125e6;  % adc (dac) sampling frequency [Hz]
bitrate   =  25e6;   % [b/s]
bw_dac    =  50e6;   % dac bandwidth [Hz]
range_adc =  1;      % adc voltage range [V]
cable_len =  25;     % length of cable [m]
cable_att =  9;      % cable attenuation [dB/100m]
SNR       =  10000;     % Signal noise ratio [-]
amp       =  1;      % signal stimulus amplitude [V]

% constants
v_c = 3e8;
v_factor = 0.695;
th = 600;

fs = [fs_dac:50e6:500e6]; 
res = [4, 8, 14]; % ADC / DAC resolutions

%------------------------------------------------------------------------------%
%% Generate PRBS (Stimulus)
S = amp*prbs_gen(order);

%------------------------------------------------------------------------------%
%% Measure influence of wave delay
result1 = [];
for a = 1:length(res)
  y1 = [];
  delay = cable_len/(v_c*v_factor);

  for i = 1:length(fs)
    % calculate analog sampling frequency
    fs_analog =  10*lcm(fs(i), bitrate);  
    worst1 = [];

    for n = 1:10
      % delay and length setup
      del_set = round(delay*fs(i))/fs(i)+n/fs_analog;
      len_set = v_c*v_factor*del_set;
      
      % get correlation function
      [xc, xd] = fdi_module(S, len_set, cable_att, fs(i), bw_dac,
      range_adc, res(a), bitrate,  SNR, term='Open', del_set);

      % meas peaks - interpolation
      [~, xpos] = get_position(xc, xd, th, 'hyper');
      len_meas = xpos(2)-xpos(1);
      delta = abs(len_set-len_meas);
      worst1 = [worst1, delta];
    end
    y1 = [y1, max(worst1)];
  end
  result1 = [result1; y1];
end

%------------------------------------------------------------------------------%
%% Plot results

figure(1)
fs = fs*1e-6;
plot(fs, result1(1, :), '-o', 'linewidth', 2)
hold on 
plot(fs, result1(2, :), '-o', 'linewidth', 2)
hold on 
plot(fs, result1(3, :), '-o', 'linewidth', 2)
xlim([fs(1), fs(end)])
ylim([0, 0.07])

ylabel('{Odchylka vzdálenosti [m]}')
xlabel('{Vzorkovací frekvence [MHz]}')
grid on

orient('landscape')
h = legend({'  rozlišení 4 bity',...
            '  rozlišení 8 bitů',...
            '  rozlišení 14 bitů'},'Location','northeast');

set (h, 'fontsize', 20, 'position', [0.65,0.72,0.25,0.2]);
set(gca, 'fontsize', 20);

%------------------------------------------------------------------------------%
%% plot exporting setups
target = '../../../doc/outputs/sim/';
name = 'accuracy_res.tex';
name_inc = 'accuracy_res-inc.eps';

print(name, '-dtex');

path = strcat(target, name);
path_inc = strcat(target, name_inc);

movefile(name, path);
movefile(name_inc, path_inc);
