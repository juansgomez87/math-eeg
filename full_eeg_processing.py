import numpy as np
import mne
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import asrpy
import glob
import tqdm
import pandas as pd

import pdb


# verbosity and plots
verbose = False
# bad channels
bad_chan = {'Expert1': [65, 66, 110],
            'Expert3': [11],
            'Expert53': [19, 54, 115],
            'Novice2': [19, 31, 36, 90, 94],
            'Novice4': [13, 36, 55, 67],
            'Novice53': [13, 19]}
# frequency bands
iter_freqs = [
    ('Beta', 12, 17),
    ('Gamma', 30, 40)
]

# saving dataframe
df = pd.DataFrame()
# error files
err_f = []
######################################
# 1 - load all the .SET in data folder
list_fn = glob.glob('data/*/*.set')

######################################
# 2 - process each subject
for f in tqdm.tqdm(list_fn):
    # load eeg
    try:
        raw = mne.io.read_raw_eeglab(f, preload=True)
    except:
        print('!!!!!!!!!!!')
        print('File {} could not be processed!'.format(f))
        err_f.append(f)
        continue
    subj_type = f.split('/')[-1].split('_')[0]
    # montage = mne.channels.read_custom_montage('data/montage.csv')
    # pdb.set_trace()
    # raw.drop_channels(['OI2h'])
    # montage = mne.channels.make_standard_montage('biosemi128')
    # raw = raw.set_montage(montage)

    raw_init = raw.copy()

    if verbose:
        print(raw)
        print(raw.info)

    ######################################
    # 3 - preprocessing
    print('Filtering...')
    # 1Hz filtering for ica and asr
    raw.filter(l_freq=1, h_freq=None, verbose=verbose)
    # filter line noise @ 50Hz
    raw.notch_filter(freqs=50, verbose=verbose)
    # raw.plot_psd(fmax=70)
    # plt.show()

    ######################################
    # 4 - removing bad channels and interpolating
    if subj_type in bad_chan.keys():
        drop_chan = [_ - 1 for _ in bad_chan[subj_type]]
        drop_names = [raw.ch_names[_] for _ in drop_chan]
        raw.info['bads'].extend(drop_names)
        raw.interpolate_bads(verbose=verbose)

    ## reference to average
    raw = raw.set_eeg_reference(ref_channels='average', verbose=verbose)

    ######################################
    # 5 - removing artifacts
    print('Removing artifacts...')

    # removing artifacts with subspace projections
    asr = asrpy.ASR(sfreq=raw.info["sfreq"], cutoff=10)
    try:
        asr.fit(raw)
    except:
        print('!!!!!!!!!!!')
        print('File {} could not be processed!'.format(f))
        err_f.append(f)
        continue
    
    # raw_after = asr.transform(raw)
    raw = asr.transform(raw)

    # raw.plot(duration=5, n_channels=40)
    # plt.show()
    # raw_after.plot(duration=5, n_channels=40)
    # plt.show()

    # removing artifacts with independent component analysis
    ica = mne.preprocessing.ICA(n_components=None,
                                random_state=1987,
                                max_iter=800,
                                method='fastica',
                                verbose=verbose)
    ica.fit(raw, verbose=verbose)
    ecg_inds, ecg_scores = ica.find_bads_ecg(raw, ch_name='OI2h', verbose=verbose)
    ica.exclude = ecg_inds
    raw_ica = raw.copy()
    ica.apply(raw_ica, verbose=verbose)
    if verbose:
        ica.plot_scores(ecg_scores)

        raw.plot()
        raw_ica.plot()

    ######################################
    # 6 - selecting channels of interest
    print('Selecting channels of interest...')

    # get all channels
    all_chan = raw_ica.ch_names
    # drop heart rate channel
    # Selected according to plot and position on matlab file
    raw_ica.drop_channels(['OI2h'])

    # subselection of channels 
    gamma_chan = ['FC3', 'FC1', 'FCz', 'FC2', 'FC4']
    beta_chan = ['P1', 'Pz', 'P2', 'POz']
    raw_ica = raw_ica.pick_channels(beta_chan + gamma_chan)

    if verbose:
        fig = plt.figure()
        ax2d = fig.add_subplot(121)
        ax3d = fig.add_subplot(122, projection='3d')
        raw_ica.plot_sensors(ch_type='eeg', axes=ax2d)#, show_names=True)
        raw_ica.plot_sensors(ch_type='eeg', axes=ax3d, kind='3d', sphere='auto')
        ax3d.view_init(azim=70, elev=15)
        plt.show()

    ######################################
    # 7 - get events from annotations and calculate power spectrum density
    print('Calculating power spectral density...')

    fs = raw.info['sfreq']
    win = int(2 * fs)  # based on matlab script (?)
    ovlp = int(0.5 * win)

    frequency_map = list()
    all_data = {}
    for band, fmin, fmax in iter_freqs:

        # Obtain the PSD using Welch's method
        psd = raw_ica.compute_psd(method='welch',
                                    fmin=fmin,
                                    fmax=fmax,
                                    window='hamming',
                                    n_fft=win,
                                    n_overlap=ovlp,
                                    verbose=verbose)
        power = np.mean(10 * np.log10(psd.get_data()*10e6), axis=1)/(fmax-fmin)

        res = dict(zip(psd.ch_names, power))
        if band == 'Beta':
            res= {k+'_b': v for k, v in res.items()}
        elif band == 'Gamma':
            res= {k+'_g': v for k, v in res.items()}
        
        all_data.update(res)


    subj_data = f.split('/')[-1]

    if subj_data.split('_')[0].startswith('Exp'):
        all_data['group'] = 'Expert'
        all_data['subject'] = 'S' + subj_data.split('_')[0].replace('Expert', '')
    elif subj_data.split('_')[0].startswith('Nov'):
        all_data['group'] = 'Novice'
        all_data['subject'] = 'S' + subj_data.split('_')[0].replace('Novice', '')


    if subj_data.split('_')[2].endswith('G'):
        all_data['math'] = 'geometry'
    elif subj_data.split('_')[2].endswith('A'):
        all_data['math'] = 'algebra'

    all_data['bodyposition'] = subj_data.split('_')[4]

    df = pd.concat([df, pd.DataFrame(all_data.values(), all_data.keys()).T])
    # delete stuff to save memory alloc
    del raw, raw_ica, psd, ica

# save summary of data for statistical analysis
df.to_csv('summary_full.csv', sep=',')

np.save('error_files_full.npy', err_f)


