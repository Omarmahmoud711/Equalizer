function gains = equalizerPresets(name)
%EQUALIZERPRESETS Return a 1x10 gain vector (dB) for a named preset.
%   Bands (Hz): 30, 60, 170, 310, 600, 1000, 3000, 6000, 10000, 20000

    switch lower(name)
        case 'flat'
            gains = zeros(1, 10);
        case 'party'
            gains = [ 6  6  3  0  0  2  4  4  6  4];
        case 'classical'
            gains = [ 4  4  4  4  0  0 -2 -2  0  0];
        case 'techno'
            gains = [ 6  6  4  0 -3 -3  0  4  6  6];
        case 'rock'
            gains = [ 5  4  3 -3 -5 -3  2  5  6  6];
        case 'reggae'
            gains = [ 0  0  0 -3 -3  0  4  4  0  0];
        case 'pop'
            gains = [-2 -1  0  2  4  4  2  0 -1 -2];
        otherwise
            error('equalizerPresets:UnknownPreset', ...
                'Unknown preset "%s".', name);
    end
end
