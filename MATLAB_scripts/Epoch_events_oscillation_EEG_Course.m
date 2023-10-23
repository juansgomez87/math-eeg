function Epoch_events_oscillation_EEG_Course
% This function will call the function
% Separate_epochs_oscillation_EEG_Course
% To run this function, download EEGlab for Matlab: https://sccn.ucsd.edu/eeglab/index.php

% Refers to the Symbolic Geometric data and not to the Baseline data
condi='_SYMGEO_';

% Symbolic (A), or Geometric (G)
presents={'A' 'G'};

% Number of the demonstration: 1 2 3 4 5 7 9 11

StSt={'_Stand' '_Sit'};
countrounds=1; %4;
epochtime=[52]; 
  % [52 52 54 54 ... %1A 2A
  %  34 34 38 28 ... %3A 4A
  %  32 32 41 41  ... % 5A 7A
  %  19 19 68 68 ... % 9A 11A
  %  27 27 34 34 ... % 1G 2G
  %  18 18 13 13  ... % 3G 4G
  %  27 27 32 32 ... % 5G 7G
  %  25 25 15 15]; % 9G 11G % from FindTriggers_EEG_Course.m
  
  % Symbolic or Geometric presentation
for presstyl=1:1
    
    % number of the demonstration (1 2 3 4 5 7 9 11)
for demnr=1:1 %length(demnrs)
    
    % Sitting or Standing
    for SitSta=1:1 %2
if (demnr==2 && presstyl==2) || (demnr==11 && presstyl==2) %8 1
    % name of the time stamp in the EEG file for 11A and 2G which had more
    % than 10 slides in the presentations, and thus, sl 01 instead of sl 1
    ss=['0, ' num2str(demnr) presents{presstyl} '_sl01###TEST' StSt{SitSta}];
else
    % name of the stamp for other demonstrations which had less than 10
    % slides
    ss=['0, ' num2str(demnr) presents{presstyl} '_sl1###TEST' StSt{SitSta}];
end
evs{countrounds}=ss;
ep_e{countrounds}=[num2str(demnr) presents{presstyl} '_sl1' StSt{SitSta}];
    end
end
end

    for ggrou=1:2
        if ggrou==1
            grou='Expert';
            % subject number
            subjectloop =  [3 8 53]; 
        else
            % subject number
            subjectloop = [2 4 53]; 
            grou='Novice';
        end      
        for subj=1:length(subjectloop)
            Separate_epochs_oscillation_EEG_Course(subjectloop, subj, evs, condi, grou, epochtime, ep_e)    
        end
    end 
    fclose all
end
