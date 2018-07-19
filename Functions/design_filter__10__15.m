function bp_filter = design_filter__10__15(Fs)
    Fstop1 = 9;           % First Stopband Frequency
    Fpass1 = 10;          % First Passband Frequency
    Fpass2 = 15;          % Second Passband Frequency
    Fstop2 = 16;          % Second Stopband Frequency
    Astop1 = 30;          % First Stopband Attenuation (dB)
    Apass  = 1;           % Passband Ripple (dB)
    Astop2 = 30;          % Second Stopband Attenuation (dB)
    match  = 'stopband';  % Band to match exactly
    
    h  = fdesign.bandpass(Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass, Astop2, Fs);
    bp_filter = design(h, 'butter', 'MatchExactly', match, 'SystemObject', true);
    reorder(bp_filter, 'up'); % Reorder from less to most selective (poles close to 0 first)
end