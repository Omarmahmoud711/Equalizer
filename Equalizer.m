classdef Equalizer < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        AxesPanel             matlab.ui.container.Panel
        UIAxes_2              matlab.ui.control.UIAxes
        UIAxes                matlab.ui.control.UIAxes
        EssentialsPanel       matlab.ui.container.Panel
        VolumeSlider          matlab.ui.control.Slider
        VolumeSliderLabel     matlab.ui.control.Label
        StopButton            matlab.ui.control.Button
        ResumeButton          matlab.ui.control.Button
        PauseButton           matlab.ui.control.Button
        PlayButton            matlab.ui.control.Button
        PresetsPanel          matlab.ui.container.Panel
        PartyButton           matlab.ui.control.Button
        ClassicalButton       matlab.ui.control.Button
        TechnoButton          matlab.ui.control.Button
        RockButton            matlab.ui.control.Button
        RaggaeButton          matlab.ui.control.Button
        PopButton             matlab.ui.control.Button
        Panel                 matlab.ui.container.Panel
        KHzSlider_7           matlab.ui.control.Slider
        KHzSlider_7Label      matlab.ui.control.Label
        KHzSlider_6           matlab.ui.control.Slider
        KHzSlider_6Label      matlab.ui.control.Label
        KHzSlider_5           matlab.ui.control.Slider
        KHzSlider_5Label      matlab.ui.control.Label
        KHzSlider_4           matlab.ui.control.Slider
        KHzSlider_4Label      matlab.ui.control.Label
        KHzSlider_3           matlab.ui.control.Slider
        KHzSlider_3Label      matlab.ui.control.Label
        KHzSlider_2           matlab.ui.control.Slider
        KHzSlider_2Label      matlab.ui.control.Label
        KHzSlider             matlab.ui.control.Slider
        KHzSliderLabel        matlab.ui.control.Label
        HzSlider_3            matlab.ui.control.Slider
        HzLabel_2             matlab.ui.control.Label
        HzSlider_2            matlab.ui.control.Slider
        HzLabel               matlab.ui.control.Label
        HzSlider              matlab.ui.control.Slider
        Label                 matlab.ui.control.Label
        EqualizerPanel        matlab.ui.container.Panel
        AddessEditField       matlab.ui.control.EditField
        AddessEditFieldLabel  matlab.ui.control.Label
        BrowseButton          matlab.ui.control.Button
    end

    properties (Access = private)
        Player               audioplayer
        Fs                   double
        OriginalAudio        double
    end
    
    methods (Access = public)
        % Constructor
        function app = Equalizer()
            app.Player = [];
            app.Fs = 0;
            app.OriginalAudio = [];
        end
        
        % Play the audio
        function play_audio(app, audio)
            if ~isempty(app.Player) && isplaying(app.Player)
                stop(app.Player);
            end
            
            app.Player = audioplayer(audio, app.Fs);
            play(app.Player);
        end
        
        % Load and process the audio
        function load_and_process_audio(app)
            [filename, pathname] = uigetfile('.wav', 'Select a file');

            % Check if a file was selected
            if isequal(filename, 0)
                % No file selected
                return;
            end

            % Read the audio file
            [app.OriginalAudio, app.Fs] = audioread(fullfile(pathname, filename));
            
            % Apply initial processing
            processed_audio = app.OriginalAudio;  % Perform any initial processing here

            % Display the waveform
            plot(app.UIAxes, processed_audio);
            app.UIAxes.XLabel.String = 'Time';
            app.UIAxes.YLabel.String = 'Amplitude';
            app.UIAxes.Title.String = 'Waveform';
            
            % Display the spectrogram
            spectrogram(app.UIAxes_2, processed_audio, 'yaxis');
            app.UIAxes_2.Title.String = 'Spectrogram';
        end
        
        % Apply equalization
        function apply_equalization(app, audio)
            % Apply equalization based on the slider values
            % Retrieve slider values
            gain_1 = app.HzSlider.Value;
            gain_2 = app.HzSlider_2.Value;
            gain_3 = app.HzSlider_3.Value;
            gain_4 = app.KHzSlider.Value;
            gain_5 = app.KHzSlider_2.Value;
            gain_6 = app.KHzSlider_3.Value;
            gain_7 = app.KHzSlider_4.Value;
            
            % Define filter center frequencies
            freqs = [60 170 310 600 1000 3000 6000];

            % Create an equalizer filter
            b = fir1(200, freqs/(app.Fs/2), 'DC-0');

            % Apply equalization
            processed_audio = filter(b, 1, audio);

            % Apply gain adjustment
            gains = 10.^(gain_1/20);
            gains = [gains 10.^(gain_2/20) 10.^(gain_3/20) 10.^(gain_4/20) 10.^(gain_5/20) 10.^(gain_6/20) 10.^(gain_7/20)];
            processed_audio = processed_audio .* gains;
            
            % Normalize the audio
            processed_audio = processed_audio ./ max(abs(processed_audio));
            
            % Update the audio player and plots
            app.play_audio(processed_audio);
            plot(app.UIAxes, processed_audio);
            spectrogram(app.UIAxes_2, processed_audio, 'yaxis');
        end
    end

    % App creation and deletion
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)
            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 761 481];
            app.UIFigure.Name = 'UI Figure';

            % Create AxesPanel
            app.AxesPanel = uipanel(app.UIFigure);
            app.AxesPanel.Position = [31 166 701 296];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.AxesPanel);
            title(app.UIAxes_2, 'Spectrogram')
            app.UIAxes_2.FontSize = 11;
            app.UIAxes_2.Position = [370 9 318 266];

            % Create UIAxes
            app.UIAxes = uiaxes(app.AxesPanel);
            title(app.UIAxes, 'Waveform')
            app.UIAxes.FontSize = 11;
            app.UIAxes.Position = [8 9 340 266];

            % Create EssentialsPanel
            app.EssentialsPanel = uipanel(app.UIFigure);
            app.EssentialsPanel.Title = 'Essentials';
            app.EssentialsPanel.Position = [31 15 331 139];

            % Create VolumeSlider
            app.VolumeSlider = uislider(app.EssentialsPanel);
            app.VolumeSlider.Limits = [0 100];
            app.VolumeSlider.ValueChangedFcn = createCallbackFcn(app, @VolumeSliderValueChanged, true);
            app.VolumeSlider.Position = [76 69 175 3];

            % Create VolumeSliderLabel
            app.VolumeSliderLabel = uilabel(app.EssentialsPanel);
            app.VolumeSliderLabel.HorizontalAlignment = 'right';
            app.VolumeSliderLabel.Position = [10 65 54 22];
            app.VolumeSliderLabel.Text = 'Volume';

            % Create StopButton
            app.StopButton = uibutton(app.EssentialsPanel, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Position = [227 34 100 22];
            app.StopButton.Text = 'Stop';

            % Create ResumeButton
            app.ResumeButton = uibutton(app.EssentialsPanel, 'push');
            app.ResumeButton.ButtonPushedFcn = createCallbackFcn(app, @ResumeButtonPushed, true);
            app.ResumeButton.Position = [121 34 100 22];
            app.ResumeButton.Text = 'Resume';

            % Create PauseButton
            app.PauseButton = uibutton(app.EssentialsPanel, 'push');
            app.PauseButton.ButtonPushedFcn = createCallbackFcn(app, @PauseButtonPushed, true);
            app.PauseButton.Position = [227 5 100 22];
            app.PauseButton.Text = 'Pause';

            % Create PlayButton
            app.PlayButton = uibutton(app.EssentialsPanel, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.Position = [121 5 100 22];
            app.PlayButton.Text = 'Play';

            % Create PresetsPanel
            app.PresetsPanel = uipanel(app.UIFigure);
            app.PresetsPanel.Title = 'Presets';
            app.PresetsPanel.Position = [408 15 324 139];

            % Create PartyButton
            app.PartyButton = uibutton(app.PresetsPanel, 'push');
            app.PartyButton.ButtonPushedFcn = createCallbackFcn(app, @PartyButtonPushed, true);
            app.PartyButton.Position = [27 77 100 22];
            app.PartyButton.Text = 'Party';

            % Create ClassicalButton
            app.ClassicalButton = uibutton(app.PresetsPanel, 'push');
            app.ClassicalButton.ButtonPushedFcn = createCallbackFcn(app, @ClassicalButtonPushed, true);
            app.ClassicalButton.Position = [27 48 100 22];
            app.ClassicalButton.Text = 'Classical';

            % Create TechnoButton
            app.TechnoButton = uibutton(app.PresetsPanel, 'push');
            app.TechnoButton.ButtonPushedFcn = createCallbackFcn(app, @TechnoButtonPushed, true);
            app.TechnoButton.Position = [27 19 100 22];
            app.TechnoButton.Text = 'Techno';

            % Create RockButton
            app.RockButton = uibutton(app.PresetsPanel, 'push');
            app.RockButton.ButtonPushedFcn = createCallbackFcn(app, @RockButtonPushed, true);
            app.RockButton.Position = [183 77 100 22];
            app.RockButton.Text = 'Rock';

            % Create RaggaeButton
            app.RaggaeButton = uibutton(app.PresetsPanel, 'push');
            app.RaggaeButton.ButtonPushedFcn = createCallbackFcn(app, @RaggaeButtonPushed, true);
            app.RaggaeButton.Position = [183 48 100 22];
            app.RaggaeButton.Text = 'Raggae';

            % Create PopButton
            app.PopButton = uibutton(app.PresetsPanel, 'push');
            app.PopButton.ButtonPushedFcn = createCallbackFcn(app, @PopButtonPushed, true);
            app.PopButton.Position = [183 19 100 22];
            app.PopButton.Text = 'Pop';

            % Create Panel
            app.Panel = uipanel(app.UIFigure);
            app.Panel.Title = 'Equalizer';
            app.Panel.Position = [31 178 331 284];

            % Create KHzSlider_7
            app.KHzSlider_7 = uislider(app.Panel);
            app.KHzSlider_7.Limits = [-20 20];
            app.KHzSlider_7.ValueChangedFcn = createCallbackFcn(app, @KHzSlider_7ValueChanged, true);
            app.KHzSlider_7.Position = [251 48 3 231];

            % Create KHzSlider_7Label
            app.KHzSlider_7Label = uilabel(app.Panel);
            app.KHzSlider_7Label.HorizontalAlignment = 'right';
            app.KHzSlider_7Label.Position = [227 236 25 22];
            app.KHzSlider_7Label.Text = '20 KHz';

            % Create KHzSlider_6
            app.KHzSlider_6 = uislider(app.Panel);
            app.KHzSlider_6.Limits = [-20 20];
            app.KHzSlider_6.ValueChangedFcn = createCallbackFcn(app, @KHzSlider_6ValueChanged, true);
            app.KHzSlider_6.Position = [199 48 3 231];

            % Create KHzSlider_6Label
            app.KHzSlider_6Label = uilabel(app.Panel);
            app.KHzSlider_6Label.HorizontalAlignment = 'right';
            app.KHzSlider_6Label.Position = [175 236 25 22];
            app.KHzSlider_6Label.Text = '10 KHz';

            % Create KHzSlider_5
            app.KHzSlider_5 = uislider(app.Panel);
            app.KHzSlider_5.Limits = [-20 20];
            app.KHzSlider_5.ValueChangedFcn = createCallbackFcn(app, @KHzSlider_5ValueChanged, true);
            app.KHzSlider_5.Position = [147 48 3 231];

            % Create KHzSlider_5Label
            app.KHzSlider_5Label = uilabel(app.Panel);
            app.KHzSlider_5Label.HorizontalAlignment = 'right';
            app.KHzSlider_5Label.Position = [123 236 25 22];
            app.KHzSlider_5Label.Text = '6 KHz';

            % Create KHzSlider_4
            app.KHzSlider_4 = uislider(app.Panel);
            app.KHzSlider_4.Limits = [-20 20];
            app.KHzSlider_4.ValueChangedFcn = createCallbackFcn(app, @KHzSlider_4ValueChanged, true);
            app.KHzSlider_4.Position = [95 48 3 231];

            % Create KHzSlider_4Label
            app.KHzSlider_4Label = uilabel(app.Panel);
            app.KHzSlider_4Label.HorizontalAlignment = 'right';
            app.KHzSlider_4Label.Position = [71 236 25 22];
            app.KHzSlider_4Label.Text = '3 KHz';

            % Create KHzSlider_3
            app.KHzSlider_3 = uislider(app.Panel);
            app.KHzSlider_3.Limits = [-20 20];
            app.KHzSlider_3.ValueChangedFcn = createCallbackFcn(app, @KHzSlider_3ValueChanged, true);
            app.KHzSlider_3.Position = [43 48 3 231];

            % Create KHzSlider_3Label
            app.KHzSlider_3Label = uilabel(app.Panel);
            app.KHzSlider_3Label.HorizontalAlignment = 'right';
            app.KHzSlider_3Label.Position = [19 236 25 22];
            app.KHzSlider_3Label.Text = '1 KHz';

            % Create KHzSlider_2
            app.KHzSlider_2 = uislider(app.Panel);
            app.KHzSlider_2.Limits = [-20 20];
            app.KHzSlider_2.ValueChangedFcn = createCallbackFcn(app, @KHzSlider_2ValueChanged, true);
            app.KHzSlider_2.Position = [251 19 3 231];

            % Create KHzSlider_2Label
            app.KHzSlider_2Label = uilabel(app.Panel);
            app.KHzSlider_2Label.HorizontalAlignment = 'right';
            app.KHzSlider_2Label.Position = [227 206 25 22];
            app.KHzSlider_2Label.Text = '600 Hz';

            % Create KHzSlider
            app.KHzSlider = uislider(app.Panel);
            app.KHzSlider.Limits = [-20 20];
            app.KHzSlider.ValueChangedFcn = createCallbackFcn(app, @KHzSliderValueChanged, true);
            app.KHzSlider.Position = [199 19 3 231];

            % Create KHzSliderLabel
            app.KHzSliderLabel = uilabel(app.Panel);
            app.KHzSliderLabel.HorizontalAlignment = 'right';
            app.KHzSliderLabel.Position = [175 206 25 22];
            app.KHzSliderLabel.Text = '310 Hz';

            % Create HzSlider_3
            app.HzSlider_3 = uislider(app.Panel);
            app.HzSlider_3.Limits = [-20 20];
            app.HzSlider_3.ValueChangedFcn = createCallbackFcn(app, @HzSlider_3ValueChanged, true);
            app.HzSlider_3.Position = [147 19 3 231];

            % Create HzLabel_2
            app.HzLabel_2 = uilabel(app.Panel);
            app.HzLabel_2.HorizontalAlignment = 'right';
            app.HzLabel_2.Position = [123 206 25 22];
            app.HzLabel_2.Text = '170 Hz';

            % Create HzSlider_2
            app.HzSlider_2 = uislider(app.Panel);
            app.HzSlider_2.Limits = [-20 20];
            app.HzSlider_2.ValueChangedFcn = createCallbackFcn(app, @HzSlider_2ValueChanged, true);
            app.HzSlider_2.Position = [95 19 3 231];

            % Create HzLabel
            app.HzLabel = uilabel(app.Panel);
            app.HzLabel.HorizontalAlignment = 'right';
            app.HzLabel.Position = [71 206 25 22];
            app.HzLabel.Text = '60 Hz';

            % Create HzSlider
            app.HzSlider = uislider(app.Panel);
            app.HzSlider.Limits = [-20 20];
            app.HzSlider.ValueChangedFcn = createCallbackFcn(app, @HzSliderValueChanged, true);
            app.HzSlider.Position = [43 19 3 231];

            % Create Label
            app.Label = uilabel(app.Panel);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [19 206 25 22];
            app.Label.Text = '30 Hz';

            % Create LoadButton
            app.LoadButton = uibutton(app.UIFigure, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.Position = [422 158 100 22];
            app.LoadButton.Text = 'Load';

            % Create SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [550 158 100 22];
            app.SaveButton.Text = 'Save';

            % Create EqualizerLabel
            app.EqualizerLabel = uilabel(app.UIFigure);
            app.EqualizerLabel.FontSize = 14;
            app.EqualizerLabel.FontWeight = 'bold';
            app.EqualizerLabel.Position = [193 452 77 22];
            app.EqualizerLabel.Text = 'Equalizer';

            % Create AudioPlayerLabel
            app.AudioPlayerLabel = uilabel(app.UIFigure);
            app.AudioPlayerLabel.FontSize = 14;
            app.AudioPlayerLabel.FontWeight = 'bold';
            app.AudioPlayerLabel.Position = [573 452 88 22];
            app.AudioPlayerLabel.Text = 'Audio Player';
        end
    end

    methods (Access = public)

        % Construct app
        function app = AudioEqualizerApp
            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
