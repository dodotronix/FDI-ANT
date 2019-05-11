%
% Function simulates behaviour of FDI MODULE based on STDR method 
%      returns correlation function with distance vector
% 
%      PARAMETERS:
%           * waveform  :  stimulus waveform
%           * cable_len :  cable length [m]
%           * cable_del :  cable delay [m] (optional)
%           * cable_att :  cable attenuation [dB/100m]
%           * fs_dac    :  sampling frequency of D/A converter [Hz]
%           * fs_analog :  samplinf frequency of "analog signal" [Hz]
%           * bitrate   :  submitted waveform bitrate
%           * resol     :  resolution of A/D converter [b]
%           * term      :  termination of the cable (Open, Short, s11 file)
%           * dac_bw    :  DAC filter bandwidth [Hz]
%
%                       __________________
%       waveform   -- >|                  |
%       cable_len  -- >|                  |
%       cable_del  -- >|                  |
%       cable_att  -- >|                  |
%       fs_dac     -- >|    FDI_MODULE    |
%       bitrate    -- >|                  |--> [xc, xd]
%       resol      -- >|                  |
%       order      -- >|                  |
%       term       -- >|                  |
%       SNR        -- >|                  |
%       bandwidth   -->|__________________|
%          
% for proper working needs below packages          
%  pkg signal
%  pkg load signal
%  pkg load communications
%  pkg load ltfat
%

function [xc, xd] = test_module(waveform, 
                               cable_len, 
                               cable_att=0, 
                               fs_dac=125e6, 
                               dac_bw=50e6, 
                               range_adc=1,
                               res_adc=8, 
                               bitrate=25e6, 
                               SNR=10,
                               term='Open',
                               cable_del,
                               fs_analog)

  v_c       =  3e8;                      % light speed
  imp       =  50;                       % cable impedance
  v_factor  =  0.695;                    % velocity factor
  fs_adc    =  fs_dac;

  if ~exist('cable_del')
    cable_del = cable_len/(v_c*v_factor);
    fprintf('Cable delay calculated from cable length (%.15f [s])\n', cable_del)
  end

  if ~exist('fs_analog')
    fs_analog =  20*lcm(fs_dac, bitrate);  % calculate analog sampling frequency
  end

  % repeat signal 3-times
  S2 = repeater(waveform, 3);

  % DAC output signal
  Tx_data = sampler(S2, bitrate, fs_dac);

  %% DAC output filter
  Tx_data_filter = lpfio(Tx_data, fs_dac, dac_bw);

  % DAC output signal (analog)
  Tx_signal_dac = sampler(Tx_data_filter, fs_adc, fs_analog);

  %----------------------------------------------------------------------------%
  %% Cable 

  % signal delay
  Rx_signal_shifted = cable(Tx_signal_dac, fs_analog, cable_del);

  % cable attenuation 
  Rx_signal = attenua(Rx_signal_shifted, 2*cable_len, cable_att);

  % Cable signal shift + reference signal (termination - open)
  Rx_signal_complet = Rx_signal + Tx_signal_dac(1:length(Rx_signal)); 

  figure(2)
  plot(Rx_signal_complet)

  %----------------------------------------------------------------------------%
  %% A/D converter 

  % ADC output
  Rx_data_adc = sampler(Rx_signal_complet, fs_analog, fs_adc); 

  %----------------------------------------------------------------------------%
  %% Reference signal
  Ref_data = sampler(waveform, bitrate, fs_adc);
  Ref_data = lpfio(Ref_data, fs_adc, dac_bw);

  %----------------------------------------------------------------------------%
  %% Correlator

    delta = length(Ref_data);
    bitw = fs_dac/bitrate;

    xd = [-2*bitw:delta-bitw]/fs_adc*v_c*v_factor/2;
    xc = xcorr(Rx_data_adc, Ref_data)(4*delta-2*bitw:5*delta-bitw);
end
