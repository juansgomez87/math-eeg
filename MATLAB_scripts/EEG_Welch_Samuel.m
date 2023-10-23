close all;
clc;

clear
%%
path_open1 = pwd;
folderpath = path_open1;

%%
folderpath2 = fullfile(folderpath, 'eeglab/eeglab2021.0/');
eeglab

%% Run either baseline data or demonstrations
%  Run sections using cmd + enter

%% Baseline
tmaxrun = 0;
tminrun = 15000;
folderpath3 = fullfile('/Users/toblersa/Documents/_EEG/Data/Files/July2021/Baselines'); 

%% Demonstrations
tmaxrun = 1000;
tminrun = 2000;
folderpath3 = fullfile('/Users/toblersa/Downloads/eeglab2021.0/FILES/Files_January2022/')


%% First two seconds
tminrun = 0;
% tmaxrun to be adjusted below
folderpath3 = fullfile('/Users/toblersa/Documents/_EEG/Data/Files/July2021/Symbolic');

%% Window Parameter
% win = window_length * Fs
window_length = 2; % should be 2
% overlap = overlap_factor * win
overlap_factor = 0.5;

%%
filelist   = dir(folderpath3);
name       = {filelist.name};
namex = name(4:length(name));

%%

reps_filelist = (length(namex))/2;

%%
for i = 1:reps_filelist

    k = i*2;
name2 = namex(k);
name3 = name2{1,1};

ICA_set.data = pop_loadset(name3, folderpath3);

% Manual Entry

% ICA_set.data = pop_loadset('Novice9_SYMGEO_5A_sl1_Sit_05-40Hz.set', folderpath); 

ALLEEG = ICA_set.data;

n_channels = ALLEEG.nbchan; % Number of channels

data = ALLEEG.data; % 15 rows of data
t = ALLEEG.times; % in ms: -2000 at the beginning, -1000 at the end


tmin = min(t);
tmax = max(t);

tmin2 = tmin + tminrun; % -2000 for experimental data, -15000 for baseline data
tmax2 = tmax - tmaxrun; % - 1000; % - 1000 for experimental data, 0 for baseline
%tmax2 = 2000;

for i = 1:30000 % from 
    tx = t(i);
    if (tx >= tmin2)
       tmin3pos = i;
       break
    else 
        i = i+1;
    end 
end

tmin3pos;

i = 0;
for i = 1:length(t)
    tx = t(i);
    if (tx >= tmax2)
       tmax3pos = i;
       break
    else 
        i = i+1;
    end 
end

tmax3pos;

% REDUCED ALLEEG

t = ALLEEG.times(tmin3pos:tmax3pos);

data = ALLEEG.data(:,tmin3pos:tmax3pos);


Fs = ALLEEG.srate; % Sampling frequency
T = 1/Fs; % Sampling period 

win = window_length * Fs; % window length (pwelch parameter)
overlap = overlap_factor * win; % Set to 50% overlap (pwelch parameter)

% Bands: Delta  Theta  Alpha  Beta (feel free to re-define!)
f_min = [0.5    4      8      12];
f_max = [4      8     12      30];



int_band_power    = zeros(n_channels, length(f_min)); % Numerically integrate PSD in band range
mean_band_power   = zeros(n_channels, length(f_min)); % Normalize integral with band width
peak_band_power   = zeros(n_channels, length(f_min)); % Peak power within band
f_peak_band_power = zeros(n_channels, length(f_min)); % Frequency of peak power within band

for i = 1:n_channels % n_channels
    y = data(i,:);
    [Pxx, F] = pwelch(y, win, overlap, [], Fs);
    
    for j = 1:length(f_min) % 4 channels
        i_min = find(F >= f_min(j), 1, 'first');
        i_max = find(F <= f_max(j), 1, 'last');
    
        integral = trapz(F(i_min:i_max), Pxx(i_min:i_max));
        int_band_power(i,j) = integral;
        mean_band_power(i,j) = integral / (f_max(j)-f_min(j));
        
        [P_max, ind_P_max] = max(Pxx(i_min:(i_max-1))); % decrement i_max so ranges don't overlap
        peak_band_power(i,j) = P_max;
        ind_P_max = ind_P_max - 1 + i_min; % Correct index to full data series
        
        f_peak_band_power(i,j) = F(ind_P_max);
    end
end

% Remove outliers of 1 standard deviation 
int_band_power = remove_outliers(int_band_power, 1);
mean_band_power = remove_outliers(mean_band_power,1);
peak_band_power = remove_outliers(peak_band_power, 1);

lengthx = length(data(:,1)); %129
lengthy = length(data(1,:)); %14336
yx = zeros(length(F), lengthx);

for i = 1:lengthx

    y = data(i,:);
    [Pxx, F] = pwelch(y, win, overlap, [], Fs);
    yx(:,i) = Pxx;
    
end

%name3 = 'Novice9_SYMGEO_7A_sl1_Sit_05-40Hz.set'
name4 = ['FILES/CSV_JAN22/',name3, '.csv'];

writematrix(yx,name4) 

end
%%
% Helper Functions
function [x] = remove_outliers(x, n_std)
    mu_x = repmat(mean(x,1),size(x,1),1);
    std_x = repmat(std(x,1),size(x,1),1);

    ind_low = x < mu_x - n_std*std_x;
    ind_high = x > mu_x + n_std*std_x;

    x(ind_low) = nan;
    x(ind_high) = nan;
end