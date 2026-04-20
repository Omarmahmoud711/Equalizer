function [S, F, T] = simpleSpectrogram(x, Fs, win_len, overlap)
%SIMPLESPECTROGRAM Compute a magnitude spectrogram using only core MATLAB.
%   [S, F, T] = SIMPLESPECTROGRAM(x, Fs, win_len, overlap) returns the
%   magnitude short-time Fourier transform of x. Replaces the Signal
%   Processing Toolbox's spectrogram() so the app works on MATLAB Online
%   Basic.
%
%   S : (win_len/2+1) x nFrames magnitude matrix
%   F : frequency bin centers (Hz)
%   T : frame center times (s)

    if nargin < 3 || isempty(win_len), win_len = 1024; end
    if nargin < 4 || isempty(overlap), overlap = floor(win_len / 2); end

    if size(x, 2) > 1
        x = mean(x, 2);   % mix to mono for display
    end
    x = x(:);

    if length(x) < win_len
        pad = zeros(win_len - length(x), 1);
        x = [x; pad];
    end

    hop = win_len - overlap;
    n_frames = floor((length(x) - win_len) / hop) + 1;

    % Hann window (no Signal Processing Toolbox dependency)
    w = 0.5 - 0.5 * cos(2*pi*(0:win_len-1)'/(win_len-1));

    n_bins = win_len/2 + 1;
    S = zeros(n_bins, n_frames);

    for k = 1:n_frames
        idx = (k-1)*hop + (1:win_len);
        X = fft(x(idx) .* w);
        S(:, k) = abs(X(1:n_bins));
    end

    F = (0:win_len/2)' * (Fs / win_len);
    T = ((0:n_frames-1) * hop + win_len/2) / Fs;
end
