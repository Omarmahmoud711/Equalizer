function y = applyMultiBandEq(x, Fs, gains_dB, centers_Hz)
%APPLYMULTIBANDEQ Apply a multi-band graphic equalizer to an audio signal.
%   y = APPLYMULTIBANDEQ(x, Fs, gains_dB, centers_Hz) shapes the signal x
%   (Nx1 mono or Nx2 stereo, sample rate Fs) by multiplying its FFT by a
%   gain curve that passes through the (centers_Hz, gains_dB) control
%   points. Interpolation is linear on log-frequency. Gains are held at
%   the endpoints for bins below the first and above the last center.
%
%   Uses only core MATLAB (no Signal Processing / Audio toolboxes).

    if isempty(x)
        y = x;
        return;
    end

    % Accept row or column; make column-major
    if isrow(x)
        x = x(:);
    end
    [N, nchan] = size(x);

    nyq = Fs / 2;
    valid = centers_Hz > 0 & centers_Hz < nyq;
    c = centers_Hz(valid);
    g = gains_dB(valid);

    if isempty(c) || all(g == 0)
        y = x;
        return;
    end

    % Fold FFT bin frequencies into [0, Nyquist] so the gain curve is
    % symmetric (guarantees a real-valued ifft output).
    bin_freqs = (0:N-1)' * (Fs / N);
    above = bin_freqs > nyq;
    bin_freqs(above) = Fs - bin_freqs(above);

    log_f = log10(max(bin_freqs, 1));     % avoid log10(0) at DC
    log_c = log10(c(:));
    g_col = g(:);

    gain_curve_dB = interp1(log_c, g_col, log_f, 'linear');
    % Hold at endpoints (interp1 returns NaN outside the range by default)
    gain_curve_dB(log_f < log_c(1))   = g_col(1);
    gain_curve_dB(log_f > log_c(end)) = g_col(end);
    gain_curve_dB(isnan(gain_curve_dB)) = 0;

    gain_linear = 10.^(gain_curve_dB / 20);

    y = zeros(size(x));
    for ch = 1:nchan
        X = fft(x(:, ch));
        y(:, ch) = real(ifft(X .* gain_linear));
    end

    % Prevent digital clipping from boosted bands
    peak = max(abs(y(:)));
    if peak > 1
        y = y / peak;
    end
end
