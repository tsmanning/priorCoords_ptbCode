function [kb] = SetupKeyboard()

% Define keybindings for Sotiropoulos replicaiton/expansion
%
% Usage: [] = SetupKeyboard_PriorXfer()

KbName('UnifyKeyNames');

% Response keys
kb.upkey = KbName('UpArrow');
kb.downkey = KbName('DownArrow');
kb.leftkey = KbName('LeftArrow');
kb.rightkey = KbName('RightArrow');

kb.escapeKey = KbName('ESCAPE'); % quits out of the experiment before its completion
kb.spacebarKey = KbName('space'); % intiates a new trial

% Initialize KbCheck
[kb.keyIsDown, kb.secs, kb.keyCode] = KbCheck(-1);
KbReleaseWait; % Make sure all keys are released
kb.keyWasDown= 0;

end