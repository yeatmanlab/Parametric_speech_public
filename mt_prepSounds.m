function mt_prepSounds()

% params.sounds(1).name             = 'responseTone'; 

params.sounds(1).name             = 'cueTone'; %to be played simultaneous with pre-cue 
params.sounds(2).name             = 'correctTone'; 
params.sounds(3).name             = 'incorrectTone';
% params.sounds(5).name             = 'fixBreakTone'; 

% params.sounds(1).toneDur         = 0.050; 

params.sounds(1).toneDur         = 0.075;
params.sounds(2).toneDur         = 0.075; 
params.sounds(3).toneDur         = 0.075; 
% params.sounds(5).toneDur         = 0.150; %this is actually 2 incorrect tones concatenated 

% params.sounds(1).toneFreq        = 400; 

params.sounds(1).toneFreq        = 675; 
params.sounds(2).toneFreq        = 600; 
params.sounds(3).toneFreq        = 180; 
% params.sounds(5).toneFreq        = 180; %this is actually 2 incorrect tones concatenated 

params.soundsOutFreq             = 48000; %output sampling frequency 
params.soundsBlankDur            = 0;  %amount of blank time before sound signal starts 

params.doDataPixx               = false;

%% %%%%% Feedbacks sounds:
soundMode = 1; %playback only 
latClass = 0; % 1 is reasonably fast latency, but doesn't take over all sound functionality 

%create sounds ...

%Eyelink seems to use old 'Snd' function in it calibration routine, which
%meses with using PsychPortAudio
%So if we're using eyelink, let's not use PsychPortAudio but instead old
%fasioned Snd

InitializePsychSound;


nblank = round(params.soundsOutFreq*params.soundsBlankDur);

for si=1:3
    nsignl = round(params.soundsOutFreq*params.sounds(si).toneDur); 
    t = (0:(nsignl-1))/params.soundsOutFreq;
    
    params.sounds(si).signal = [zeros(1,nblank) linspace(0.5,0,nsignl)].*[zeros(1,nblank) sin(2*pi*t*params.sounds(si).toneFreq)];
    params.sounds(si).signal = repmat(params.sounds(si).signal,2,1);
    params.sounds(si).freq = params.soundsOutFreq;
    params.sounds(si).nrchannels = size(params.sounds(si).signal,1);
    
end

% Timeout/FixBreak feedback
%Just two repetitions of incorrect sound
% params.sounds(5).signal = repmat(params.sounds(3).signal,1,2);
% params.sounds(5).freq = params.soundsOutFreq;
% params.sounds(5).nrchannels = size(params.sounds(5).signal,1);


devNum = 7; %'8=sysdefault'

%Make buffers
for si=1:length(params.sounds)
    params.sounds(si).handle = PsychPortAudio('Open', devNum, soundMode, latClass, params.sounds(si).freq, params.sounds(si).nrchannels);
    PsychPortAudio('FillBuffer', params.sounds(si).handle, params.sounds(si).signal);
end

%Play a sound to load up the sound engine (avoid delay on first feedback beep)
PsychPortAudio('Start', 0, 1, [], [], GetSecs+.5);
