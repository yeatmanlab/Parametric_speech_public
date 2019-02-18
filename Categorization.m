% This script runs a categorization experiment, in which listeners hear two
% ends of the continuum (ba,da, sa, or sha) and then a third stimulus. They
% must then click on the appropriate button, categorizing the stimulus.
%
% The layout should be two buttons in the center of the screen. For now,
% they should read 1 and 2. The buttons should change color whenever the
% corresponding sound is being played. Maybe not true buttons- just boxes
% on the screen. 
% New features: kid friendly pictures
% Now using Psychport Audio

   % Categorization_orig(SubjectCode,stim_path,results_path, form)
% This script runs a categorization experiment, in which listeners hear two
% ends of the continuum (ba,da, sa, or sha) and then a third stimulus. They
% must then click on the appropriate button, categorizing the stimulus.
%
% The layout should be two buttons in the center of the screen. For now,
% they should read 1 and 2. The buttons should change color whenever the
% corresponding sound is being played. Maybe not true buttons- just boxes
% on the screen. 
% New features: kid friendly pictures
% Now using Psychport Audio


function Categorization(varargin)

% Pass in the parameters
if nargin < 1
    SubjectCode = 'nnn';
    stim_path = './Stimuli';
    results_path = './Results';
    form = 'A';
    single_interval = 0;
    
else
    SubjectCode = varargin{1};
    stim_path = varargin{2};
    results_path = varargin{3};
    form = varargin{4};
end

test_cue = 'Sa_Sha';

% Call some default settings
PsychDefaultSetup(2);
InitializePsychSound


% Disable keys except the arrows
RestrictKeysForKbCheck([115, 117, 66, 10])
% Get the screen numbers
screens = Screen('Screens');

% Select the external screen if it is present, else revert to native screen
screenNumber = max(screens);

% Define colors 
background = [242,233,220] ./ 255;

% Open an on screen window and color it
[window, ~] = PsychImaging('OpenWindow', screenNumber, background);
HideCursor(window); % Hide the cursor

% Get the size of the onscreen window in pixels
[screenXpixels, screenYpixels] = Screen('WindowSize', window);




%% Load in sounds

% Some parameters for the audio
stim_list_dir = './Stim_List';
% Set interstumulus interval
ITI = 0.5; % set intertrial interval
% Presentations per stimulus per block
num_trials_each = 5; 
% get endpoint labels
end_pt_1_label = 'Sha';
end_pt_2_label = 'Sa';


% Work the lists into 
if strcmp(form, 'A')
    order = ['A','B','A'];
else
    order = ['B','A','B'];
end

shuffled_list = [];
for i = 1:length(order)
   
   % Read in the list 
   stim_list_file_base = ['stimlist_' test_cue '_' order(i) '.txt'];
   list_base = read_list([stim_list_dir '/' stim_list_file_base]);
   shuffled_list_tmp = permute_list(list_base, num_trials_each);
   shuffled_list = [shuffled_list, shuffled_list_tmp];   
    
end

imageLocation = './Images';

strcmp(test_cue, 'Sa_Sha')
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

% make the destination rectangles for our image

dstRects = zeros(4, 2);
theRect1 = [0 0 imageWidth1 imageHeights];
theRect2 = [0 0 imageWidth2 imageHeights];

dstRects(:,1) = CenterRectOnPointd(theRect1, screenXpixels/4, screenYpixels/2);
dstRects(:,2) = CenterRectOnPointd(theRect2, screenXpixels*(3/4), screenYpixels/2);


%% Load in images
imageLocation = './Images';

strcmp(test_cue, 'Sa_Sha')
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

% make the destination rectangles for our image

dstRects = zeros(4, 2);
theRect1 = [0 0 imageWidth1 imageHeights];
theRect2 = [0 0 imageWidth2 imageHeights];

dstRects(:,1) = CenterRectOnPointd(theRect1, screenXpixels/4, screenYpixels/2);
dstRects(:,2) = CenterRectOnPointd(theRect2, screenXpixels*(3/4), screenYpixels/2);

%% Set up where to save results
repeat_number = 1;
results_file_base = [SubjectCode '_' num2str(repeat_number) '.txt'];
results_file = [results_path '/' results_file_base];

% Check if this file already exists
while exist(results_file) == 2
    
    %update the repeat number and then the file name
    repeat_number = repeat_number + 1;
    results_file_base = [SubjectCode '_' num2str(repeat_number) '.txt'];
    results_file = [results_path '/' results_file_base];
end

output_pointer = fopen(results_file, 'w');

data_header_row = 'trial,stimulus,sound1,sound2,selection,RT';
timestamp = fix(clock);
fprintf(output_pointer, '%d-%d-%d,%d:%d:%d\n', timestamp(1),timestamp(2),timestamp(3),timestamp(4),timestamp(5),timestamp(6));
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
stimulus_step(i) = str2num(tmp_str{2});
stimulus_dur(i) = str2double(tmp_str{3});
end

%% Open the default audio device
PsychPortAudio('Close');
pahandle = PsychPortAudio('Open', [],[],0,freq,2);

%% Make a vector to store the percent classified as end_pt_1 for plotting at the end
% How many steps are in the continuum?
num_steps_in_continuum = max(stimulus_step);
psychometric = zeros(2, num_steps_in_continuum);

% Remind of the rules
instrIm = imread('Instructions.jpg');
theRect = [0 0 screenXpixels screenYpixels];
dstRect = CenterRectOnPointd(theRect, screenXpixels/2, screenYpixels/2);
instTexture = Screen('MakeTexture', window, instrIm);

Screen('DrawTexture', window, instTexture,[],dstRect);
Screen('Flip', window);   
WaitSecs(4)


%% ***********************FIRST BLOCK****************************
for j = 1:35
   % Starting screen
    
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
        psychometric(round((stimulus_dur(j)*2)/1000)+1, stimulus_step(j)) = psychometric(round((stimulus_dur(j)*2)/1000) + 1, stimulus_step(j))+1;
    elseif strcmp(kbNameResult, 'ESCAPE')
        RestrictKeysForKbCheck([])
        sca
        ShowCursor;
    else
        selection = 'NA';
    end
    
    
    % Write to file
    output_pointer = fopen(results_file, 'a');
    fprintf(output_pointer, '%d,%s,%s,%s,%s,%d\n',...
        j, ... %d
        shuffled_list{j}, ... %s
        'NA', ... %s
        'NA', .... %s,
        selection, ... %s
        Response_time); %d
    fclose(output_pointer);
    
    % Increment the psychometric function by
    WaitSecs(ITI);
    
end

%%%%%%%%%%%%%%%%% REWARD %%%%%%%%%%%%%%%%%5
        % Display progress 
rewardIm = imread('Level_1_Success.jpg');
        
theRect = [0 0 screenXpixels screenYpixels];
dstRect = CenterRectOnPointd(theRect, screenXpixels/2, screenYpixels/2);
rewardTexture = Screen('MakeTexture', window, rewardIm);
        
Screen('DrawTexture', window, rewardTexture,[],dstRect);
Screen('Flip', window);
WaitSecs(4)

% Break?
instrIm = imread('Break.jpg');
instTexture = Screen('MakeTexture', window, instrIm);

Screen('DrawTexture', window, instTexture,[],dstRect);
Screen('Flip', window);
% Wait for a key press
wait4Space = 0;
while ~wait4Space
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
    if keyIsDown
        wait4Space = 1;
    end
end

% Then display the instructions
instrIm = imread('Instructions.jpg');
theRect = [0 0 screenXpixels screenYpixels];
dstRect = CenterRectOnPointd(theRect, screenXpixels/2, screenYpixels/2);
instTexture = Screen('MakeTexture', window, instrIm);

Screen('DrawTexture', window, instTexture,[],dstRect);
Screen('Flip', window);
WaitSecs(4)

%%%%%%%%%%%%%%%%%%% SECOND BLOCK ###########################
for j = 36:70
    %% Starting screen
    
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
        psychometric(round((stimulus_dur(j)*2)/1000)+1, stimulus_step(j)) = psychometric(round((stimulus_dur(j)*2)/1000) + 1, stimulus_step(j))+1;
    elseif strcmp(kbNameResult, 'ESCAPE')
        RestrictKeysforKbCheck([])
        sca
        ShowCursor;
    else
        selection = 'NA';
    end
    
    
    % Write to file
    output_pointer = fopen(results_file, 'a');
    fprintf(output_pointer, '%d,%s,%s,%s,%s,%d\n',...
        j, ... %d
        shuffled_list{j}, ... %s
        'NA', ... %s
        'NA', .... %s,
        selection, ... %s
        Response_time); %d
    fclose(output_pointer);
    
    % Increment the psychometric function by
    WaitSecs(ITI);
    
end


%%%%%%%%%%%%%%%%% REWARD %%%%%%%%%%%%%%%%%5
        % Display progress 
rewardIm = imread('Level_2_Success.jpg');
        
theRect = [0 0 screenXpixels screenYpixels];
dstRect = CenterRectOnPointd(theRect, screenXpixels/2, screenYpixels/2);
rewardTexture = Screen('MakeTexture', window, rewardIm);
        
Screen('DrawTexture', window, rewardTexture,[],dstRect);
Screen('Flip', window);
WaitSecs(4)
% Break?
instrIm = imread('Break.jpg');
instTexture = Screen('MakeTexture', window, instrIm);

Screen('DrawTexture', window, instTexture,[],dstRect);
Screen('Flip', window);
% Wait for a key press
wait4Space = 0;
while ~wait4Space
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
    if keyIsDown 
        wait4Space = 1;
    end
end

% Then display the instructions
instrIm = imread('Instructions.jpg');
theRect = [0 0 screenXpixels screenYpixels];
dstRect = CenterRectOnPointd(theRect, screenXpixels/2, screenYpixels/2);
instTexture = Screen('MakeTexture', window, instrIm);

Screen('DrawTexture', window, instTexture,[],dstRect);
Screen('Flip', window);
WaitSecs(4)

%%%%%%%%%%%%%%%%%%% THIRD BLOCK ###########################
for j = 71:105
    % Starting screen
    
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
        psychometric(round((stimulus_dur(j)*2)/1000)+1, stimulus_step(j)) = psychometric(round((stimulus_dur(j)*2)/1000) + 1, stimulus_step(j))+1;
    elseif strcmp(kbNameResult, 'ESCAPE')
        RestrictKeysforKbCheck([])
        sca
        ShowCursor;
    else
        selection = 'NA';
    end
    
    
    % Write to file
    output_pointer = fopen(results_file, 'a');
    fprintf(output_pointer, '%d,%s,%s,%s,%s,%d\n',...
        j, ... %d
        shuffled_list{j}, ... %s
        'NA', ... %s
        'NA', .... %s,
        selection, ... %s
        Response_time); %d
    fclose(output_pointer);
    
    % Increment the psychometric function by
    WaitSecs(ITI);
    
end


%%%%%%%%%%%%%%%%% REWARD %%%%%%%%%%%%%%%%%5
        % Display progress 
rewardIm = imread('Level_3_Success.jpg');
        
theRect = [0 0 screenXpixels screenYpixels];
dstRect = CenterRectOnPointd(theRect, screenXpixels/2, screenYpixels/2);
rewardTexture = Screen('MakeTexture', window, rewardIm);
        
Screen('DrawTexture', window, rewardTexture,[],dstRect);
Screen('Flip', window);
WaitSecs(4)

% Clear the screen
sca
PsychPortAudio('Close')
RestrictKeysForKbCheck([]);
% Plot the psychometric for the experimenter
psychometric_viewer(psychometric, 15)

end


                                                      
