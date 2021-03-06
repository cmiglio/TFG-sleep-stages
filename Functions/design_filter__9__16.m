function Hd = design_filter__9__16(Fs)
%DESIGN_FILTER__9__16 Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 9.2 and the DSP System Toolbox 9.4.
% Generated on: 21-Mar-2018 15:37:42

% Elliptic Bandpass filter designed using FDESIGN.BANDPASS.

% All frequency values are in Hz.

Fstop1 = 8.5;     % First Stopband Frequency
Fpass1 = 9;       % First Passband Frequency
Fpass2 = 16;      % Second Passband Frequency
Fstop2 = 16.5;    % Second Stopband Frequency
Astop1 = 60;      % First Stopband Attenuation (dB)
Apass  = 1;       % Passband Ripple (dB)
Astop2 = 60;      % Second Stopband Attenuation (dB)
match  = 'both';  % Band to match exactly

% Construct an FDESIGN object and call its ELLIP method.
h  = fdesign.bandpass(Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass, ...
    Astop2, Fs);
Hd = design(h, 'ellip', 'MatchExactly', match, 'SystemObject', true);

reorder(Hd, 'up');




% [EOF]
