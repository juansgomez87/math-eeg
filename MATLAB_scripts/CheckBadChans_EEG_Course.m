function CheckBadChans_EEG_Course

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
subjectloop={'Expert53'}; % Participant codes        
for subj = 1:length(subjectloop)
    path_open = 'D:\PostDoc\NeuroLabData\Preprocessed_EEG_Course\'; 
    name_of_file=[subjectloop{subj} '_SYMGEO_05-40Hz_preprocessed.set'];
    EEG = pop_loadset('filename', name_of_file, 'filepath', path_open);
[chns, frms]=size(EEG.data);
for cha=1:chns-1 % 128 EEG channels (channel 129 is heartbeat)
    forgfp(cha,1:frms)=EEG.data(cha,1:frms); % ,ee
    gfp(cha,1)=std(forgfp(cha,:)); % ,ee
    if gfp(cha,1)>50 
        disp(subjectloop(subj))
        disp('Channel')
        disp(num2str(cha))
        disp('Value')
        disp(gfp(cha,1))
    end
end
end
end
    