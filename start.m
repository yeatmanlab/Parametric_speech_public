PsychJavaTrouble

clear

clc

fprintf('Welcome!\n\n\n');

%subjectName = input('What is your name? ','s');
%fprintf('\n');
subjectIni = input('What is your subject ID? ','s');
fprintf('\n');
%ver = input('Experiment version (1 or 2)?  ');

%flag = input('Score board (0 = no, 1 = yes)? ');

fprintf('\n');
fprintf('Thank you!\n');
fprintf('\n');
fprintf('\n');

doPractice = 1;


% Get the directory we are getting results and stimuli from
basedir = fileparts(which('start'));
stimpath = fullfile(basedir,'Stimuli');
resultspath = fullfile(basedir,'Results');


trial = 1;
while doPractice
    if trial == 1
        aaa = input('Do you want to practice (y/n) ? ','s');
    else
        aaa = input('Do you want to practice more (y/n) ? ','s');
    end
    if strcmp(aaa, 'y')
        Categorization_Practice(subjectIni,'Sa_Sha','./Stimuli', './Results')
        trial = trial + 1;
        clc;
    else
        doPractice = 0;
        clc;
    end
end

doRunMain = 1;

while doRunMain == 1
    aaa = input('Do you want to run the Snake Game (y/n) ? ','s');
    if strcmp(aaa, 'y')
        form_q = input('What version? (a/b) ?','s');
        if strcmp(form_q, 'a') || strcmp(form_q, 'b')
            Categorization(subjectIni, stimpath, resultspath, upper(form_q));
            doRunMain = 0;
        else 
            doRunMain = 0;
        end
    else
        doRunMain = 0;
    end
end