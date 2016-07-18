
function PinpingCurves
% This protocol is used to estimate tuning curves in auditory areas
% Written by F.Carnevale, 4/2015.

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with settings default
    
    S.GUI.PulseWidth = 0.002; 
    S.GUI.minPulseFreq = 10; 
    S.GUI.maxPulseFreq = 100; 
    S.GUI.nFreq = 20; % Number of frequencies
    
    S.GUIPanels.PulseSettings = {'PulseWidth', 'minPulseFreq', 'maxPulseFreq', 'nFreq'};
    
    S.GUI.InterTrial = 0.5; % Intertrial Interval
    S.GUI.PreStimMin = 0.25; % PreSound Interval
    S.GUI.PreStimWidth = 0.25; % PreSound Interval
    S.GUI.StimDuration = 0.5; % Sound Duration
    S.GUI.nStim = 10;
    
    S.GUIPanels.TimingSettings = {'InterTrial', 'PreStimMin', 'PreStimWidth', 'StimDuration', 'nStim'};
    
    S.GUI.PulseFreq = 0; % Pulse Frequency
    S.GUIMeta.PulseFreq.Style = 'text';
    
    S.GUI.TrialNumber = 0; % Number of current trial
    S.GUIMeta.TrialNumber.Style = 'text';
    
    S.GUI.TotalTrials = 0; % Total number of trials
    S.GUIMeta.TotalTrials.Style = 'text';
    
    S.GUIPanels.CurrentTrial = {'PulseFreq', 'TrialNumber', 'TotalTrials'};

    
    % Other Stimulus settings (not in the GUI)
    StimulusSettings.SamplingRate = 192000; % Sound card sampling rate;
    
end

PulsePal;
load ParameterMatrix_Example;
ProgramPulsePal(ParameterMatrix); % Sends the default parameter matrix to Pulse Pal
ProgramPulsePalParam(1, 'LinkedToTriggerCH1', 0); % Set output channel 4 to respond to trigger ch 1
ProgramPulsePalParam(2, 'LinkedToTriggerCH1', 0); % Set output channel 4 to respond to trigger ch 1
ProgramPulsePalParam(3, 'LinkedToTriggerCH1', 0); % Set output channel 4 to respond to trigger ch 1
ProgramPulsePalParam(4, 'LinkedToTriggerCH1', 1); % Set output channel 4 to respond to trigger ch 1

% Initialize parameter GUI plugin
BpodParameterGUI('init', S);

BpodSystem.Data.TrialFreq = []; % The trial frequency of each trial completed will be added here.

BpodSystem.ProtocolFigures.InitialMsg = msgbox({'', ' Edit your settings and click OK when you are ready to start!     ', ''},'Tuning Curves Protocol...');
uiwait(BpodSystem.ProtocolFigures.InitialMsg);

S = BpodParameterGUI('sync', S); % Sync parameters with EnhancedBpodParameterGUI plugin

%% Define trials
PossibleFreqs = linspace(S.GUI.minPulseFreq,S.GUI.maxPulseFreq,S.GUI.nFreq);

MaxTrials = size(PossibleFreqs,2)*S.GUI.nStim;

PulseFreq = PossibleFreqs(randi(size(PossibleFreqs,2),1,MaxTrials));

PreSound = nan(1,MaxTrials); % PreSound interval for each trial
InterTrial = nan(1,MaxTrials); % Intertrial interval for each trial
StimDuration = nan(1,MaxTrials); % Sound duration for each trial

S.GUI.PulseFreq = round(PulseFreq(1)); % Sound Volume

S.GUI.TrialNumber = 1; % Number of current trial
S.GUI.TotalTrials = MaxTrials; % Total number of trials

%% Main trial loop
for currentTrial = 1:MaxTrials
    
    S = BpodParameterGUI('sync', S); % Sync parameters with EnhancedBpodParameterGUI plugin
    
    InterTrial(currentTrial) = S.GUI.InterTrial;
    PreSound(currentTrial) = S.GUI.PreStimMin+S.GUI.PreStimWidth*rand;
    StimDuration(currentTrial) = S.GUI.StimDuration;

    % Update stimulus settings    
    StimulusSettings.PulseWidth = S.GUI.PulseWidth;    
    StimulusSettings.StimDuration = S.GUI.StimDuration;
    StimulusSettings.PulseFreq = PulseFreq(currentTrial);
    StimulusSettings.InterPulseInterval = round((1/StimulusSettings.PulseFreq)*10^4)/10^4;
    if StimulusSettings.InterPulseInterval <0
        StimulusSettings.InterPulseInterval = 0;
    end
    
    ProgramPulsePalParam(4, 'Phase1Voltage', 1); % Set output channel 1 to produce 2.5V pulses
    ProgramPulsePalParam(4, 'Phase1Duration', StimulusSettings.PulseWidth); % Set output channel 1 to produce 2ms pulses
    ProgramPulsePalParam(4, 'InterPulseInterval', StimulusSettings.InterPulseInterval); % Set pulse interval to produce 10Hz pulses
    ProgramPulsePalParam(4, 'PulseTrainDuration', StimulusSettings.StimDuration); % Set pulse train to last 120 seconds


    sma = NewStateMatrix(); % Assemble state matrix
    
    sma = AddState(sma, 'Name', 'PreSound', ...
        'Timer', PreSound(currentTrial),...
        'StateChangeConditions', {'Tup', 'TrigStart'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'TrigStart', ...
        'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'DeliverStimulus'},...
        'OutputActions', {'BNCState', 2});
    sma = AddState(sma, 'Name', 'DeliverStimulus', ...
        'Timer', StimDuration(currentTrial)/1000,...
        'StateChangeConditions', {'Tup', 'InterTrial'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'InterTrial', ...
        'Timer', InterTrial(currentTrial),...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
    
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.PulseFreq(currentTrial) = PulseFreq(currentTrial);
        BpodSystem.Data.StimDuration(currentTrial) = StimDuration(currentTrial);
        BpodSystem.Data.InterTrial(currentTrial) = InterTrial(currentTrial);
        BpodSystem.Data.PreSound(currentTrial) = PreSound(currentTrial);
        BpodSystem.Data.StimulusSettings = StimulusSettings; % Save Stimulus settings
        
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
        
        if currentTrial<MaxTrials
            
            PossibleFreqs = linspace(S.GUI.minPulseFreq,S.GUI.maxPulseFreq,S.GUI.nFreq);
            PulseFreq(currentTrial+1:end) = PossibleFreqs(randi(size(PossibleFreqs,2),1,MaxTrials-currentTrial));
            
            % display next trial info
            S.GUI.PulseFreq = round(PulseFreq(currentTrial+1));
            S.GUI.TrialNumber = currentTrial+1; % Number of current trial
            S.GUI.TotalTrials = MaxTrials; % Total number of trials
        end
        
    end
    
    if BpodSystem.BeingUsed == 0
        return
    end
    
end
