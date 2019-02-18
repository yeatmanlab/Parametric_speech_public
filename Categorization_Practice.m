% This script presents the categorization task practice.

function Categorization_Practice(varargin)

% Pass in the parameters
if nargin < 1
    SubjectCode = 'nnn';
    test_cue = 'Sa_Sha';
    stim_path = './Stimuli';
    results_path = './Results';

else
    SubjectCode = varargin{1};
    test_cue = varargin{2};
    stim_path = varargin{3};
    results_path = varargin{4};

end



% Call some default settings
PsychDefaultSetup(2);
InitializePsychSound
kb = InitKeyboard;


% Disable keys except the arrows
oldenablekeys = RestrictKeysForKbCheck([kb.escKey, kb.spaceKey, kb.downKey, kb.rightKey]);

% Get the screen numbers
screens = Screen('Screens');


% Select the external screen if it is present, else revert to native screen
screenNumber = max(screens);

% Define colors
background = [242,233,220] ./ 255;

% Open an on screen window and color it
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, background);
HideCursor(window);

% Get the size of the onscreen window in pixels
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

%% Load in sounds
stim_list_dir = './Stim_List';
stim_list_file_base = ['stimlist_practice_' test_cue '.txt'];

list_base = read_list([stim_list_dir '/' stim_list_file_base]);

% Identify the endpoints of the continuum
end_pt_1_label = 'Sha';
end_pt_2_label = 'Sa';

% We only want the long ones  


% first extreme
play_file = [stim_path '/' list_base{1}];
[audio, freq] = audioread(play_file);
cont_end_1 = [audio';audio'];

% second extreme
play_file = [stim_path '/' list_base{7}];
[audio, freq] = audioread(play_file);
cont_end_2 = [audio';audio'];

% Set interstumulus interval
ITI = 0.5; % time between trials

num_trials_each = 4; % How many times each stimulus will be presented
shuffled_list = permute_list([list_base(1) list_base(7)], num_trials_each);

%% Load in images
imageLocation = './Images';

% Identify the images corresponding to the endpoints
end_pt_1_image_name = 'snake_1.png';
end_pt_2_image_name = 'snake_2.png';
end_pt_1_image_name_glow = 'snake_1_glow.png';
end_pt_2_image_name_glow = 'snake_2_glow.png';

image_1 = imread([imageLocation '/' end_pt_1_image_name], 'BackgroundColor', background);
image_1_glow = imread([imageLocation '/' end_pt_1_image_name_glow], 'BackgroundColor', background);
image_2 = imread([imageLocation '/' end_pt_2_image_name], 'BackgroundColor', background);
image_2_glow = imread([imageLocation '/' end_pt_2_image_name_glow], 'BackgroundColor', background);


% Get size of images
[s11, s21, ~] = size(image_1);
[s12, s22, ~] = size(image_2);

aspect_ratio_1 = s21/s11;
aspect_ratio_2 = s22/s12;

imageHeights = 800;
imageWidth1 = imageHeights .* aspect_ratio_1;
imageWidth2 = imageHeights .* aspect_ratio_2;

imageTexture1 = Screen('MakeTexture', window, image_1);
imageTexture2 = Screen('MakeTexture', window, image_2);
imageTexture1_glow = Screen('MakeTexture', window, image_1_glow);
imageTexture2_glow = Screen('MakeTexture', window, image_2_glow);


% Get the feedback images
correct_image_name = 'correct.png';
incorrect_image_name = 'incorrect.png';

correct_image = imread([imageLocation '/' correct_image_name], 'BackgroundColor', background);
incorrect_image = imread([imageLocation '/' incorrect_image_name], 'BackgroundColor', background);
correctTexture = Screen('MakeTexture', window, correct_image);
incorrectTexture = Screen('MakeTexture', window, incorrect_image);
[s1, s2, ~] = size(correctTexture);
aspect_ratio = s2/s1;
feedback_Height = 500;
feedback_Width = feedback_Height .* aspect_ratio;



% make the destination rectangles for our image

dstRects = zeros(4, 2);
theRect1 = [0 0 imageWidth1 imageHeights];
theRect2 = [0 0 imageWidth2 imageHeights];
corRect = [0 0 feedback_Width feedback_Height];

dstRects(:,1) = CenterRectOnPointd(theRect1, screenXpixels/4, screenYpixels/2);
dstRects(:,2) = CenterRectOnPointd(theRect2, screenXpixels*(3/4), screenYpixels/2);
dstRects(:,3) = CenterRectOnPointd(corRect, screenXpixels*0.5, screenYpixels*0.5);


%% Set up where to save results
repeat_number = 1;
results_file_base = [SubjectCode '_categorization_practice_' test_cue '_' num2str(repeat_number) '.txt'];
results_file = [results_path '/' results_file_base];

% Check if this file already exists
while exist(results_file) == 2
    
    %update the repeat number and then the file name
    repeat_number = repeat_number + 1;
    results_file_base = [SubjectCode '_categorization_practice_' test_cue '_' num2str(repeat_number) '.txt'];
    results_file = [results_path '/' results_file_base];
end

output_pointer = fopen(results_file, 'w');

data_header_row = 'trial,stimulus,selection,RT';
%timestamp = datestr(datetime('now'));
timestamp = fix(clock);
fprintf(output_pointer, '%d-%d-%d,%d:%d:%d\n', timestamp(1),timestamp(2),timestamp(3),timestamp(4),timestamp(5),timestamp(6));
%fprintf(output_pointer, '%s\n', timestamp);
fprintf(output_pointer, '%s\n',data_header_row);
fclose(output_pointer);


%% Load up all the sounds in a buffer

for i = 1:length(shuffled_list)
    % Select at random a sound from the continuum
    play_file = [stim_path '/' shuffled_list{i}];
    [audio, freq] = audioread(play_file);
    test_wavedata{i} = [audio'; audio'];
    
    % Want to know the stimulus step, for plotting our psychometric at the end
    tmp_str = strsplit(shuffled_list{i}, {'_','.'});
    stimulus_step(i) = str2double(tmp_str{2});
end



%% Make a vector to store the percent classified as end_pt_1 for plotting at the end
% How many steps are in the continuum?
num_steps_in_continuum = length(list_base);
psychometric = zeros(1, num_steps_in_continuum);

%% Open the default audio device

pahandle = PsychPortAudio('Open', [],[],0,freq,2);


%% ************************MAIN EXPERIMENT LOOP****************************

% Display the "Listen" instruction
instrIm = imread('Listen.jpg');
theRect = [0 0 screenXpixels screenYpixels];
dstRect = CenterRectOnPointd(theRect, screenXpixels/2, screenYpixels/2);
instTexture = Screen('MakeTexture', window, instrIm);

Screen('DrawTexture', window, instTexture,[],dstRect);
Screen('Flip', window);   
WaitSecs(2)



% First, play through the stimuli a few times.
% Draw two animals
Screen('DrawTextures', window, imageTexture1, [], dstRects(:,1));
Screen('DrawTextures', window, imageTexture2, [], dstRects(:,2))

% Flip to the screen
Screen('Flip', window);


%% Play the first end of the continuum

% Color the correct button
% Flip window and start playing sound
use_end = cont_end_1;
Screen('DrawTextures', window, imageTexture1_glow, [], dstRects(:,1));
Screen('DrawTextures', window, imageTexture2, [], dstRects(:,2));


sound1_start = Screen('Flip', window);
PsychPortAudio('FillBuffer', pahandle, use_end);
PsychPortAudio('Start', pahandle, 1,[]);
PsychPortAudio('Stop', pahandle, 1);
WaitSecs(0.5);
PsychPortAudio('FillBuffer', pahandle, use_end);
PsychPortAudio('Start', pahandle, 1,[]);
PsychPortAudio('Stop', pahandle, 1);
WaitSecs(0.5);
PsychPortAudio('FillBuffer', pahandle, use_end);
PsychPortAudio('Start', pahandle, 1,[]);
PsychPortAudio('Stop', pahandle, 1);
WaitSecs(1);
%% Play the second end of the continuum

use_end = cont_end_2;
Screen('DrawTextures', window, imageTexture1, [], dstRects(:,1));
Screen('DrawTextures', window, imageTexture2_glow, [], dstRects(:,2))



sound2_start = Screen('Flip', window);
PsychPortAudio('FillBuffer', pahandle, use_end);
PsychPortAudio('Start', pahandle, 1,[]);
PsychPortAudio('Stop', pahandle, 1);
WaitSecs(0.5);
PsychPortAudio('FillBuffer', pahandle, use_end);
PsychPortAudio('Start', pahandle, 1,[]);
PsychPortAudio('Stop', pahandle, 1);
WaitSecs(0.5);
PsychPortAudio('FillBuffer', pahandle, use_end);
PsychPortAudio('Start', pahandle, 1,[]);
PsychPortAudio('Stop', pahandle, 1);


%% Instruct the participant to try
instrIm = imread('You_Try.jpg');
theRect = [0 0 screenXpixels screenYpixels];
dstRect = CenterRectOnPointd(theRect, screenXpixels/2, screenYpixels/2);
instTexture = Screen('MakeTexture', window, instrIm);

Screen('DrawTexture', window, instTexture,[],dstRect);
Screen('Flip', window);   
WaitSecs(2)

instrIm = imread('Instructions.jpg');
theRect = [0 0 screenXpixels screenYpixels];
dstRect = CenterRectOnPointd(theRect, screenXpixels/2, screenYpixels/2);
instTexture = Screen('MakeTexture', window, instrIm);

Screen('DrawTexture', window, instTexture,[],dstRect);
Screen('Flip', window);   
WaitSecs(4)

%% Now go into the loop
for j = 1:length(shuffled_list)
    

    
    
    
    % Draw two animals
    Screen('DrawTextures', window, imageTexture1, [], dstRects(:,1));
    Screen('DrawTextures', window, imageTexture2, [], dstRects(:,2));
    
    % Flip to the screen
    Screen('Flip', window);
    PsychPortAudio('FillBuffer', pahandle, test_wavedata{j});
    PsychPortAudio('Start', pahandle, 1,[]);
    PsychPortAudio('Stop', pahandle, 1);
    reps_start_time = GetSecs;
    keyPress = 0;
    
    % Wait for a keystroke to terminate
    while keyPress ==0
        [keyPress, secs, keyCode] = KbCheck();
        
    end
    
    Response_time = secs - reps_start_time;
    
    % Categorize as choice 1 or choice 2
    kbNameResult = KbName(keyCode);
    disp(kbNameResult)
    if strcmp(kbNameResult,'DownArrow')
        selection = end_pt_1_label;
    elseif strcmp(kbNameResult,'RightArrow')
        selection = end_pt_2_label;
    elseif keyCode(kb.escKey)
        Screen('CloseAll');
        PsychPortAudio('Close')
        ShowCursor;
        break;
    else
        selection = 'NA';
    end
    
    % Give feedback to the participant- correct or incorrect?
    if strcmp(selection, end_pt_1_label) && stimulus_step(j) == 1
        Screen('DrawTextures', window, correctTexture, [], dstRects(:,3));
    elseif strcmp(selection, end_pt_2_label) && stimulus_step(j) == 7
        Screen('DrawTextures', window, correctTexture, [], dstRects(:,3));
    else
        Screen('DrawTextures', window, incorrectTexture, [], dstRects(:,3));
    end
    
    Screen('Flip', window)
    
    % Write to file
    output_pointer = fopen(results_file, 'a');
    fprintf(output_pointer, '%d,%s,%s,%d\n',...
        j, ... %d
        shuffled_list{j}, ... %s
        selection, ... %s
        Response_time); %d
    
    
    % Increment the psychometric function by
    WaitSecs(ITI);
    
end
    

% Clear the screen
sca
PsychPortAudio('Close');
return 


end
