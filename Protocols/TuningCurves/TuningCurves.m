
function TuningCurves
% This protocol is used to estimate tuning curves in auditory areas
% Written by F.Carnevale, 4/2015.

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with settings default
    
    S.GUI.SoundType = 1;
    S.GUIMeta.SoundType.Style = 'popupmenu';
    S.GUIMeta.SoundType.String = {'Tone', 'Chord','FM','Noise','FastBips'};
    
    S.GUI.LowFreq = 4000; % Lowest frequency
    S.GUI.HighFreq = 40000; % Highest frequency
    S.GUI.nFreq = 20; % Number of frequencies    

    S.GUI.SoundVolumeMin = 55; % Sound Volume    
    S.GUI.SoundVolumeMax = 55; % Sound Volume
    S.GUI.nVolumes = 1; % Number of sound volumes
    
    S.GUIPanels.SoundSettings = {'SoundType', 'LowFreq', 'HighFreq', 'nFreq', 'SoundVolumeMin', 'SoundVolumeMax', 'nVolumes'};
    
    S.GUI.InterTrial = 0.5; % Intertrial Interval
    S.GUI.PreSoundMin = 0.5; % PreSound Interval
    S.GUI.PreSoundWidth = 0.25; % PreSound Interval
    S.GUI.SoundDuration = 0.25; % Sound Duration
    S.GUI.nSounds = 20;
    
    S.GUIPanels.TimingSettings = {'InterTrial', 'PreSoundMin', 'PreSoundWidth', 'SoundDuration', 'nSounds'};
        
    S.GUI.SoundFreq = 0; % Sound Frequency
    S.GUIMeta.SoundFreq.Style = 'text';
    
    S.GUI.SoundVolume = 0; % Sound Volume
    S.GUIMeta.SoundVolume.Style = 'text';
    
    S.GUI.TrialNumber = 0; % Number of current trial
    S.GUIMeta.TrialNumber.Style = 'text';

    S.GUIPanels.CurrentTrial = {'SoundFreq', 'SoundVolume', 'TrialNumber'};
    
    S.GUI.BregmaAP = 0; %
    S.GUI.BregmaDM = 0; %
    S.GUI.SurfaceDepth = 0; %
    
    S.GUI.ElectrodeAP = 0; %
    S.GUI.ElectrodeDM = 0; %
    S.GUI.ElectrodeDepth = 0; %

    S.GUIPanels.Coordinates = {'BregmaAP', 'BregmaDM', 'SurfaceDepth','ElectrodeAP', 'ElectrodeDM', 'ElectrodeDepth'};
        
    % Other Stimulus settings (not in the GUI)
    StimulusSettings.SamplingRate = 192000; % Sound card sampling rate;
    StimulusSettings.Ramp = 0.005; 
    
end

% Initialize parameter GUI plugin
BpodParameterGUI('init', S);

BpodSystem.Data.TrialFreq = []; % The trial frequency of each trial completed will be added here.

% Program sound server
PsychToolboxSoundServer('init')

% Set soft code handler to trigger sounds
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

BpodSystem.ProtocolFigures.InitialMsg = msgbox({'', ' Edit your settings and click OK when you are ready to start!     ', ''},'Tuning Curves Protocol...');
uiwait(BpodSystem.ProtocolFigures.InitialMsg);

S = BpodParameterGUI('sync', S); % Sync parameters with EnhancedBpodParameterGUI plugin

%% Define trials
PossibleFreqs = logspace(log10(S.GUI.LowFreq),log10(S.GUI.HighFreq),S.GUI.nFreq);
PossibleVolumes = linspace(S.GUI.SoundVolumeMin,S.GUI.SoundVolumeMax,S.GUI.nVolumes);

MaxTrials = size(PossibleFreqs,2)*S.GUI.nSounds;

TrialFreq = PossibleFreqs(randi(size(PossibleFreqs,2),1,MaxTrials));
TrialVol = PossibleVolumes(randi(size(PossibleVolumes,2),1,MaxTrials));

PreSound = nan(1,MaxTrials); % PreSound interval for each trial
InterTrial = nan(1,MaxTrials); % Intertrial interval for each trial
SoundDuration = nan(1,MaxTrials); % Sound duration for each trial

S.GUI.SoundFreq = round(TrialFreq(1)); % Sound Freq
S.GUI.SoundVolume = round(TrialVol(1)); % Sound Freq
S.GUI.TrialNumber = [num2str(1) '/' num2str(MaxTrials)]; % Number of current trial

%% Main trial loop
for currentTrial = 1:MaxTrials
    
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    
    InterTrial(currentTrial) = S.GUI.InterTrial;
    PreSound(currentTrial) = S.GUI.PreSoundMin+S.GUI.PreSoundWidth*rand;
    SoundDuration(currentTrial) = S.GUI.SoundDuration;

    % Update stimulus settings    
    StimulusSettings.SoundVolume = TrialVol(currentTrial);
    StimulusSettings.SoundDuration = S.GUI.SoundDuration;
    StimulusSettings.Freq = TrialFreq(currentTrial);
    StimulusSettings.Ramp = StimulusSettings.Ramp;
    
    % This stage sound generation
    Sound = GenerateSound(StimulusSettings);
    PsychToolboxSoundServer('Load', 1, Sound);
    
    sma = NewStateMatrix(); % Assemble state matrix
    
    sma = AddState(sma, 'Name', 'PreSound', ...
        'Timer', PreSound(currentTrial),...
        'StateChangeConditions', {'Tup', 'TrigStart'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'TrigStart', ...
        'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'DeliverStimulus'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'DeliverStimulus', ...
        'Timer', SoundDuration(currentTrial),...
        'StateChangeConditions', {'Tup', 'InterTrial'},...
        'OutputActions', {'SoftCode', 1, 'BNCState', 1});
    sma = AddState(sma, 'Name', 'InterTrial', ...
        'Timer', InterTrial(currentTrial),...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
    
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.TrialFreq(currentTrial) = TrialFreq(currentTrial);
        BpodSystem.Data.TrialVol(currentTrial) = TrialVol(currentTrial);
        BpodSystem.Data.SoundDuration(currentTrial) = SoundDuration(currentTrial);
        BpodSystem.Data.InterTrial(currentTrial) = InterTrial(currentTrial);
        BpodSystem.Data.PreSound(currentTrial) = PreSound(currentTrial);
        BpodSystem.Data.StimulusSettings = StimulusSettings; % Save Stimulus settings
        
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
        
        if currentTrial<MaxTrials
            
            PossibleFreqs = logspace(log10(S.GUI.LowFreq),log10(S.GUI.HighFreq),S.GUI.nFreq);
            TrialFreq(currentTrial+1:end) = PossibleFreqs(randi(size(PossibleFreqs,2),1,MaxTrials-currentTrial));
            
            PossibleVolumes = linspace(S.GUI.SoundVolumeMin,S.GUI.SoundVolumeMax,S.GUI.nVolumes);

            TrialVol(currentTrial+1:end) = PossibleVolumes(randi(size(PossibleVolumes,2),1,MaxTrials-currentTrial));
            
            % display next trial info
            S.GUI.SoundFreq = round(TrialFreq(currentTrial+1)); % Sound Frequency
            S.GUI.SoundVolume = round(TrialVol(currentTrial+1)); % Sound Volume
            S.GUI.TrialNumber = [num2str(currentTrial+1) '/' num2str(MaxTrials)]; % Number of current trial
        end
        
    end
    
    if BpodSystem.BeingUsed == 0
        return
    end
    
end
