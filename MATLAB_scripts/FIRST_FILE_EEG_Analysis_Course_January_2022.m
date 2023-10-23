FIRST_FILE_EEG_Analysis_Course_January_2022
% Functions we go through during the course

 1 Preprocessing_128Ch_EEG_Course
 2 CheckBadChans_EEG_Course
% -> manually type in bad channels
 3 call_ICA_oscillation_EEG_Course (calls ICA_oscillation_EEG_Course)
% -> remove ICA channels manually
 4 Interpolate_bad_channels_EEG_Course
 5 FindTriggers_EEG_Course
 6 Add_SitStand_TriggerLabels_EEG_Course (calls Add_SitStand_TriggerLabels_EEG_Course)
 7 Epoch_events_oscillation_EEG_Course (calls Separate_epochs_oscillation_EEG_Course)
 
% Options for further analysis: Amplitude power, phase frequency, Phase-Amplitude
% Coupling, Event Related Potential, Event Related Synchrony/Descynhrony,
% Source Localization

% Statistical analysis: T-test, ANOVA (type of ANOVA depends on the study
% design)