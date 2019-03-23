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

function [xc, xd] = fdi_module(waveform, 
                               cable_len, 
                               cable_att=9, 
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

  % DAC output filter
  Tx_data_filter = lpfio(Tx_data, fs_dac, dac_bw);

  % DAC output signal (analog)
  Tx_signal_dac = resample(Tx_data_filter, fs_analog, fs_adc);

  % noise on output DAC
  Tx_signal_dac_noise = awgn(Tx_signal_dac, SNR, 'measured');

  %----------------------------------------------------------------------------%
  %% Cable 

  if(exist(term, 'file'))
    
    %--------------------------------------------------------------------------%
    %% Antenna 

    % signal delay (function returns fixed cable length)
    Rx_shifted_ant = cable(Tx_signal_dac_noise, fs_analog, cable_del);

    % cable attenuation (forward)
    Tx_cable_ant = attenua(Rx_shifted_ant, cable_len, cable_att);

    % reflected signal from antenna
    Rx_cable_ant = antenna(Tx_cable_ant, fs_analog, term, imp);

    % cable attenuation (backward)
    Rx_signal = attenua(Rx_cable_ant, cable_len, cable_att);

  elseif(strcmp(term, 'Open') || strcmp(term, 'Short'))
    % signal delay
    Rx_signal_shifted = cable(Tx_signal_dac_noise, fs_analog, cable_del);

    if(strcmp(term, 'Short'))
      Rx_signal_shifted = -Rx_signal_shifted;
    end

    % cable attenuation 
    Rx_signal = attenua(Rx_signal_shifted, 2*cable_len, cable_att);
  end
  % Cable signal shift + reference signal (termination - open)
  Rx_signal_complet = Rx_signal + Tx_signal_dac_noise(1:length(Rx_signal)); 

  %----------------------------------------------------------------------------%
  %% A/D converter 

  % Quantization
  adc_max = max(abs(Rx_signal_complet)) / range_adc;
  Rx_data_quant = uquant(Rx_signal_complet,res_adc, adc_max);

  % ADC output
  Rx_data_adc = sampler(Rx_data_quant, fs_analog, fs_adc); 

  %----------------------------------------------------------------------------%
  %% Reference signal
  Ref_data = sampler(waveform, bitrate, fs_adc);
  Ref_data = lpfio(Ref_data, fs_adc, dac_bw);
  Ref_data_noise = awgn(Ref_data, SNR, 'measured');

  % Quantization
  adc_max = max(abs(Ref_data_noise)) / range_adc;
  Ref_data = uquant(Ref_data_noise, res_adc, adc_max);

  %----------------------------------------------------------------------------%
  %% Correlator

    delta = length(Ref_data);
    bitw = fs_dac/bitrate;

    xd = [-2*bitw:delta-bitw]/fs_adc*v_c*v_factor/2;
    xc = xcorr(Rx_data_adc, Ref_data)(4*delta-2*bitw:5*delta-bitw);
end
