function FindTriggers_EEG_Course

path_open = 'D:\PostDoc\NeuroLabData\EEG_Course_January_2022\';
path_save = 'D:\PostDoc\NeuroLabData\EEG_Course_January_2022\SitStandTriggers\';
%name_of_file = 'Expert1_BadChInterp_SYMGEO_05-40Hz.set';

for ggrou = 1:2
if ggrou == 1
    grname='Expert';
    subjectloop = [3 8 53]; % Participant numbers
else
    subjectloop = [2 4 53]; % Participant numbers
    grname='Novice';
end
Cond='_SYMGEO_';
waves={'05-40Hz'};

for subj=1:length(subjectloop)
    for eegra=1:length(waves)

name_of_file = [grname num2str(subjectloop(subj)) '_BadChInterp' Cond waves{eegra} '.set'];
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename', name_of_file, 'filepath', path_open);

% Find already existing triggers in the EEG data
for mm=1:length(EEG.event)
    % convertCharsToStrings Convert character arrays to string arrays and leave others unaltered.
    tst(mm)=convertCharsToStrings(EEG.event(mm).type);
    ts_lat(mm)=convertCharsToStrings(EEG.event(mm).latency);
    ts_latency(mm)=(ts_lat(mm)); 
end
demnrs=[1 2 3 4 5 7 9 11];
for demnr=1:length(demnrs)
for presstyl=1:2
presents={'A' 'G'};

if (demnr==2 && presstyl==2) || (demnr==8 && presstyl==1)
    ss=['0, ' num2str(demnrs(demnr)) presents{presstyl} '_sl01###TEST'];
    ss2=['0, ' num2str(demnrs(demnr)) presents{presstyl} '_end###TEST'];
else
    ss=['0, ' num2str(demnrs(demnr)) presents{presstyl} '_sl1###TEST'];
    ss2=['0, ' num2str(demnrs(demnr)) presents{presstyl} '_end###TEST'];
end

for kk=1:length(tst)
    if strcmp(tst{kk},ss)==1 && strcmp(tst{kk-1},ss)~=1 % '0, 1G_sl1###TEST';
        trig_nr=kk;
        latc=ts_latency(kk)/512; % latency saved as a datapoint, 512 Hz sampling frequency
        [NewTrBeg,NewTrEnd] = Add_SitStand_TriggerLabels_EEG_Course(subjectloop(subj),demnrs,demnr,ss,ss2);
    % set the triggers indicating sitting or standing to the same timepoint
    % with the original triggers
        NewTrBegAr = {NewTrBeg, latc};
        [EEG, eventnumbers] = pop_importevent(EEG, 'event', NewTrBegAr, 'fields', {'type', 'latency'}, ...
          'append', 'yes', 'align', NaN, 'timeunit', 1); % 
    elseif strcmp(tst{kk},ss2)==1 && strcmp(tst{kk-1},ss2)~=1 % '0, 1G_end###TEST'
        trig_nrEND=kk;
        latcEND=ts_latency(kk)/512;
        epochtime(demnr,presstyl)=floor(latcEND-latc);
        epochstart(demnr,presstyl)=latc;
        [NewTrBeg,NewTrEnd] = Add_SitStand_TriggerLabels_EEG_Course(subjectloop(subj),demnrs,demnr,ss,ss2);
    % set the triggers indicating sitting or standing to the same timepoint
    % with the original triggers
        NewTrEndAr = {NewTrEnd, latcEND};
        [EEG, eventnumbers] = pop_importevent(EEG, 'event', NewTrEndAr, 'fields', {'type', 'latency'}, ...
          'append', 'yes', 'align', NaN, 'timeunit', 1); % 
    end  
    
end
end
end
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, ...
'setname', [grname num2str(subjectloop(subj)) Cond waves{eegra} '_SitStandTrigs_NEW'], 'comments',... 
'Data without epoching, filtered high-pass 0.5Hz, low-pass 40Hz, new triggers',...
'savenew', [path_save grname num2str(subjectloop(subj)) Cond waves{eegra} '_SitStandTrigs_NEW.set']);
EEG = eeg_checkset( EEG );
    end
end
end
% epoch_events_oscillation_EEG_Course
end
