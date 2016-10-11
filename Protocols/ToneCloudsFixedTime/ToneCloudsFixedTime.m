
function ToneCloudsFixedTime

% This protocol implements the fixed time version of ToneClouds (developed by P. Znamenskiy) on Bpod
% Based on PsychoToolboxSound (written by J.Sanders)

% Written by F.Carnevale, 2/2015.

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
        
    % Protocol parameters
    % 1. Define parameters and values (with legacy syntax)
    S.GUI.Subject = BpodSystem.GUIData.SubjectName;
    S.GUI.Stage = 4;
    % 2. Parameter types and meta-data (assumes "edit" style if no meta info is specified)
    S.GUIMeta.Stage.Style = 'popupmenu';
    S.GUIMeta.Stage.String = {'Direct', 'Full 1', 'Full 2', 'Full 3', 'Full4'};
    % Assigns each parameter to a panel on the GUI (assumes "Parameters" panel if not specified)
    S.GUIPanels.Protocol = {'Subject', 'Stage'};
    
    
    % Stimulation Parameters
    S.GUI.UseStimulation = 0;
    S.GUIMeta.UseStimulation.Style = 'checkbox';
    S.GUI.TrainDelay = 0;
    S.GUI.PulseWidth = 0.002;
    S.GUI.PulseInterval = 0.1;
    S.GUI.StimProbability = 0.2;
    S.GUIPanels.Stimulation = {'UseStimulation', 'TrainDelay', 'PulseWidth', 'PulseInterval', 'StimProbability'};
    
    
    % Stimulus parameters
    S.GUI.DifficultyLow = 1;
    S.GUI.DifficultyHigh = 1;
    S.GUI.nDifficulties = 0;
    S.GUI.ToneOverlap = 0.66;
    S.GUI.ToneDuration = 0.03;
    S.GUI.VolumeMin = 50; % Lowest volume dB
    S.GUI.VolumeMax = 60; % Highest Volume dB
    S.GUI.AudibleHuman = 0;
    S.GUIMeta.AudibleHuman.Style = 'checkbox';
    S.GUI.LightsOn = 1;
    S.GUIMeta.LightsOn.Style = 'checkbox';
    S.GUIPanels.StimulusSettings = {'DifficultyLow', 'DifficultyHigh', 'nDifficulties'...
        'ToneOverlap', 'ToneDuration', 'VolumeMin', 'VolumeMax', 'AudibleHuman','LightsOn'};
    
    % Reward parameters
    S.GUI.SideRewardAmount = 2.5;
    S.GUI.CenterRewardAmount = 0.5;
    S.GUI.PunishSound = 0;
    S.GUI.FreqSide = 1;
    S.GUIMeta.FreqSide.Style = 'popupmenu';
    S.GUIMeta.FreqSide.String = {'LowLeft', 'LowRight'};
    S.GUIMeta.PunishSound.Style = 'checkbox';
    S.GUIPanels.RewardSettings = {'SideRewardAmount', 'CenterRewardAmount', 'FreqSide', 'PunishSound'};
    
        
    % Trial structure 
    S.GUI.TimeForResponse = 10;
    S.GUI.TimeoutDuration = 4;
    S.GUIPanels.TrialStructure = {'TimeForResponse', 'TimeoutDuration'};
    
    % Prestimulus delay
    S.GUI.PrestimDistribution = 1;
    S.GUIMeta.PrestimDistribution.Style = 'popupmenu';
    S.GUIMeta.PrestimDistribution.String = {'Delta', 'Uniform', 'Exponential'};
    S.GUI.PrestimDurationStart = 0.050;
    S.GUI.PrestimDurationEnd = 0.050;
    S.GUI.PrestimDurationStep = 0.050;
    S.GUI.PrestimDurationNtrials = 20;
    S.GUI.PrestimDurationCurrent = S.GUI.PrestimDurationStart;
    S.GUIMeta.PrestimDurationCurrent.Style = 'text';
    S.GUIPanels.PrestimulusDelay = {'PrestimDistribution', 'PrestimDurationStart', 'PrestimDurationEnd',...
        'PrestimDurationStep', 'PrestimDurationNtrials', 'PrestimDurationCurrent'};
    
    % Sound duration
    S.GUI.SoundDistribution = 1;
    S.GUIMeta.SoundDistribution.Style = 'popupmenu';
    S.GUIMeta.SoundDistribution.String = {'Delta', 'Uniform', 'Exponential'};
    S.GUI.SoundDurationStart = 0.1;
    S.GUI.SoundDurationEnd = 0.5;
    S.GUI.SoundDurationStep = 0.1;
    S.GUI.SoundDurationNtrials = 20;
    S.GUI.SoundDurationCurrent = S.GUI.SoundDurationStart;
    S.GUIMeta.SoundDurationCurrent.Style = 'text';
    S.GUIPanels.SoundDuration = {'SoundDistribution', 'SoundDurationStart', 'SoundDurationEnd',...
        'SoundDurationStep', 'SoundDurationNtrials', 'SoundDurationCurrent'};
    
    % Memory delay
    S.GUI.MemoryDistribution = 1;
    S.GUIMeta.MemoryDistribution.Style = 'popupmenu';
    S.GUIMeta.MemoryDistribution.String = {'Delta', 'Uniform', 'Exponential'};
    S.GUI.MemoryDurationStart = 0;
    S.GUI.MemoryDurationEnd = 0;
    S.GUI.MemoryDurationStep = 0.050;
    S.GUI.MemoryDurationNtrials = 20;
    S.GUI.MemoryDurationCurrent = S.GUI.MemoryDurationStart;
    S.GUIMeta.MemoryDurationCurrent.Style = 'text';
    S.GUIPanels.MemoryDuration = {'MemoryDistribution', 'MemoryDurationStart', 'MemoryDurationEnd',...
        'MemoryDurationStep', 'MemoryDurationNtrials', 'MemoryDurationCurrent'};
            
    % Antibias
    S.GUI.Antibias = 1;
    S.GUIMeta.Antibias.Style = 'popupmenu';
    S.GUIMeta.Antibias.String = {'no', 'yes'};
    S.GUIPanels.Antibias = {'Antibias'};

end

% Set frequency range
if S.GUI.AudibleHuman
    minFreq = 200; maxFreq = 2000; 
else
    minFreq = 5000; maxFreq = 40000; 
end

% Blank Pulse Pal Parameters
S.InitialPulsePalParameters = struct;
% Other Stimulus settings (not in the GUI)
StimulusSettings.ToneOverlap = S.GUI.ToneOverlap;
StimulusSettings.ToneDuration = S.GUI.ToneDuration;
StimulusSettings.minFreq = minFreq;
StimulusSettings.maxFreq = maxFreq;
StimulusSettings.SamplingRate = 192000; % Sound card sampling rate;
StimulusSettings.nFreq = 18; % Number of different frequencies to sample from
StimulusSettings.ramp = 0.005;    
StimulusSettings.Volume = 60;


%% Define trials
MaxTrials = 5000;
TrialTypes = ceil(rand(1,MaxTrials)*2); % correct side for each trial
EvidenceStrength = nan(1,MaxTrials); % evidence strength for each trial
pTarget = nan(1,MaxTrials); % evidence strength for each trial
PrestimDuration = nan(1,MaxTrials); % prestimulation delay period for each trial
SoundDuration = nan(1,MaxTrials); % sound duration period for each trial
MemoryDuration = nan(1,MaxTrials); % memory duration period for each trial
Outcomes = nan(1,MaxTrials);
Side = nan(1,MaxTrials);
StimulationTrials = zeros(1,MaxTrials);
StimulationSettings = cell(1,MaxTrials);
AccumulatedReward=0;

BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
BpodSystem.Data.EvidenceStrength = []; % The evidence strength of each trial completed will be added here.
BpodSystem.Data.PrestimDuration = []; % The evidence strength of each trial completed will be added here.
BpodSystem.Data.StimulationTrials = zeros(1,MaxTrials);

%% Initialize plots

% Initialize parameter GUI plugin
BpodParameterGUI('init', S);

% Total Reward display (online display of the total amount of liquid reward earned)
TotalRewardDisplay('init');

% Outcome plot
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [457 803 1000 250],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot = axes('Position', [.075 .3 .89 .6]);
OutcomePlot(BpodSystem.GUIHandles.OutcomePlot,'init',2-TrialTypes);

% Performance
SlidingWindowSize = 30; % Size of sliding window average, units = trials
TrialGroups{1} = 1; TrialGroups{2} = 2; % Groups of trial types to plot %correct
TrialGroupNames{1} = 'Left'; TrialGroupNames{2} = 'Right'; % Names of consecutive groups
PerformancePlot('init', TrialGroups, TrialGroupNames, SlidingWindowSize);

% Psychometric
BpodSystem.ProtocolFigures.PsychoPlotFig = figure('Position', [1450 100 400 300],'name','Pshycometric plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.PsychoPlot = axes('Position', [.2 .25 .75 .65]);
PsychoPlot(BpodSystem.GUIHandles.PsychoPlot,'init')  %set up axes nicely

% % BinoPlot
% BpodSystem.ProtocolFigures.BinoPlotFig = figure('Position', [1450 100 400 300],'name','Binomial plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
% BpodSystem.GUIHandles.BinoPlot = axes('Position', [.2 .25 .75 .65]);
% hold(BpodSystem.GUIHandles.BinoPlot,'on')
% BinoPlot(BpodSystem.GUIHandles.BinoPlot,'init',2)  %set up axes nicely

% Stimulus plot
BpodSystem.ProtocolFigures.StimulusPlotFig = figure('Position', [457 803 500 300],'name','Stimulus plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.StimulusPlot = axes('Position', [.15 .2 .75 .65]);
StimulusPlot(BpodSystem.GUIHandles.StimulusPlot,'init',StimulusSettings.nFreq);

%%% Pokes plot
state_colors = struct( ...
        'WaitForCenterPoke', [0.5 0.5 1],...
        'Delay',0.3*[1 1 1],...
        'DeliverStimulus', 0.75*[1 1 0],...
        'Memory', 0.75*[0.25 1 0.5],...
        'GoSignal',[0.5 1 1],...        
        'Reward',[0,1,0],...
        'Drinking',[0,0,1],...
        'Punish',[1,0,0],...
        'EarlyWithdrawal',[1,0.3,0],...
        'EarlyWithdrawalPunish',[1,0,0],...
        'WaitForResponse',0.75*[0,1,1],...
        'CorrectWithdrawalEvent',[1,0,0],...
        'exit',0.2*[1 1 1]);
    
poke_colors = struct( ...
      'L', 0.6*[1 0.66 0], ...
      'C', [0 0 0], ...
      'R',  0.9*[1 0.66 0]);
    
PokesPlot('init', state_colors,poke_colors);

SummaryAndSave('init');
SummaryAndSave('display','Subject', BpodSystem.GUIData.SubjectName);
SummaryAndSave('display','Stage', S.GUIMeta.Stage.String{S.GUI.Stage});


%% Define stimuli and send to sound server

SF = StimulusSettings.SamplingRate;
AttenuationFactor = .5;
PunishSound = (rand(1,SF*.5)*AttenuationFactor) - AttenuationFactor*.5;

% Program sound server
PsychToolboxSoundServer('init')
PsychToolboxSoundServer('Load', 2, 0);
PsychToolboxSoundServer('Load', 3, PunishSound);

% Set soft code handler to trigger sounds
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

BpodSystem.ProtocolFigures.InitialMsg = msgbox({'', ' Edit your settings and click OK when you are ready to start!     ', ''},'ToneCloud Protocol...');
uiwait(BpodSystem.ProtocolFigures.InitialMsg);

S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
UsingStimulation = 0;
if S.GUI.UseStimulation
    try
        PulsePal;
        load TC4B_PulsePalProgram;
        ProgramPulsePal(ParameterMatrix);
        S.InitialPulsePalParameters = ParameterMatrix;
        UsingStimulation = 1;
    catch
        disp('No PulsePal connected')
    end
end
% Set timer for this session
SessionBirthdate = tic;

% Disable changing task 
set(BpodSystem.GUIHandles.ParameterGUI.Params(strcmp(get(BpodSystem.GUIHandles.ParameterGUI.Labels(:),'string'),'Stage')),'enable','off')


CenterValveCode = 2;

% Control the step up of prestimulus period and stimulus duration
controlStep_Prestim = 0; % valid trial counter
controlStep_Sound = 0; % valid trial counter
controlStep_Memory = 0; % valid trial counter

%% Main trial loop
for currentTrial = 1:MaxTrials
    
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
        
    if S.GUI.UseStimulation
        StimulationTrials(currentTrial) = rand < S.GUI.StimProbability;
        if (~UsingStimulation)
            PulsePal;
            load TC4B_PulsePalProgram;
            ProgramPulsePal(ParameterMatrix);
            S.InitialPulsePalParameters = ParameterMatrix;
            UsingStimulation = 1;
        end  
        
        ProgramPulsePalParam(4, 'Phase1Duration', S.GUI.PulseWidth);
        ProgramPulsePalParam(4, 'InterPulseInterval', S.GUI.PulseInterval);
        ProgramPulsePalParam(4, 'PulseTrainDelay', S.GUI.TrainDelay);
        if StimulationTrials(currentTrial)
            ProgramPulsePalParam(4,'linkedtotriggerCH1', 1);
        else
            ProgramPulsePalParam(4,'linkedtotriggerCH1', 0);
        end

        StimulationSettings{currentTrial}.PulseWidth = S.GUI.PulseWidth;
        StimulationSettings{currentTrial}.PulseInterval = S.GUI.PulseInterval;
        StimulationSettings{currentTrial}.TrainDelay = S.GUI.TrainDelay;
    else
        try
            ProgramPulsePalParam(4,'linkedtotriggerCH1', 0);
        catch
        end
        UsingStimulation = 0;
        StimulationTrials(currentTrial) = 0;
    end
    
    if S.GUI.AudibleHuman, minFreq = 200; maxFreq = 2000; else minFreq = 5000; maxFreq = 40000; end
    if S.GUI.LightsOn, LightsOn = 255; else LightsOn = 0; end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Prestimulation Duration

    if currentTrial==1 %start from the start
        S.GUI.PrestimDurationCurrent =  S.GUI.PrestimDurationStart;
    end    
    controlStep_nRequiredValid_Prestim = S.GUI.PrestimDurationNtrials;    
    
    if S.GUI.PrestimDurationStart<S.GUI.PrestimDurationEnd %step up prestim duration only if start<end
        if controlStep_Prestim > controlStep_nRequiredValid_Prestim

            controlStep_Prestim = 0; %restart counter

            % step up, unless we are at the max
            if S.GUI.PrestimDurationCurrent + S.GUI.PrestimDurationStep > S.GUI.PrestimDurationEnd
                S.GUI.PrestimDurationCurrent = S.GUI.PrestimDurationEnd;
            else
                S.GUI.PrestimDurationCurrent = S.GUI.PrestimDurationCurrent + S.GUI.PrestimDurationStep;
            end
        end
    else
       S.GUI.PrestimDurationCurrent =  S.GUI.PrestimDurationStart;
    end
    
    switch S.GUI.PrestimDistribution
        case 1
            PrestimDuration(currentTrial) = S.GUI.PrestimDurationCurrent;
        case 2
            % uniform distribution with mean = range
            PrestimDuration(currentTrial) = (rand+0.5)*S.GUI.PrestimDurationCurrent;
        case 3
            PrestimDuration(currentTrial) = exprnd(S.GUI.PrestimDurationCurrent);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Sound Duration
    
    if currentTrial==1 %start from the start
        S.GUI.SoundDurationCurrent =  S.GUI.SoundDurationStart;
    end    
    controlStep_nRequiredValid_Sound = S.GUI.SoundDurationNtrials;    
    
    if S.GUI.SoundDurationStart<S.GUI.SoundDurationEnd %step up prestim duration only if start<end
        if controlStep_Sound > controlStep_nRequiredValid_Sound

            controlStep_Sound = 0; %restart counter

            % step up, unless we are at the max
            if S.GUI.SoundDurationCurrent + S.GUI.SoundDurationStep > S.GUI.SoundDurationEnd
                S.GUI.SoundDurationCurrent = S.GUI.SoundDurationEnd;
            else
                S.GUI.SoundDurationCurrent = S.GUI.SoundDurationCurrent + S.GUI.SoundDurationStep;
            end
        end
    else
       S.GUI.SoundDurationCurrent =  S.GUI.SoundDurationStart;
    end
    
    switch S.GUI.SoundDistribution
        case 1
            SoundDuration(currentTrial) = S.GUI.SoundDurationCurrent;
        case 2
            % uniform distribution with mean = range
            SoundDuration(currentTrial) = (rand+0.5)*S.GUI.SoundDurationCurrent;
        case 3
            SoundDuration(currentTrial) = exprnd(S.GUI.SoundDurationCurrent);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MemoryDuration
    
    if currentTrial==1 %start from the start
        S.GUI.MemoryDurationCurrent =  S.GUI.MemoryDurationStart;
    end    
    controlStep_nRequiredValid_Memory = S.GUI.MemoryDurationNtrials;    
    
    if S.GUI.MemoryDurationStart<S.GUI.MemoryDurationEnd %step up prestim duration only if start<end
        if controlStep_Memory > controlStep_nRequiredValid_Memory

            controlStep_Memory = 0; %restart counter

            % step up, unless we are at the max
            if S.GUI.MemoryDurationCurrent + S.GUI.MemoryDurationStep > S.GUI.MemoryDurationEnd
                S.GUI.MemoryDurationCurrent = S.GUI.MemoryDurationEnd;
            else
                S.GUI.MemoryDurationCurrent = S.GUI.MemoryDurationCurrent + S.GUI.MemoryDurationStep;
            end
        end
    else
       S.GUI.MemoryDurationCurrent =  S.GUI.MemoryDurationStart;
    end
    
    switch S.GUI.MemoryDistribution
        case 1
            MemoryDuration(currentTrial) = S.GUI.MemoryDurationCurrent;
        case 2
            % uniform distribution with mean = range
            MemoryDuration(currentTrial) = (rand+0.5)*S.GUI.MemoryDurationCurrent;
        case 3
            MemoryDuration(currentTrial) = exprnd(S.GUI.MemoryDurationCurrent);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    
    R = GetValveTimes(S.GUI.SideRewardAmount, [1 3]); 
    LeftValveTime = R(1); RightValveTime = R(2); % Update reward amounts
    C = GetValveTimes(S.GUI.CenterRewardAmount, 2); 
    CenterValveTime = C(1);

    
    % Update stimulus settings
    StimulusSettings.nTones = floor((S.GUI.SoundDurationCurrent-S.GUI.ToneDuration*S.GUI.ToneOverlap)/(S.GUI.ToneDuration*(1-S.GUI.ToneOverlap)));
    StimulusSettings.ToneOverlap = S.GUI.ToneOverlap;
    StimulusSettings.ToneDuration = S.GUI.ToneDuration;
    StimulusSettings.minFreq = minFreq;
    StimulusSettings.maxFreq = maxFreq;
    StimulusSettings.VolumeMin = S.GUI.VolumeMin;
    StimulusSettings.VolumeMax = S.GUI.VolumeMax;
    StimulusSettings.Volume = (randi(10)-1)/4*(StimulusSettings.VolumeMax-StimulusSettings.VolumeMin) + StimulusSettings.VolumeMin;
    
    bias = nanmean(Side(1:currentTrial-1))-1; %0:left, 1:right
    disp(['Bias (0:left,1:right): ' num2str(bias)]);
    
    switch S.GUI.Stage
        
        case 1 % Training stage 1: Direct sides - Poke and collect water
                        
            S.GUI.TimeoutDuration = 0;
            
            EvidenceStrength(currentTrial) = 1;   
            GoSignalStateChangeConditions = {'Tup', 'Reward'};
            
        case 2 % Full task 1
               % Full 1: no punish sound, no timeout, sound duration ramping up in 40 trials, prestim 0.05 delta 
               % (until it does reasonable number of trials)
            
            DifficultySet = [S.GUI.DifficultyLow S.GUI.DifficultyLow:(S.GUI.DifficultyHigh-S.GUI.DifficultyLow)/(S.GUI.nDifficulties-1):S.GUI.DifficultyHigh S.GUI.DifficultyHigh];
            DifficultySet = unique(DifficultySet);
            EvidenceStrength(currentTrial) = DifficultySet(randi(size(DifficultySet,2)));  
            GoSignalStateChangeConditions = {'Tup', 'WaitForResponse'};
            
            S.GUI.PunishSound = 0;
            S.GUI.TimeoutDuration = 0;
            S.GUI.SoundDurationNtrials = 40;
            S.GUI.PrestimDistribution = 1;
            S.GUI.PrestimDurationEnd = 0.050; % Prestim duration end
            
        
        case 3 % Full task 2
               % Full 2: punish sound, 4s timeout, sound duration ramping up in 20 trials, prestim 0.1 uniform 
               % (until gets the association)
                        
            DifficultySet = [S.GUI.DifficultyLow S.GUI.DifficultyLow:(S.GUI.DifficultyHigh-S.GUI.DifficultyLow)/(S.GUI.nDifficulties-1):S.GUI.DifficultyHigh S.GUI.DifficultyHigh];
            DifficultySet = unique(DifficultySet);
            EvidenceStrength(currentTrial) = DifficultySet(randi(size(DifficultySet,2)));  
            GoSignalStateChangeConditions = {'Tup', 'WaitForResponse'};
       
            S.GUI.PunishSound = 1;
            S.GUI.TimeoutDuration = 4;
            S.GUI.SoundDurationNtrials = 20;
            S.GUI.PrestimDistribution = 2;
            S.GUI.PrestimDurationEnd = 0.10; % Prestim duration end
            S.GUI.PrestimDurationNtrials = 20; % Required number of valid trials before each step    
                    
        case 4 % Full task 3
               % Full 3: sound duration ramping up 2 trials, prestim 0.25 uniform
               % (until the end, increasing difficulty)
               
            S.GUI.MemoryDurationStart = 0;
            S.GUI.MemoryDurationEnd = 0.3;
            S.GUI.MemoryDurationStep = 0.1;
            S.GUI.MemoryDurationNtrials = 2;
            
            S.GUI.DifficultyLow = 0.4;
            S.GUI.DifficultyHigh = 1;
            S.GUI.nDifficulties = 5;
            
            DifficultySet = [S.GUI.DifficultyLow S.GUI.DifficultyLow:(S.GUI.DifficultyHigh-S.GUI.DifficultyLow)/(S.GUI.nDifficulties-1):S.GUI.DifficultyHigh S.GUI.DifficultyHigh];
            DifficultySet = unique(DifficultySet);
            EvidenceStrength(currentTrial) = DifficultySet(randi(size(DifficultySet,2)));  
            GoSignalStateChangeConditions = {'Tup', 'WaitForResponse'};
            
            S.GUI.PunishSound = 1;                    
            S.GUI.TimeoutDuration = 4;
            S.GUI.SoundDurationNtrials = 2;
            S.GUI.PrestimDistribution = 2;
            S.GUI.PrestimDurationEnd = 0.25; % Prestim duration end
            S.GUI.PrestimDurationNtrials = 2; % Required number of valid trials before each step    

        case 5 % Full task 4 (full Psycometric with Memory and Stimulation)
               % same as full 3
            
            S.GUI.UseStimulation = 1;

            S.GUI.MemoryDurationStart = 0;
            S.GUI.MemoryDurationEnd = 0.3;
            S.GUI.MemoryDurationStep = 0.1;
            S.GUI.MemoryDurationNtrials = 2;
               
            S.GUI.DifficultyLow = 0.4;
            S.GUI.DifficultyHigh = 1;
            S.GUI.nDifficulties = 5;
            
            DifficultySet = [S.GUI.DifficultyLow S.GUI.DifficultyLow:(S.GUI.DifficultyHigh-S.GUI.DifficultyLow)/(S.GUI.nDifficulties-1):S.GUI.DifficultyHigh S.GUI.DifficultyHigh];
            DifficultySet = unique(DifficultySet);
            EvidenceStrength(currentTrial) = DifficultySet(randi(size(DifficultySet,2)));  
            GoSignalStateChangeConditions = {'Tup', 'WaitForResponse'};
            
            S.GUI.PunishSound = 1;                    
            S.GUI.TimeoutDuration = 4;
            S.GUI.SoundDurationNtrials = 2;
            S.GUI.PrestimDistribution = 2;
            S.GUI.PrestimDurationEnd = 0.25; % Prestim duration end
            S.GUI.PrestimDurationNtrials = 2; % Required number of valid trials before each step    
    end
    
    % Update ParameterGUI according to stage
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    
    if S.GUI.PunishSound
        PsychToolboxSoundServer('Load', 3, PunishSound);
    else
        PsychToolboxSoundServer('Load', 3, 0);
    end
    
    if S.GUI.Antibias==2 %apply antib;ias
        
        if rand<bias % this condition is met most frequently when bias is close to 1 (bias is to the right)
            TrialTypes(currentTrial) = 1; % type 1 means reward at left 
        else % this condition is most frequently met when bias is close to 0 (bias to the left) 
            TrialTypes(currentTrial) = 2; % type 2 means reward at right 
        end
    end
    
    
    switch TrialTypes(currentTrial) % Determine trial-specific state matrix fields
        
        case 1 % Left is rewarded
            
            if strcmp(S.GUIMeta.FreqSide.String{S.GUI.FreqSide},'LowLeft')                
                TargetOctave = 'low';
            else
                TargetOctave = 'high';
            end
            
        case 2 % Right is rewarded
            
            if strcmp(S.GUIMeta.FreqSide.String{S.GUI.FreqSide},'LowRight')                
                TargetOctave = 'low';
            else
                TargetOctave = 'high';
            end
    end
    
    % This stage sound generation
    [Sound, Cloud, Cloud_toplot] = GenerateToneCloud(TargetOctave, EvidenceStrength(currentTrial), StimulusSettings);
    PsychToolboxSoundServer('Load', 1, Sound);
                        
    % Because stimulus generation is random, we need to check trial
    % by trial, so that the animal is rewarded by what they hear
    if sum(Cloud>9)>sum(Cloud<9) % if more high than low tones

        pTarget(currentTrial) = sum(Cloud>9)/sum(Cloud>0);

        TargetOctave = 'high';

        if S.GUI.FreqSide==1 %LowLeft
           TrialTypes(currentTrial) = 2; % type 2 means reward at right 
        else %LowRight
           TrialTypes(currentTrial) = 1; % type 1 means reward at left
        end

    else

        pTarget(currentTrial) = sum(Cloud<9)/sum(Cloud>0);

        TargetOctave = 'low';

        if S.GUI.FreqSide==1 %LowLeft
           TrialTypes(currentTrial) = 1; % type 1 means reward at left    
        else  %LowRight
           TrialTypes(currentTrial) = 2; % type 1 means reward at right
        end

    end

    if TrialTypes(currentTrial)==1 % type 1 means reward at left
        CorrectWithdrawalEvent = 'Port1Out';
        ValveCode = 1; ValveTime = LeftValveTime;
        RewardedPort = {'Port1In'};
        PunishedPort = {'Port3In'};
    else                           % type 2 means reward at right
        CorrectWithdrawalEvent = 'Port3Out';
        ValveCode = 4; ValveTime = RightValveTime;
        RewardedPort = {'Port3In'}; 
        PunishedPort = {'Port1In'};
    end


    sma = NewStateMatrix(); % Assemble state matrix

    sma = AddState(sma, 'Name', 'WaitForCenterPoke', ...
        'Timer', 0,...
        'StateChangeConditions', {'Port2In', 'Delay'},...
        'OutputActions',{'PWM2', 255});

    sma = AddState(sma, 'Name', 'Delay', ...
        'Timer', PrestimDuration(currentTrial),...
        'StateChangeConditions', {'Tup', 'DeliverStimulus', 'Port2Out', 'EarlyWithdrawal'},...
        'OutputActions', {'PWM2', LightsOn});

    sma = AddState(sma, 'Name', 'DeliverStimulus', ...
        'Timer', SoundDuration(currentTrial),...
        'StateChangeConditions', {'Tup', 'Memory', 'Port2Out', 'EarlyWithdrawal'},...
        'OutputActions', {'SoftCode', 1,'PWM2', LightsOn, 'BNCState', 2});

    sma = AddState(sma, 'Name', 'Memory', ...
        'Timer', MemoryDuration(currentTrial),...
        'StateChangeConditions', {'Tup', 'GoSignal', 'Port2Out', 'EarlyWithdrawal'},...
        'OutputActions', {'PWM2', LightsOn});

    sma = AddState(sma, 'Name', 'GoSignal', ...
        'Timer', CenterValveTime,...
        'StateChangeConditions', GoSignalStateChangeConditions,...
        'OutputActions', {'ValveState', CenterValveCode,'PWM2', LightsOn});

    sma = AddState(sma, 'Name', 'EarlyWithdrawal', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'EarlyWithdrawalPunish'},...
        'OutputActions', {'SoftCode', 255,'PWM2', LightsOn});

    sma = AddState(sma, 'Name', 'WaitForResponse', ...
        'Timer', S.GUI.TimeForResponse,...
        'StateChangeConditions', {'Tup', 'exit', RewardedPort, 'Reward', PunishedPort, 'Punish'},...
        'OutputActions', {'PWM1', LightsOn, 'PWM3', LightsOn});

    sma = AddState(sma, 'Name', 'Reward', ...
        'Timer', ValveTime,...
        'StateChangeConditions', {'Tup', 'Drinking'},...
        'OutputActions', {'ValveState', ValveCode, 'PWM1', LightsOn,'PWM3', LightsOn});

    sma = AddState(sma, 'Name', 'Drinking', ...
        'Timer', 0,...
        'StateChangeConditions', {CorrectWithdrawalEvent, 'exit'},...
        'OutputActions', {'PWM1', LightsOn,'PWM3', LightsOn});

    sma = AddState(sma, 'Name', 'Punish', ...
        'Timer', S.GUI.TimeoutDuration,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'SoftCode', 3});

    sma = AddState(sma, 'Name', 'EarlyWithdrawalPunish', ...
        'Timer', S.GUI.TimeoutDuration,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'SoftCode', 3});

    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;

    tic
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial); % Adds the trial type of the current trial to data
        BpodSystem.Data.EvidenceStrength(currentTrial) = EvidenceStrength(currentTrial); 
        BpodSystem.Data.pTarget(currentTrial) = pTarget(currentTrial); 
        BpodSystem.Data.PrestimDuration(currentTrial) = PrestimDuration(currentTrial); % 
        BpodSystem.Data.SoundDuration(currentTrial) = SoundDuration(currentTrial); % 
        BpodSystem.Data.MemoryDuration(currentTrial) = MemoryDuration(currentTrial); % 
        BpodSystem.Data.StimulusSettings = StimulusSettings; % Save Stimulus settings
        BpodSystem.Data.Cloud{currentTrial} = Cloud; % Saves Stimulus 
        BpodSystem.Data.StimulusVolume(currentTrial) = StimulusSettings.Volume;
        
        % Side (this works becasue in each trial once the animal goes into one port is either a reward or a punishment and then exit - there are no two ports-in in one trial)
        if isfield(BpodSystem.Data.RawEvents.Trial{currentTrial}.Events,'Port1In') 
            Side(currentTrial) = 1; %Left
        elseif isfield(BpodSystem.Data.RawEvents.Trial{currentTrial}.Events,'Port3In')
            Side(currentTrial) = 2; %Right
        else
            Side(currentTrial) = nan; %Invalid
        end                      
        
        %Outcome
        if ~isnan(BpodSystem.Data.RawEvents.Trial{currentTrial}.States.Reward(1))
            Outcomes(currentTrial) = 1;
            AccumulatedReward = AccumulatedReward+S.GUI.SideRewardAmount+S.GUI.CenterRewardAmount;
            controlStep_Prestim = controlStep_Prestim+1; % update because this is a valid trial
            controlStep_Sound = controlStep_Sound+1; % update because this is a valid trial
            controlStep_Memory = controlStep_Memory+1; % update because this is a valid trial
            
            Side(currentTrial) = TrialTypes(currentTrial);
            
        elseif ~isnan(BpodSystem.Data.RawEvents.Trial{currentTrial}.States.Punish(1))
            Outcomes(currentTrial) = 0;
            controlStep_Prestim = controlStep_Prestim+1; % update because this is a valid trial
            controlStep_Sound = controlStep_Sound+1; % update because this is a valid trial
            controlStep_Memory = controlStep_Memory+1; % update because this is a valid trial
            
            Side(currentTrial) = 2-not((2-TrialTypes(currentTrial)));
                        
        else
            Outcomes(currentTrial) = -1;
        end
        
        BpodSystem.Data.Outcomes(currentTrial) = Outcomes(currentTrial);
        BpodSystem.Data.Side(currentTrial) = Side(currentTrial);
        BpodSystem.Data.AccumulatedReward = AccumulatedReward;
        BpodSystem.Data.StimulationTrials(currentTrial) = StimulationTrials(currentTrial);
        BpodSystem.Data.StimulationSettings(currentTrial) = StimulationSettings(currentTrial);
        
        
        %Update plots
        UpdateOutcomePlot(TrialTypes, Outcomes);
        UpdatePerformancePlot(TrialTypes, Outcomes,SessionBirthdate);
        UpdatePsychoPlot(TrialTypes, Outcomes);
%         UpdateBinoPlot();
        UpdateStimulusPlot(Cloud_toplot);
        PokesPlot('update');
        UpdateTotalRewardDisplay(S.GUI.CenterRewardAmount+S.GUI.SideRewardAmount, currentTrial);
        
        SummaryAndSave('display','Association', S.GUIMeta.FreqSide.String{S.GUI.FreqSide});
        SummaryAndSave('display','Time', floor(toc(SessionBirthdate)/60));
        SummaryAndSave('display','Water', AccumulatedReward);
        SummaryAndSave('display','Correct', sum(Outcomes > 0));
        SummaryAndSave('display','Valid', sum(Outcomes >= 0));
        SummaryAndSave('display','Total', currentTrial);
        
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    toc
    if BpodSystem.BeingUsed == 0
        return
    end
end

function UpdateOutcomePlot(TrialTypes, Outcomes)
global BpodSystem
EvidenceStrength = BpodSystem.Data.EvidenceStrength
nTrials = BpodSystem.Data.nTrials;
OutcomePlot(BpodSystem.GUIHandles.OutcomePlot,'update',nTrials+1,2-TrialTypes,Outcomes,EvidenceStrength);

function UpdatePerformancePlot(TrialTypes, Outcomes,~)
global BpodSystem
nTrials = BpodSystem.Data.nTrials;
PerformancePlot('update', TrialTypes, Outcomes, nTrials);

function UpdatePsychoPlot(TrialTypes, Outcomes)
global BpodSystem
EvidenceStrength = BpodSystem.Data.EvidenceStrength;
nTrials = BpodSystem.Data.nTrials;
PsychoPlot(BpodSystem.GUIHandles.PsychoPlot, 'update',nTrials,2-TrialTypes,Outcomes,EvidenceStrength);

function UpdateTotalRewardDisplay(RewardAmount, currentTrial)
% If rewarded based on the state data, update the TotalRewardDisplay
global BpodSystem
    if ~isnan(BpodSystem.Data.RawEvents.Trial{currentTrial}.States.Reward(1))
        TotalRewardDisplay('add', RewardAmount);
    end

% function UpdateBinoPlot()
% global BpodSystem
% 
% %pTarget = (1/2+r/2);
% %EvidenceStrength = 2*(pTarget-1/2);
% Predictor = {(2*BpodSystem.Data.pTarget-1).*(2*BpodSystem.Data.TrialTypes-3);...
%              (BpodSystem.Data.StimulusVolume-55)/10};
% Response = BpodSystem.Data.Side;
% Valid = BpodSystem.Data.Outcomes>=0;
% BinoPlot(BpodSystem.GUIHandles.PsychoPlot,'update',Predictor,Response,Valid);        
        

function UpdateStimulusPlot(Cloud)
global BpodSystem
CloudDetails.pTarget = BpodSystem.Data.pTarget(end);
if sum(BpodSystem.Data.Cloud{end}>9)>sum(BpodSystem.Data.Cloud{end}<9)
    CloudDetails.Target = 'High';
else
    CloudDetails.Target = 'Low';    
end
StimulusPlot(BpodSystem.GUIHandles.StimulusPlot,'update',Cloud,CloudDetails);