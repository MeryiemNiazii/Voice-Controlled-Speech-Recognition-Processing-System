downloadFile = matlab.internal.examples.downloadSupportFile("audio","wav2vec2/wav2vec2-base-960.zip");
wav2vecLocation = fullfile("D:\University\SEMESTER 4\S&S LAB\Project","wav2vec");
unzip(downloadFile,wav2vecLocation)
addpath(wav2vecLocation)

close all
clc

% Declare global variables
global recorder inputAxes outputAxes isRecordingDone processedAudio audioData mainFig recordingLabel durationSpinner

% Create the main figure
mainFig = uifigure('Name', 'Speech Recognition System 🎙🔊', 'Position', [100 100 1000 600]);

% Create panels for each graph
inputPanel = uipanel(mainFig, 'Position', [50 400 750 200], 'Title', 'Initial Voice');
outputPanel = uipanel(mainFig, 'Position', [50 150 750 200], 'Title', 'Transformed Voice');

% Create axes within the panels
inputAxes = uiaxes(inputPanel, 'Position', [10 50 700 130]);
outputAxes = uiaxes(outputPanel, 'Position', [10 50 700 130]);

% Create sliders for line width and color within the panels
inputLineWidthSlider = uislider(inputPanel, 'Position', [720 100 20 80], 'Limits', [0.5 5]);
inputLineColorDropdown = uidropdown(inputPanel, 'Position', [720 50 100 22], 'Items', {'b', 'r', 'g', 'k', 'y'});

outputLineWidthSlider = uislider(outputPanel, 'Position', [720 100 20 80], 'Limits', [0.5 5]);
outputLineColorDropdown = uidropdown(outputPanel, 'Position', [720 50 100 22], 'Items', {'b', 'r', 'g', 'k', 'y'});

% Create a button to apply changes within the panels
inputApplyButton = uibutton(inputPanel, 'Position', [720 10 100 22], 'Text', 'Apply Changes');
outputApplyButton = uibutton(outputPanel, 'Position', [720 10 100 22], 'Text', 'Apply Changes');

% Set the button callbacks to the applyChanges function
inputApplyButton.ButtonPushedFcn = @(btn, event) applyChanges(inputAxes, inputLineWidthSlider, inputLineColorDropdown, getappdata(mainFig, 'audioData'));
outputApplyButton.ButtonPushedFcn = @(btn, event) applyChanges(outputAxes, outputLineWidthSlider, outputLineColorDropdown, getappdata(mainFig, 'processedAudio'));

% Create a button to replay the recorded audio within the panels
inputReplayButton = uibutton(inputPanel, 'Position', [10 10 100 30], 'Text', 'Replay');
outputReplayButton = uibutton(outputPanel, 'Position', [10 10 100 30], 'Text', 'Replay');

% Set the button callbacks to the replay functions
inputReplayButton.ButtonPushedFcn = @(btn, event) replayAudio('input');
outputReplayButton.ButtonPushedFcn = @(btn, event) replayAudio('output');

% Create buttons
recordButton = uibutton(mainFig, 'Position', [50 50 100 30], 'Text', 'Record');
highPitchButton = uibutton(mainFig, 'Position', [200 50 100 30], 'Text', 'High Pitch');
lowPitchButton = uibutton(mainFig, 'Position', [350 50 100 30], 'Text', 'Low Pitch');
echoButton = uibutton(mainFig, 'Position', [500 50 100 30], 'Text', 'Echo');

% Create a label to indicate recording status
recordingLabel = uilabel(mainFig, 'Position', [50 90 300 30], 'Text', '', 'FontSize', 14, 'FontColor', 'red');

% Create a spinner to set the recording duration
durationSpinner = uispinner(mainFig, 'Position', [715 50 100 30], 'Limits', [1 10], 'Value', 3, 'Step', 1);

% Calculate the center of the figure
centerFig = mainFig.Position(3) / 2;

% Adjust the position of each button
recordButton.Position(1) = centerFig - 2 * recordButton.Position(3);
highPitchButton.Position(1) = centerFig - highPitchButton.Position(3);
lowPitchButton.Position(1) = centerFig;
echoButton.Position(1) = centerFig + echoButton.Position(3);

% Add button callbacks
recordButton.ButtonPushedFcn = @(btn, event) recordAudio();
highPitchButton.ButtonPushedFcn = @(btn, event) processAudio('low');
lowPitchButton.ButtonPushedFcn = @(btn, event) processAudio('high');
echoButton.ButtonPushedFcn = @(btn, event) processAudio('echo');

% Add a label at the bottom
label = uilabel(mainFig, 'Position', [50 10 700 30], 'Text', 'By Asad Mehmood BCPE223053 and Mahroona Mariam BCPE223021');
label.HorizontalAlignment = 'center'; % Align the label to the center

% Set initial positions and sizes
resizeComponents(mainFig, inputPanel, outputPanel, inputAxes, outputAxes, inputLineWidthSlider, inputLineColorDropdown, outputLineWidthSlider, outputLineColorDropdown, inputApplyButton, outputApplyButton, recordButton, highPitchButton, lowPitchButton, echoButton, durationSpinner, label);

% Nested resizeComponents function
function resizeComponents(mainFig, inputPanel, outputPanel, inputAxes, outputAxes, inputLineWidthSlider, inputLineColorDropdown, outputLineWidthSlider, outputLineColorDropdown, inputApplyButton, outputApplyButton, recordButton, highPitchButton, lowPitchButton, echoButton, durationSpinner, label)
    % Get the current figure size
    figPos = mainFig.Position;
    figWidth = figPos(3);
    figHeight = figPos(4);

    % Set the panel positions
    panelWidth = figWidth - 100; % Leave 50 pixels margin on each side
    panelHeight = 200;
    inputPanel.Position = [50 figHeight - 250 panelWidth panelHeight];
    outputPanel.Position = [50 figHeight - 450 panelWidth panelHeight];

    % Set the axes positions
    axesWidth = panelWidth - 120; % Leave space for sliders and dropdowns
    axesHeight = 130;
    inputAxes.Position = [10 50 axesWidth axesHeight];
    outputAxes.Position = [10 50 axesWidth axesHeight];

    % Set the sliders and dropdowns positions
    inputLineWidthSlider.Position = [axesWidth + 20 100 20 80];
    inputLineColorDropdown.Position = [axesWidth + 20 50 100 22];

    outputLineWidthSlider.Position = [axesWidth + 20 100 20 80];
    outputLineColorDropdown.Position = [axesWidth + 20 50 100 22];

    % Set the apply buttons positions
    inputApplyButton.Position = [axesWidth + 20 10 100 22];
    outputApplyButton.Position = [axesWidth + 20 10 100 22];

    % Set the control buttons positions
    centerFig = figWidth / 2;
    buttonWidth = 100;
    buttonHeight = 30;
    recordButton.Position = [centerFig - 2 * buttonWidth - 10 50 buttonWidth buttonHeight];
    highPitchButton.Position = [centerFig - buttonWidth - 5 50 buttonWidth buttonHeight];
    lowPitchButton.Position = [centerFig + 5 50 buttonWidth buttonHeight];
    echoButton.Position = [centerFig + buttonWidth + 10 50 buttonWidth buttonHeight];

    % Set the spinner position
    durationSpinner.Position = [centerFig + 2 * buttonWidth + 20 50 buttonWidth buttonHeight];

    % Set the recording label position
    recordingLabel.Position = [centerFig - 2 * buttonWidth - 10 90 300 30];
    
    % % Set the label position
    % label.Position = [50 10 panelWidth 30];
     % Set the label position to bottom center
    label.Position = [figWidth/2 - panelWidth/2, 10, panelWidth, 30];
end

function applyChanges(axes, slider, dropdown, audioData)
    % Get the current values from the slider and dropdown
    lineWidth = slider.Value;
    lineColor = dropdown.Value;

    % Plot the audio data on the specified axes
    plot(axes, audioData, 'LineWidth', lineWidth, 'Color', lineColor);
end

function recordAudio()
    % Declare global variables
    global recorder inputAxes isRecordingDone mainFig audioData recordingLabel durationSpinner a j

    % Create an audiorecorder object
    recorder = audiorecorder(16000, 16, 1);

    % Record audio for a specific duration
    duration = durationSpinner.Value;
    disp('Start speaking.')
    recordingLabel.Text = 'Recording...';
    recordblocking(recorder, duration);
    disp('End of Recording.')
    % Update the recording label to indicate recording has stopped
    recordingLabel.Text = 'Recording stopped.';
    % Get the audio data
    audioData = getaudiodata(recorder);

    % Save as a .wav file
    audiowrite('myRecording.wav', audioData, 16000);
    [a, j] = audioread('myRecording.wav');
    audioDuration = numel(a) / j;
    fprintf('Audio duration: %.2f seconds\n', audioDuration);


    isRecordingDone = true;

    % Transcribe the audio file
    transcriber = speechClient("wav2vec2.0");
    transcript = transcriber.transcribe(audioData, 16000);

    A = table2cell(transcript(:, 1));
    run_application(A);


    % Plot the audio data
    plot(inputAxes, audioData);
    setappdata(mainFig, 'audioData', audioData);
    sound(audioData, 16000);
end

function run_application(S)
    global isRecordingDone
    if isRecordingDone == true
        for i = 1:length(S)
            open_application(S{i});
        end
    end
end


function processAudio(type)
    % Declare global variables
    global audioData processedAudio outputAxes mainFig

    if isempty(audioData)
        disp('No audio data found. Please record audio first.');
        return;
    end

    % Process the audio based on the type
    switch type
        case 'high'
            processedAudio = increase_pitch(audioData, 16000);

            % Save the high pitch audio as a .wav file
            audiowrite('myRecording_high.wav', processedAudio, 16000);
            sound(processedAudio, 16000);

        case 'low'
            processedAudio = decrease_pitch(audioData, 16000);

            % Save the low pitch audio as a .wav file
            audiowrite('myRecording_low.wav', processedAudio, 16000);
            sound(processedAudio, 16000);

        case 'echo'
            processedAudio = add_echo_conv(audioData, 16000);

            % Save the echo audio as a .wav file
            audiowrite('myRecording_echo.wav', processedAudio, 16000);
            sound(processedAudio, 16000);
    end

    % Plot the processed audio data
    plot(outputAxes, processedAudio);
    setappdata(mainFig, 'processedAudio', processedAudio);
end

function replayAudio(type)
    % Declare global variables
    global audioData processedAudio

    switch type
        case 'input'
            if isempty(audioData)
                disp('No recorded audio to play.');
            else
                sound(audioData, 16000);
            end
        case 'output'
            if isempty(processedAudio)
                disp('No processed audio to play.');
            else
                sound(processedAudio, 16000);
            end
    end
end
function y = increase_pitch(x, fs)
    % Increase the pitch of the audio signal
    [P, Q] = rat(2^(8/12)); % Increase pitch by one semitone
    y = resample(x, P, Q);
    y = y / max(abs(y)); % Normalize the amplitude
end

function y = decrease_pitch(x, fs)
    % Decrease the pitch of the audio signal
    [P, Q] = rat(2^(-8/12)); % Decrease pitch by one semitone
    y = resample(x, P, Q);
    y = y / max(abs(y)); % Normalize the amplitude
end

function y = add_echo_conv(x, fs)
    % Create an echo effect on the audio signal using convolution
    delayInSeconds = 0.5; % Delay in seconds
    attenuation = 0.6; % Attenuation factor
    delayInSamples = round(fs * delayInSeconds); % Delay in samples

    % Create the impulse response
    impulseResponse = [1; zeros(delayInSamples - 1, 1); attenuation];

    % Convolve the original signal with the impulse response
    y = conv(x, impulseResponse);

    % Normalize the amplitude
    y = y / max(abs(y));
end

function open_application(app_name)
    if strcmpi(app_name, 'word')
        system('start winword');
    elseif strcmpi(app_name, 'excel')
        system('start excel');
    elseif strcmpi(app_name, 'powerpoint')
        system('start powerpnt');
    elseif strcmpi(app_name, 'notepad')
        system('start notepad');
    elseif strcmpi(app_name, 'calculator')
        system('start calc');
    elseif strcmpi(app_name, 'paint')
        system('start mspaint');
    elseif strcmpi(app_name, 'chrome')
        system('start chrome');
    elseif strcmpi(app_name, 'firefox')
        system('start firefox');
    elseif strcmpi(app_name, 'cmd')
        system('start cmd');
    elseif strcmpi(app_name, 'explorer')
        system('start explorer');
    else
        disp(['Application ', app_name, ' not recognized. Please enter a recognized application name.']);
    end
end
