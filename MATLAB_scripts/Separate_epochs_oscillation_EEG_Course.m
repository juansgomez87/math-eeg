function Separate_epochs_oscillation_EEG_Course(subjectloop, subj, evs, condi, grou, epochtime, ep_e)

freqs={'05-40Hz'};
for waves=1:length(freqs)
    fclose all
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

path_open='D:\PostDoc\NeuroLabData\Preprocessed_EEG_Course\SitStandTriggers\';
path_save='D:\PostDoc\NeuroLabData\Preprocessed_EEG_Course\Epoched\';

open_file = [grou num2str(subjectloop(subj)) condi '05-40Hz_SitStandTrigs.set'];

for MinMax=1:1 %2
 %  try
    EEG = pop_loadset( 'filename', open_file, 'filepath', path_open);
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG); 
    eeglab redraw
    EEG = eeg_checkset( EEG );
    evv=evs{MinMax} % trigger code in the EEG data
    ep_ev=ep_e{MinMax} % trigger for the filename
    try
        EEG = pop_epoch( EEG, {evv}, [0, epochtime(MinMax)], 'newname', [path_save grou num2str(subjectloop(subj)) ...
           condi '_' ep_ev '_' freqs{waves}], 'epochinfo', 'yes');
        save_file=[grou num2str(subjectloop(subj)) ...
           condi ep_ev '_' freqs{waves} '.set']; 
            EEG = eeg_checkset( EEG );
            [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            eeglab redraw
 
            EEG = pop_saveset (EEG, 'filename', save_file, 'filepath', path_save); 
            EEG = eeg_checkset( EEG );

            eeglab redraw      
 
    catch
                disp('no epoch for test subject and event below')
                disp(grou)
                disp(num2str(subjectloop(subj)))
                disp(condi)
                disp(evs{MinMax})
                disp(freqs{waves})
   end   
end
fclose all;
end