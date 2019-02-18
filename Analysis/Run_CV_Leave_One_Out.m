close all
clear

% Parameters of subject
width_vec = 0:0.05:0.3;

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
sid_list = unique(sid_list);

% Check which ones have already been done
file_list = dir('../Results/CV_10');
sid_list2 = {};

for i = 3:length(file_list)
    fname = file_list(i).name;
    s = strsplit(fname, {'_','.'});
    sid = s{2};
    
    
    sid_list2{i-2} = sid;
end

% Just take the unique values of the sid list
sid_list2 = unique(sid_list2);

sid_list = setdiff(sid_list, sid_list2);

parfor j = 1:length(sid_list)
    subject_id = sid_list{j};
    % Loop over all possible widths
    for w = 1:length(width_vec)
        try
        out1  = Cross_validation_k10(subject_id,100, width_vec(w));
            warning('Oops, something went wrong.')

        out2  = Cross_validation_k10(subject_id, 300, width_vec(w))
        
        header = 'SubjectID,block,width,p';
        
        
        fid = fopen(['/home/eobrien/bde/Projects/Parametric/Speech/Results/CV_10/CV_'...
            subject_id, '_', num2str(width_vec(w)),'.csv'], 'w');
        
        fprintf(fid, '%s\n', header);
        for k = 1:length(out1)
            fprintf(fid, '%s,%f,%f,%f\n', subject_id, 100, width_vec(w), out1(k));
            fprintf(fid, '%s,%f,%f,%f\n', subject_id, 300, width_vec(w), out2(k));
        end
        fclose(fid);
        
        catch
             warning('Oops, something went wrong.')
        end
        
        
    end
end
