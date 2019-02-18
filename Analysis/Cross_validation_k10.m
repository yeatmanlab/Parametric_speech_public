% This function returns the goodness-of-fit for repeated cross-validation
function [fold_likelihood] = Cross_validation_k10(subject_id, duration, width)


% Add psignifit toolbox path
addpath('/usr/local/MATLAB/R2017a/toolbox/psignifit')

% Read in the raw data for this subject
filename1 = ['../Results/Raw/' subject_id '_1.txt' ];
filename2 = ['../Results/Raw/' subject_id '_2.txt' ];
T1 = readtable(filename1);
T2 = readtable(filename2);

T = [T1; T2];

if duration == 100
    list = ['Step_1_100.wav'; 'Step_2_100.wav'; 'Step_3_100.wav';
    'Step_4_100.wav'; 'Step_5_100.wav';'Step_6_100.wav';'Step_7_100.wav'];
else
    list = ['Step_1_300.wav'; 'Step_2_300.wav'; 'Step_3_300.wav';
    'Step_4_300.wav'; 'Step_5_300.wav';'Step_6_300.wav';'Step_7_300.wav'];
end

T = T(ismember(T.stimulus, list),:);

% Get the psychometric values after removing a single data point
nrow = 1:105;
fold_likelihood = zeros(1, 10);

% Assign groups to each data point
T.indices = crossvalind('Kfold', length(nrow), 10);

for i = 1:10
   
    % Get the data sans the leaveout point
    rows = T.indices ~= i;
    vars = {'trial','stimulus','selection','RT','indices'};
    T_tmp = T(rows, vars);
    % Get all the indices that are in the fold
    rows = T.indices == i;
    obsv_T = T(rows, vars);

% Get the percent correct at each step in the training set
    for this_step = 1:7
        step = T_tmp(ismember(T_tmp.stimulus, ['Step_' ,num2str(this_step), '_' num2str(duration) '.wav']),:);
        sel = table2array(step(:,3))';
        idx = strfind(sel, 'Sa');
        idx = find(not(cellfun('isempty', idx))); %#ok<STRCL1>
        nCorr_T1(this_step) = length(idx);
        nPres_T1(this_step) = length(sel);
    end


    A_data_T1 = [1:7; nCorr_T1; nPres_T1]';


    %% Fit the psychometric function
    % Options for fitting
    options = struct;
    options.expType = 'YesNo';
    options.sigmoidName = 'logistic';
    options.useGPU = 1;

    % Set the width slope parameters correctly

    % minimum = minimal difference of two stimulus levels
    widthmin = 1;
    % We use the same prior as we previously used... e.g. we use the factor by
    % which they differ for the cumulative normal function
    Cfactor   = (my_norminv(.95,0,1) - my_norminv(.05,0,1))./( my_norminv(1-0.05,0,1) - my_norminv(0.05,0,1));
    % add a cosine devline over 2 times the spread of the data
    options.priors{2} = @(x) ((x.*Cfactor)>=widthmin).*((x.*Cfactor)<=2*widthmin).*(.5-.5*cos(pi.*((x.*Cfactor)-widthmin)./widthmin))...
        + ((x.*Cfactor)>2*widthmin).*((x.*Cfactor)<= 40);

    if width == 0
        options.fixedPars = NaN(5,1);
        options.fixedPars(3) = 0;
        options.fixedPars(4) = 0;
    else
        priorLambda = @(x) (x>=0).*(x<=width);
        options.priors{3} = priorLambda;
        options.priors{4} = priorLambda;
    end

    results = psignifit(A_data_T1, options);
    %% Assess the deviance on the other half of the dataset
    x = results.data(:,1);
    fit_values = (1-results.Fit(3)-results.Fit(4))*arrayfun(@(x) results.options.sigmoidHandle(x,results.Fit(1),results.Fit(2)),x)+results.Fit(4);
    
    % LOOP OVER points in held-out fold
    % Did we choose "sa" or "sha" on the observation case? 
    in_fold_likelihood = zeros(1, height(obsv_T));
    for j = 1:height(obsv_T)
        obsv_stimulus = regexp(obsv_T.stimulus{j},'\d*','Match');
        obsv_step = str2double(obsv_stimulus{1});
    
        % Did they get it right?
        if strcmp(obsv_T.selection{j}, 'Sa') 
            p = fit_values(obsv_step);
        else
            p = 1 - fit_values(obsv_step);
        end

        in_fold_likelihood(j) = log(p);
    end
    
    % What is the error on this part? Equal to the sum of the
    % log-likelihoods of heldout points. 
    fold_likelihood(i) = sum(in_fold_likelihood);
end
