%
% This function simulates behaviour of antenna.
% 
% -- USAGE : signal_out = antenna(signal_in, fs, file_s11, imp)
%     returns signal reflected from antenna 
%
% -- PARAMETERS
%      * signal_in   : signal input
%      * file_s11    : measured S11  
%      * fs          : input signal sampling frequency
%      * imp         : wire impedance
%
%		              _____________
%		             |             |
%   signal_in -->|   ANTENNA   |--> signal_back
%		             |_____________|
%
% need below package for proper working
% pkg load signal

function signal_back = antenna(signal_in, fs, file_s11, imp=50)
  s11         = load(file_s11);
  freq_axis   = s11(:, 1);
  module_axis = s11(:, 2);
  phase_axis  = s11(:, 3);

  % signal -> analytic signal
  S_hilb = hilbert(signal_in);

  % analytic signal spectrum
  S_spect = fft(S_hilb);
  fstep = fs/length(signal_in);
  fx = [0:fstep:fs-1];

  %% convert antena S11 [dB] -> [-] 
  module_axis = power(10, module_axis/20);

  %% aproximation
  module_apx = interp1(freq_axis, module_axis, fx, 'extrap');
  phase_apx  = interp1(freq_axis, phase_axis, fx, 'extrap');

  %% aproximation of reflection coefficient S11 - complex spectrum
  R_ant = module_apx.*(cosd(phase_apx) + sind(phase_apx).*i);

  %% spectra
  spect_back = R_ant.*S_spect;

  %% signal back
  signal_back = real(ifft(spect_back));

  %% TODO correct calculation
  %p_sig = sum(power(abs(S_spect),2)/imp)/fstep;
  %p_back = sum(power(abs(spect_back),2)/imp)/fstep
  %p_out = p_sig - p_back

endfunction
