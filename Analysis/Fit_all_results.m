% This scripts fits all the subjects to psychometric functions, based on
% the contents of a subject list.

close all
clear

% Get the subject list from the directory of results
file_list = dir('../Results/Psychometrics/Raw');

sid_list = {};

for i = 3:length(file_list)
    fname = file_list(i).name;
    s = strsplit(fname, {'_','.'});
    sid = s{3};
    
    
    sid_list{i-2} = sid;
end

% Just take the unique values of the sid list
%sid_list = unique(sid_list);


% For each, compute the fit
for i = 1:length(sid_list)
    
    % Inputs: subject id, continuum, width of rectangular prior
    try
        read_psychometric_and_fit(sid_list{i},100,0.15)
    catch
        warning('oops!')
    end
    
    try
        read_psychometric_and_fit(sid_list{i},300,0.15)
    catch
        warning('oops!')
    end
    
end

