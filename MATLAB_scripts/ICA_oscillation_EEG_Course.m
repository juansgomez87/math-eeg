function ICA_oscillation_EEG_Course(subjectloop,subj,groupp)
%called in call_ICA_oscillation

% Bad channels not to be used in the Independent Component Analysis (ICA):
% Expert1: 65 66 110
% Expert3: 11
% Expert53: 19 54 115

% Novice2: 19 31 36 90 94
% Novice4: 13 36 55 67
% Novice53: 13 19

for condi=1:1
    if condi==1
        cond='SYMGEO';
    else
        cond='BASELINE';
    end

if groupp==1
    grname='Expert';
    % Channnels to be included in ICA (excluding bad channels)
    icaChannels={[1:64 67:109 111:128] % Expert1: 65 66 110
            [1:10 12:128] % Expert3: 11
            [1:18 20:53 55:114 116:128] % Expert53: 19 54 115
            };
else
    grname='Novice';
    % Channnels to be included in ICA (excluding bad channels)
    icaChannels={[1:18 20:30 32:35 37:89 91:93 95:128]; % Novice2: 19 31 36 90 94
                  [1:12 14:35 37:54 56:66 68:128] % % Novice4: 13 36 55 67
                  [1:12 14:18 20:128] % Novice53: 13 19
                  }; 
end
         
    [ALLEEG EEG, CURRENTSET ALLCOM] = eeglab;
    path_open = 'D:\PostDoc\NeuroLabData\Preprocessed_EEG_Course\'; 
    name_of_file=[grname num2str(subjectloop(subj)) '_' cond '_05-40Hz_preprocessed.set'];
    EEG = pop_loadset('filename', name_of_file, 'filepath', path_open);
         
    EEG = eeg_checkset( EEG );
    
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG); 
    eeglab redraw
  
    save_file=[grname num2str(subjectloop(subj)) '_ICA_' cond '_05-40Hz.set']; 
    %icaChannels{subj}
    % ajetaan ICA
    %%% The rank function can be finicky, but this is a rare problem. 
    % I usually set the number components manually in my script. 
    % For example ‘pca’,-1 is a new option that allows to decrease the
    % dimensionality by 1. %%%
    % https://sccn.ucsd.edu/wiki/Makoto's_useful_EEGLAB_code ...
    % #How_to_avoid_the_effect_of_rank-deficiency_in_applying_ICA_.2803.2F31.2F2021_added.29
    % https://sccn.ucsd.edu/wiki/Shannon%27s_ICA_rank_project
    % Just something that I found in the runica() script: if you 
    % comment out "drawnow" on line 1047, there is a dramatic speed-up of
    % the script. %%%
    % But there is the repeated code in line 1167 for 'extended' on. 

    % run ICA
    EEG = pop_runica(EEG, 'dataset', 1, 'options',{}, 'chanind', icaChannels{subj}); % ,  'icatype', 'fastica'
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    eeglab redraw
    
    % save the dataset to a file
    EEG = pop_saveset (EEG, 'filename', save_file, 'filepath', path_open);
    EEG = eeg_checkset( EEG );

    eeglab redraw
    fclose all;
end
