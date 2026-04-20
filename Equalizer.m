classdef Equalizer < matlab.apps.AppBase
    %EQUALIZER 10-band audio equalizer GUI (MATLAB App Designer).
    %   Loads a .wav/.mp3/.flac audio file, applies a 10-band FFT-based
    %   equalizer (30 Hz - 20 kHz), and plays the result. Presets and
    %   waveform + spectrogram display are included.
    %
    %   Usage:  Equalizer
    %
    %   Depends on (same folder):
    %       applyMultiBandEq.m, simpleSpectrogram.m, equalizerPresets.m

    properties (Access = public)
        UIFigure               matlab.ui.Figure
        FileControlsPanel      matlab.ui.container.Panel
        BrowseButton           matlab.ui.control.Button
        FilePathEditField      matlab.ui.control.EditField
        SaveButton             matlab.ui.control.Button
        AxesPanel              matlab.ui.container.Panel
        WaveformAxes           matlab.ui.control.UIAxes
        SpectrogramAxes        matlab.ui.control.UIAxes
        EqualizerPanel         matlab.ui.container.Panel
        PresetsPanel           matlab.ui.container.Panel
        FlatButton             matlab.ui.control.Button
        PartyButton            matlab.ui.control.Button
        ClassicalButton        matlab.ui.control.Button
        TechnoButton           matlab.ui.control.Button
        RockButton             matlab.ui.control.Button
        ReggaeButton           matlab.ui.control.Button
        PopButton              matlab.ui.control.Button
        EssentialsPanel        matlab.ui.container.Panel
        PlayButton             matlab.ui.control.Button
        PauseButton            matlab.ui.control.Button
        ResumeButton           matlab.ui.control.Button
        StopButton             matlab.ui.control.Button
        VolumeSlider           matlab.ui.control.Slider
        VolumeLabel            matlab.ui.control.Label
        StatusLabel            matlab.ui.control.Label
    end

    properties (Access = private)
        BandSliders            % 1x10 cell of uislider handles
        BandLabels             % 1x10 cell of uilabel  handles
        Player                 % audioplayer (or empty)
        Fs             double = 0
        OriginalAudio  double = []
        ProcessedAudio double = []
        BandCenters    double = [30 60 170 310 600 1000 3000 6000 10000 20000]
        BandLabelText  cell   = {'30 Hz','60 Hz','170 Hz','310 Hz','600 Hz', ...
                                 '1 kHz','3 kHz','6 kHz','10 kHz','20 kHz'}
    end

    % ------------------------------------------------------------------
    % Construction
    % ------------------------------------------------------------------
    methods (Access = public)
        function app = Equalizer()
            createComponents(app);
            registerApp(app, app.UIFigure);
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            stopPlayback(app);
            if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                delete(app.UIFigure);
            end
        end
    end

    % ------------------------------------------------------------------
    % Internal logic
    % ------------------------------------------------------------------
    methods (Access = private)

        function setStatus(app, msg)
            app.StatusLabel.Text = msg;
            drawnow limitrate;
        end

        function gains = getBandGains(app)
            gains = zeros(1, numel(app.BandSliders));
            for k = 1:numel(app.BandSliders)
                gains(k) = app.BandSliders{k}.Value;
            end
        end

        function setBandGains(app, gains)
            for k = 1:numel(app.BandSliders)
                app.BandSliders{k}.Value = gains(k);
            end
        end

        function stopPlayback(app)
            if ~isempty(app.Player) && isvalid(app.Player) && isplaying(app.Player)
                stop(app.Player);
            end
        end

        function updatePlots(app)
            if isempty(app.ProcessedAudio)
                return;
            end
            t = (0:size(app.ProcessedAudio, 1)-1) / app.Fs;
            cla(app.WaveformAxes);
            plot(app.WaveformAxes, t, app.ProcessedAudio);
            app.WaveformAxes.XLabel.String = 'Time (s)';
            app.WaveformAxes.YLabel.String = 'Amplitude';
            app.WaveformAxes.Title.String  = 'Waveform';
            axis(app.WaveformAxes, 'tight');

            [S, F, T] = simpleSpectrogram(app.ProcessedAudio, app.Fs, 1024, 512);
            cla(app.SpectrogramAxes);
            imagesc(app.SpectrogramAxes, T, F, 20*log10(S + eps));
            app.SpectrogramAxes.YDir = 'normal';
            app.SpectrogramAxes.XLabel.String = 'Time (s)';
            app.SpectrogramAxes.YLabel.String = 'Frequency (Hz)';
            app.SpectrogramAxes.Title.String  = 'Spectrogram (dB)';
            colormap(app.SpectrogramAxes, 'turbo');
        end

        function updateEqualization(app)
            if isempty(app.OriginalAudio)
                return;
            end
            gains = getBandGains(app);
            app.ProcessedAudio = applyMultiBandEq( ...
                app.OriginalAudio, app.Fs, gains, app.BandCenters);
            updatePlots(app);
            stopPlayback(app);
        end

        function startPlayback(app)
            if isempty(app.ProcessedAudio)
                setStatus(app, 'Load an audio file first.');
                return;
            end
            stopPlayback(app);
            vol = app.VolumeSlider.Value / 100;
            audio_out = app.ProcessedAudio * vol;
            peak = max(abs(audio_out(:)));
            if peak > 1
                audio_out = audio_out / peak;
            end
            app.Player = audioplayer(audio_out, app.Fs);
            play(app.Player);
            setStatus(app, 'Playing');
        end

        function applyPreset(app, name)
            gains = equalizerPresets(name);
            setBandGains(app, gains);
            updateEqualization(app);
            setStatus(app, sprintf('Preset: %s', name));
        end

        % -------- Button / slider callbacks --------

        function BrowseButtonPushed(app, ~)
            [filename, pathname] = uigetfile( ...
                {'*.wav;*.mp3;*.flac;*.ogg;*.m4a', 'Audio files'; ...
                 '*.*', 'All files'}, ...
                'Select audio file');
            if isequal(filename, 0)
                return;
            end
            full = fullfile(pathname, filename);
            try
                [audio, fs] = audioread(full);
            catch err
                setStatus(app, ['Error loading: ' err.message]);
                return;
            end
            app.OriginalAudio = audio;
            app.Fs = fs;
            app.FilePathEditField.Value = full;
            setStatus(app, sprintf('Loaded %s  (%.1f s, %d Hz, %d ch)', ...
                filename, size(audio,1)/fs, fs, size(audio,2)));
            updateEqualization(app);
        end

        function SaveButtonPushed(app, ~)
            if isempty(app.ProcessedAudio)
                setStatus(app, 'Nothing to save.');
                return;
            end
            [filename, pathname] = uiputfile({'*.wav','WAV audio'}, ...
                'Save equalized audio', 'equalized.wav');
            if isequal(filename, 0)
                return;
            end
            out = app.ProcessedAudio * (app.VolumeSlider.Value / 100);
            peak = max(abs(out(:)));
            if peak > 1
                out = out / peak;
            end
            audiowrite(fullfile(pathname, filename), out, app.Fs);
            setStatus(app, ['Saved: ' filename]);
        end

        function PlayButtonPushed(app, ~)
            startPlayback(app);
        end

        function PauseButtonPushed(app, ~)
            if ~isempty(app.Player) && isvalid(app.Player) && isplaying(app.Player)
                pause(app.Player);
                setStatus(app, 'Paused');
            end
        end

        function ResumeButtonPushed(app, ~)
            if ~isempty(app.Player) && isvalid(app.Player) && ~isplaying(app.Player)
                resume(app.Player);
                setStatus(app, 'Playing');
            end
        end

        function StopButtonPushed(app, ~)
            stopPlayback(app);
            setStatus(app, 'Stopped');
        end

        function VolumeSliderValueChanged(app, ~)
            stopPlayback(app);
            setStatus(app, sprintf('Volume: %d%% (press Play)', ...
                round(app.VolumeSlider.Value)));
        end

        function BandSliderValueChanged(app, ~)
            updateEqualization(app);
        end

        function FlatButtonPushed(app, ~),      applyPreset(app, 'Flat');      end
        function PartyButtonPushed(app, ~),     applyPreset(app, 'Party');     end
        function ClassicalButtonPushed(app, ~), applyPreset(app, 'Classical'); end
        function TechnoButtonPushed(app, ~),    applyPreset(app, 'Techno');    end
        function RockButtonPushed(app, ~),      applyPreset(app, 'Rock');      end
        function ReggaeButtonPushed(app, ~),    applyPreset(app, 'Reggae');    end
        function PopButtonPushed(app, ~),       applyPreset(app, 'Pop');       end

        % -------- UI construction --------

        function createComponents(app)
            % Figure
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1100 700];
            app.UIFigure.Name = 'Audio Equalizer';

            % ---- File controls (top strip) ----
            app.FileControlsPanel = uipanel(app.UIFigure, ...
                'Position', [10 655 1080 38]);

            app.BrowseButton = uibutton(app.FileControlsPanel, 'push', ...
                'Position', [10 7 100 24], 'Text', 'Browse...', ...
                'ButtonPushedFcn', createCallbackFcn(app, @BrowseButtonPushed, true));

            app.FilePathEditField = uieditfield(app.FileControlsPanel, 'text', ...
                'Position', [120 7 830 24], 'Editable', 'off', ...
                'Placeholder', 'No file loaded');

            app.SaveButton = uibutton(app.FileControlsPanel, 'push', ...
                'Position', [960 7 110 24], 'Text', 'Save...', ...
                'ButtonPushedFcn', createCallbackFcn(app, @SaveButtonPushed, true));

            % ---- Visualization (waveform + spectrogram) ----
            app.AxesPanel = uipanel(app.UIFigure, ...
                'Title', 'Visualization', 'Position', [10 410 1080 240]);

            app.WaveformAxes = uiaxes(app.AxesPanel, 'Position', [10 10 520 210]);
            title(app.WaveformAxes, 'Waveform');
            xlabel(app.WaveformAxes, 'Time (s)');
            ylabel(app.WaveformAxes, 'Amplitude');

            app.SpectrogramAxes = uiaxes(app.AxesPanel, 'Position', [540 10 530 210]);
            title(app.SpectrogramAxes, 'Spectrogram');
            xlabel(app.SpectrogramAxes, 'Time (s)');
            ylabel(app.SpectrogramAxes, 'Frequency (Hz)');

            % ---- Equalizer (10 vertical sliders) ----
            app.EqualizerPanel = uipanel(app.UIFigure, ...
                'Title', 'Equalizer', 'Position', [10 180 690 220]);

            app.BandSliders = cell(1, 10);
            app.BandLabels  = cell(1, 10);
            x_start = 15;
            x_gap   = 67;
            for k = 1:10
                x = x_start + (k-1)*x_gap;
                app.BandSliders{k} = uislider(app.EqualizerPanel, ...
                    'Orientation', 'vertical', ...
                    'Limits', [-20 20], ...
                    'Value', 0, ...
                    'MajorTicks', [-20 -10 0 10 20], ...
                    'Position', [x 25 3 140], ...
                    'ValueChangedFcn', createCallbackFcn(app, @BandSliderValueChanged, true));

                app.BandLabels{k} = uilabel(app.EqualizerPanel, ...
                    'Position', [x-22 175 50 18], ...
                    'Text', app.BandLabelText{k}, ...
                    'HorizontalAlignment', 'center', ...
                    'FontWeight', 'bold');
            end

            % ---- Presets (right of equalizer) ----
            app.PresetsPanel = uipanel(app.UIFigure, ...
                'Title', 'Presets', 'Position', [710 180 380 220]);

            btn_w = 100; btn_h = 28;
            row1_y = 150; row2_y = 110; row3_y = 70; row4_y = 30;
            col1_x = 20;  col2_x = 140; col3_x = 260;

            app.FlatButton = uibutton(app.PresetsPanel, 'push', ...
                'Position', [col1_x row1_y btn_w btn_h], 'Text', 'Flat', ...
                'ButtonPushedFcn', createCallbackFcn(app, @FlatButtonPushed, true));
            app.PartyButton = uibutton(app.PresetsPanel, 'push', ...
                'Position', [col2_x row1_y btn_w btn_h], 'Text', 'Party', ...
                'ButtonPushedFcn', createCallbackFcn(app, @PartyButtonPushed, true));
            app.ClassicalButton = uibutton(app.PresetsPanel, 'push', ...
                'Position', [col3_x row1_y btn_w btn_h], 'Text', 'Classical', ...
                'ButtonPushedFcn', createCallbackFcn(app, @ClassicalButtonPushed, true));

            app.TechnoButton = uibutton(app.PresetsPanel, 'push', ...
                'Position', [col1_x row2_y btn_w btn_h], 'Text', 'Techno', ...
                'ButtonPushedFcn', createCallbackFcn(app, @TechnoButtonPushed, true));
            app.RockButton = uibutton(app.PresetsPanel, 'push', ...
                'Position', [col2_x row2_y btn_w btn_h], 'Text', 'Rock', ...
                'ButtonPushedFcn', createCallbackFcn(app, @RockButtonPushed, true));
            app.ReggaeButton = uibutton(app.PresetsPanel, 'push', ...
                'Position', [col3_x row2_y btn_w btn_h], 'Text', 'Reggae', ...
                'ButtonPushedFcn', createCallbackFcn(app, @ReggaeButtonPushed, true));

            app.PopButton = uibutton(app.PresetsPanel, 'push', ...
                'Position', [col2_x row3_y btn_w btn_h], 'Text', 'Pop', ...
                'ButtonPushedFcn', createCallbackFcn(app, @PopButtonPushed, true));

            % ---- Essentials (play controls + volume + status) ----
            app.EssentialsPanel = uipanel(app.UIFigure, ...
                'Title', 'Playback', 'Position', [10 10 1080 160]);

            app.PlayButton = uibutton(app.EssentialsPanel, 'push', ...
                'Position', [20 90 120 30], 'Text', 'Play', ...
                'ButtonPushedFcn', createCallbackFcn(app, @PlayButtonPushed, true));
            app.PauseButton = uibutton(app.EssentialsPanel, 'push', ...
                'Position', [150 90 120 30], 'Text', 'Pause', ...
                'ButtonPushedFcn', createCallbackFcn(app, @PauseButtonPushed, true));
            app.ResumeButton = uibutton(app.EssentialsPanel, 'push', ...
                'Position', [280 90 120 30], 'Text', 'Resume', ...
                'ButtonPushedFcn', createCallbackFcn(app, @ResumeButtonPushed, true));
            app.StopButton = uibutton(app.EssentialsPanel, 'push', ...
                'Position', [410 90 120 30], 'Text', 'Stop', ...
                'ButtonPushedFcn', createCallbackFcn(app, @StopButtonPushed, true));

            app.VolumeLabel = uilabel(app.EssentialsPanel, ...
                'Position', [560 95 60 22], 'Text', 'Volume', 'FontWeight', 'bold');
            app.VolumeSlider = uislider(app.EssentialsPanel, ...
                'Limits', [0 100], 'Value', 80, ...
                'Position', [630 105 420 3], ...
                'ValueChangedFcn', createCallbackFcn(app, @VolumeSliderValueChanged, true));

            app.StatusLabel = uilabel(app.EssentialsPanel, ...
                'Position', [20 15 1040 22], ...
                'Text', 'Ready. Click Browse to load an audio file.', ...
                'FontAngle', 'italic');

            app.UIFigure.Visible = 'on';
        end
    end
end
