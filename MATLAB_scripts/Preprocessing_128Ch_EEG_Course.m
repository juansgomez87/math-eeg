function Preprocessing_128Ch_EEG_Course
% download EEGLAB: https://sccn.ucsd.edu/eeglab/download.php
% ans add it through Set Path
% download ANT EEProbe for pop_loadeep_v4 to work: 
% https://www.ant-neuro.com/support/supporting-documentation-and-downloads
% add CA-203_EEGO_2.elc file

% NOTE !!! ECG data is at the channel 129 !!!

% folder for the folder file in which the data is saved
save_path = 'D:\PostDoc\NeuroLabData\Preprocessed_EEG_Course\'; 

% two subject groups
groups={'Expert' 'Novice'};

for ggrou=1:2
    if ggrou==1
        % participants, Experts
        subjectloop = [3 8 53]; % Participant number
        grname='Expert';
    else
        % participants, Novices
        subjectloop = [2 4 53]; % Participant number
        grname='Novice';
    end
    
    for filecnt=1:1
        if filecnt==1
            % EEG + ECG data file with the Symbolic and Geometric math
            % demonstrations
            condi='SYMGEO';
        else
            % EEG + ECG data file with the hearbat perception and
            % the baseline condition: sitting/standing eyes open/closed
            condi='BASELINE';
        end

        for subj = 1:length(subjectloop)

        % opening eeglab
        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

        % path of the folder in which the EEG file is
        ctrlpth = 'D:\PostDoc\NeuroLabData\';

        % load the raw EEG + ECG file
        EEG = pop_loadeep_v4([ctrlpth grname num2str(subjectloop(subj)) '_' condi '.cnt']);
        stremp=EEG();
        empty_struct = isempty(fieldnames(stremp));
        if empty_struct == 1
            return;
        end
        
        % load EEG channel locations from the CA-203_EEGO_2.elc file
        EEG=pop_chanedit(EEG, 'load',{'C:\Users\hanna\OneDrive\Documents\PostDoc\DataAnalysis\CA-203_EEGO_2.elc', 'filetype', 'autodetect'});
        
        % the data was collected in 2048 Hz, I chose to donwsample to 512
        % Hz due to reduce the file size
        EEG = pop_resample( EEG, 512); 
        EEG = eeg_checkset( EEG );

        % re-referencing the data as the average of all the EEG electrodes
        % excluding the eye-movement electrodes
        EEG = pop_reref( EEG, [], 'exclude', [32 54 57 64 129], 'keepref', 'on');
 
        % list of the EEG channels
        EEG = pop_select( EEG, 'channel', {'Fp1', 'Fpz', 'Fp2',	'F7', 'F3',	'Fz', ...
            'F4', 'F8', 'FC5', 'FC1', 'FC2', 'FC6',	'M1', 'T7',	'C3', 'Cz',	'C4', ...
            'T8', 'M2',	'CP5', 'CP1', 'CP2', 'CP6',	'P7', 'P3',	'Pz', 'P4', 'P8', ...
            'POz', 'O1', 'O2', 'HEOGR',	'CPz', 'AF7', 'AF3', 'AF4',	'AF8', 'F5', 'F1', ...
            'F2', 'F6',	'FC3', 'FCz', 'FC4', 'C5', 'C1', 'C2', 'C6', 'CP3',	'CP4', ...
            'P5', 'P1',	'P2', 'P6',	'HEOGL', 'PO3',	'PO4', 'VEOGU',	'FT7', 'FT8', ...
            'TP7', 'TP8', 'PO7', 'PO8', 'VEOGL', 'FT9',	'FT10',	'TPP9h', 'TPP10h', ...
            'PO9', 'PO10',	'P9', 'P10', 'AFF1', 'AFz',	'AFF2',	'FFC5h', 'FFC3h', ...
            'FFC4h', 'FFC6h', 'FCC5h', 'FCC3h', 'FCC4h',	'FCC6h', 'CCP5h', 'CCP3h', ...
            'CCP4h', 'CCP6h', 'CPP5h', 'CPP3h',	'CPP4h', 'CPP6h', 'PPO1', 'PPO2', ...
            'I1', 'Iz',	'I2', 'AFp3h', 'AFp4h',	'AFF5h', 'AFF6h', 'FFT7h', 'FFC1h', ...
            'FFC2h', 'FFT8h', 'FTT9h', 'FTT7h',	'FCC1h', 'FCC2h', 'FTT8h',	'FTT10h', ...
            'TTP7h', 'CCP1h', 'CCP2h', 'TTP8h',	'TPP7h', 'CPP1h', 'CPP2h',	'TPP8h', ...
            'PPO9h', 'PPO5h', 'PPO6h', 'PPO10h', 'POO9h', 'POO3h', 'POO4h',	'POO10h', ...
            'OI1h',	'OI2h'}); % , 'HEART'
        
        EEG = eeg_checkset( EEG );
        stremp=EEG();
        empty_struct = isempty(fieldnames(stremp));
        if empty_struct == 1
            disp('cannot read the data')
            return;
        end
         
        % high-pass filtering for 0.5 Hz if willing to use that
        EEG = pop_eegfilt( EEG, .5, 0,[], [0]);

        %%% VENERA, modify the line below for gamma, 
        %%% read: https://www.sciencedirect.com/science/article/pii/S1053811919309474
        %%% We need to exclude the 50 Hz line noise
        
        % low-pass filtering for 40 Hz if willing to use that
        EEG = pop_eegfilt( EEG, 0, 40, [], [0]);

        % save the new data file
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, ...
        'setname', [grname num2str(subjectloop(subj)) '_' condi '_FiltResampLocs'], 'comments',... 
        'Raw data without epoching, 128-ch avg as reference, filtering: high-pass 0.5Hz, low-pass 40Hz',...
        'savenew', [save_path grname num2str(subjectloop(subj)) '_' condi '_05-40Hz_preprocessed.set']);
            eeglab redraw
 
    fclose all;
        end
    end
end
end
 