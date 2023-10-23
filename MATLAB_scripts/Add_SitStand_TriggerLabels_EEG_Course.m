function [NewTrBeg,NewTrEnd] = Add_SitStand_TriggerLabels_EEG_Course(ParticNr,demnrs,demnr,ss,ss2) % 

% Participant 4, 53, 8: sitting: 1 2 5 7 ; standing: 3 4 6 8  
% -> with the stimulus codes, sitting: 1 2 5 9, standing: 3 4 7 11  1A & 1G etc.
% Participant 2, 3: sitting: 3 4 6 8
% ; standing: 1 2 5 7
% -> with the stimulus codes, sitting: 3 4 7 11, standing: 1 2 5 9 

% PatricNr = Number of the participant, eg. Expert53 or Novice53 because
% Expert53 and Novice53 saw the same math demonstrations in the same order,
% same for Expert2 and Novice2 etc.

if ((demnrs(demnr)==1 || demnrs(demnr)==2 || demnrs(demnr)==5 || demnrs(demnr)==9) && ...
        (ParticNr==4 || ParticNr==53 || ParticNr==8 )) || ...
    ((demnrs(demnr)==3 || demnrs(demnr)==4 || demnrs(demnr)==7 || demnrs(demnr)==11) && ...
        (ParticNr==2 || ParticNr==3))
    NewTrBeg=[ss '_Sit']; % the during these math demonstrations, the participants was sitting
    NewTrEnd=[ss2 '_Sit'];
else
    NewTrBeg=[ss '_Stand']; % the during these math demonstrations, the participants was standing
    NewTrEnd=[ss2 '_Stand'];
end
end


