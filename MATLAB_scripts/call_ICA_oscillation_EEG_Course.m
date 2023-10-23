function call_ICA_oscillation_EEG_Course

for groupp=1:2
    if groupp==1
        subjectloop=[3 8 53]; % Participant number, Experts
    else
        subjectloop=[2 4 53]; % Participant number, Novices
    end
for subj= 1:length(subjectloop)
            ICA_oscillation_EEG_Course(subjectloop,subj,groupp)
end
end

%interpolate_bad_channels_EEG_Course