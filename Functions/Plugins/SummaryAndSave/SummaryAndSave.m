%{
----------------------------------------------------------------------------

This file is part of the Bpod Project
Copyright (C) 2014 Joshua I. Sanders, Cold Spring Harbor Laboratory, NY, USA

----------------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3.

This program is distributed  WITHOUT ANY WARRANTY and without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
%}
function SummaryAndSave(varargin)
% SummaryAndSave('init') - initializes a window that displays total reward
% SummaryAndSave('add', Amount) - updates the total reward display with
% a new reward, adding to the total amount.

global BpodSystem
Op = varargin{1};
if nargin > 1
    FieldToDisplay = varargin{2};
    ThingToDisplay = varargin{3};
end
Op = lower(Op);
switch Op
    case 'init'
        xposition = .14;
        yposition=0.94;
        dy = 0.04;
        dyy = 0.062;
        
        width = 0.7;
        height = 0.035;
        
        background_color = 0.9*[1 1 1];
        
        BpodSystem.PluginObjects.SummaryAndSaveDisplay = 0;
        BpodSystem.ProtocolFigures.SummaryAndSaveDisplay = figure('Position', [100 250 300 700],'name','Summary and Save','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off', 'Color', [.8 .8 .8]);
        set(BpodSystem.ProtocolFigures.SummaryAndSaveDisplay, 'Position', [100 250 300 700]);
        
        %Save       
        yposition = yposition-dyy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Save = struct;
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Save.Button = uicontrol('Style', 'pushbutton', 'String', 'Save to Server', 'units', 'normalized', 'Position', [xposition yposition width height+0.02], 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color,'Callback', @SyncWithServer);
        
        %Subject        
        yposition = yposition-dyy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Subject = struct;
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Subject.Label = uicontrol('Style', 'text', 'String', 'Subject', 'units', 'normalized', 'Position', [xposition yposition width height], 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color);
        yposition = yposition-dy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Subject.Amount = uicontrol('Style', 'text', 'String', '-', 'units', 'normalized', 'Position', [xposition yposition width height], 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color);
        
        %Association        
        yposition = yposition-dyy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Association = struct;
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Association.Label = uicontrol('Style', 'text', 'String', 'Association', 'units', 'normalized', 'Position', [xposition yposition width height], 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color);
        yposition = yposition-dy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Association.Amount = uicontrol('Style', 'text', 'String', '-', 'units', 'normalized', 'Position', [xposition yposition width height], 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color);
        
        %Stage        
        yposition = yposition-dyy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Stage = struct;
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Stage.Label = uicontrol('Style', 'text', 'String', 'Stage', 'units', 'normalized', 'Position', [xposition yposition width height], 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color);
        yposition = yposition-dy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Stage.Amount = uicontrol('Style', 'text', 'String', '-', 'units', 'normalized', 'Position', [xposition yposition width height], 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color);        
        
        %Time        
        yposition = yposition-dyy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Time = struct;
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Time.Label = uicontrol('Style', 'text', 'String', 'Time (min)', 'units', 'normalized', 'Position', [xposition yposition width height], 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color);
        yposition = yposition-dy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Time.Amount = uicontrol('Style', 'text', 'String', '0 ', 'units', 'normalized', 'Position', [xposition yposition width height], 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color);                
        
        %Total Reward
        yposition = yposition-dyy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Water = struct;
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Water.Label = uicontrol('Style', 'text', 'String', ['Water (' char(181) 'l)'], 'units', 'normalized', 'Position', [xposition yposition width height], 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color);
        yposition = yposition-dy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Water.Amount = uicontrol('Style', 'text', 'String', '0', 'units', 'normalized', 'Position', [xposition yposition width height], 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color);
        
        %Correct trials        
        yposition = yposition-dyy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Correct = struct;
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Correct.Label = uicontrol('Style', 'text', 'String', 'Correct', 'units', 'normalized', 'Position', [xposition yposition width height], 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color);
        yposition = yposition-dy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Correct.Amount = uicontrol('Style', 'text', 'String', '0', 'units', 'normalized', 'Position', [xposition yposition width height], 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color);                
        
        %Valid trials        
        yposition = yposition-dyy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Valid = struct;
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Valid.Label = uicontrol('Style', 'text', 'String', 'Valid', 'units', 'normalized', 'Position', [xposition yposition width height], 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color);
        yposition = yposition-dy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Valid.Amount = uicontrol('Style', 'text', 'String', '0', 'units', 'normalized', 'Position', [xposition yposition width height], 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color);                
        
        %Total trials        
        yposition = yposition-dyy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Total = struct;
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Total.Label = uicontrol('Style', 'text', 'String', 'Total', 'units', 'normalized', 'Position', [xposition yposition width height], 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color);
        yposition = yposition-dy;  
        BpodSystem.GUIHandles.SummaryAndSaveDisplay.Total.Amount = uicontrol('Style', 'text', 'String', '0', 'units', 'normalized', 'Position', [xposition yposition width height], 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', background_color);                
        
        
    case 'display'
        
        if isfield(BpodSystem.GUIHandles.SummaryAndSaveDisplay,FieldToDisplay)
            BpodSystem.GUIHandles.SummaryAndSaveDisplay.(FieldToDisplay).Amount.String = num2str(ThingToDisplay);
        else
            error('Summary and Save plugin: field not recognized.');
        end        
        
end