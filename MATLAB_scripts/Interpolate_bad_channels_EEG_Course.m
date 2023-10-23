function Interpolate_bad_channels_EEG_Course
% Interpolating bad channnels and saving the dataset

for subgr = 1:2
if subgr == 1
    grname='Expert'; 
    subjectloop =[3 8 53];
    % Bad channels Expert1: 65 66 110; Expert3: 11; Expert53: 19 54 115
    
    interpArray = {[65 66 110] % Expert1: 65 66 110
                [11] % Expert3: 11
                [19 54 115] % Expert53: 19 54 115
                }; 
else
    subjectloop = [2 4 53];
    grname='Novice';
    % Bad channels Novice2: 19 31 36 90 94 % Novice4: 13 36 55 67; Novice53: 13 19 
        interpArray = {[19 31 36 90 94] % Novice2: 19 31 36 90 94
            [13 36 55 67] % Novice4: 13 36 55 67
            [13 19] % Novice53: 13 19     
            }; 
end

%% Process       

% open EEGLAB
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
path_open='D:\PostDoc\NeuroLabData\Preprocessed_EEG_Course\'; 

for subj = 1:length(subjectloop)
    for cond=1:1
    if cond==1
        condi='SYMGEO';
    else
        condi='BASELINE';
    end
       
    % e.g. Novice2_ICArejected_SYMGEO_05-40Hz
    open_file=[grname num2str(subjectloop(subj)) '_ICArejected_' condi '_05-40Hz.set'];      
    % load data 
    EEG = pop_loadset( 'filename', open_file, 'filepath', path_open);
    % choosing channels to interpolate
    EEG = pop_select(EEG, 'channel',1:129);            
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    eeglab redraw
    % load electrode locations
    EEG = pop_editset(EEG, 'chanlocs',  'C:\Users\hanna\OneDrive\Documents\PostDoc\DataAnalysis\CA-203_EEGO_2.elc');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    eeglab redraw
    % interpolate
       EEG = eeg_interp(EEG, interpArray{subj}, 'invdist'); %'spherical');

    save_file=[grname num2str(subjectloop(subj)) '_BadChInterp_' condi '_05-40Hz.set'];
    
    % save the dataset
    EEG = pop_saveset (EEG, 'filename', save_file, 'filepath', path_open);
    EEG = eeg_checkset( EEG );
 
    eeglab redraw
    % close files which are open to save memory of the computer
    fclose all;

    end    
end
end
end