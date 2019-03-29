#!/usr/bin/python
# -*- coding:utf-8 -*-

import sys
import os
import visa
import time as tm
import numpy as np
import matplotlib.pyplot as plot

sys.path.append('..')

from modules.labdev import GenComm, ScopeComm
from modules.wafo import WaveForm as wf # prbs, sin, square

def get_samples(samples): 
    # 16k, 32k, 52k
    if samples == '32k':
        return 2**15
    elif samples == '512k':
        return 2**19
    else:
        return 2**14 # 16k

if __name__ == '__main__':

    addr_s = "10.0.4.30"
    addr_g = "10.0.4.48"

    # physical konstant
    c = 3e8    #  [m/s]; light speed
    vf = 0.695 #  [-] velocity factor
    order = 11

    # generation parameters
    bitrate = ((2**order)-1)*8e3     # [bit/s]
    samples = get_samples('512k') # [Sa/s]
    amp = 0.5                      # [Volts]
    fsmp = 125e6                   # [Sa/s]

    # devices init values
    # bw = 'FULL' # on RTE 1024 maximum bandwidth 200 MHz
    bw = 'B20'
    imp = 50      # [ohm]
    trig = amp/4  # [V]
    name = 'stdr' # signal name
    
    # prbs signal generation
    prbs = wf.generate_prbs_sequence(1, order)
    # prbs = [1, -1, 1, -1, 1]

    freq = bitrate/(len(prbs))
    print('Frequency: ' + str(freq))
    if(freq >= 8e6):
        print("Calculated frequency is too high.")
        sys.exit()

    signal = wf.get_bit_signal(prbs, samples, bitrate)
    size = len(signal) # size is reduced number of samples

    # DEBUG
    # plot.plot(test_data)
    # plot.show()

    # connect to devices
    generator = GenComm(addr_g)
    oscilloscope = ScopeComm(addr_s)

    # TODO input your custom names of reference and reflected data file
    def save_data(data1, data2):
        save_path = "data"
        print("Do you want to save reference and reflected signal data?")
        if(input('') == 'y'):
            print('write name of the reference data file with: ')
            reference = input()
            reference =  os.path.join(save_path, reference + ".txt")
            print('write name of the reflected data file with: ')
            reflected = input()
            reflected =  os.path.join(save_path, reflected + ".txt")
            np.savetxt(reference, data1, '%f')
            np.savetxt(reflected, data2, '%f')

    def wait_for_key():
        key = input('')
        if (key == ''):
            pass
        if (key == 'q'):
            sys.exit()

    # connect to devices
    generator = GenComm(addr_g)
    oscilloscope = ScopeComm(addr_s)

    # translate data for generator
    data = generator.prepare_wave_data(signal) 
    # set signal on generator
    generator.send_data_and_set('1', freq, str(amp), '0', '0', name, data)
    # enable external clock
    generator.enable_external_osc()
    # dds mode
    generator.set_dds('1')
    generator.enable_sync_signal('2', freq)
    # load custom signal with particular name
    generator.activate_custom_signal('1', name)
    # enable sync signal on second channel
    generator.enable_output('1', str(imp))

    # set osciloscop initial values
    oscilloscope.setup(fsmp, bw, freq, amp + 0.6, imp, trig)
    # check if everything setup
    oscilloscope.check_setup()
    # check if everything was setup right
    oscilloscope.get_error_list()

    print("Connect load (press Enter to continue).")
    wait_for_key()
    reference = oscilloscope.get_wave_data() # get reference signal 
    # oscilloscope.change_h_scale(2/freq)
   
    while(1):
        print("Connect cable and press Enter to continue.")
        wait_for_key()
        reflected = oscilloscope.get_wave_data() 

        size_adc = len(reference)
        # reflected = reflected[:size_adc]

        # correlation
        print("Correlation ...")
        c0 = np.correlate(reflected, reference, "full")
        bound = size_adc - 1

        # resol = 0.5*vf*c*period
        resol = float(oscilloscope.resol)*vf*c*0.5
        t = np.linspace(0, bound, size_adc)*resol

        # correlation time domain
        t1 = np.linspace(-bound, bound, 2*size_adc-1)*resol

        p0_value = c0.max()
        p0_index = np.argmax(c0) 
        d0 = t1[p0_index]
        print('Peak0 value: ' + str(p0_value))
        print('Peak0 distance: ' + str(d0))

        # second peak
        tmp = reflected - reference
        c1 = np.correlate(tmp, reference, "full")
        plot.show()

        p1_value = c1.max()
        p1_index = np.argmax(c1) 
        d1 = t1[p1_index]
        print('Peak1 value: ' + str(p1_value))
        print('Peak1 distance: ' + str(d1))

        dt = (d1)
        print("Length of cabel is: " + str(dt) + " [m]")

        plot.subplot(3, 1, 1)
        plot.plot(t, reference)
        plot.subplot(3, 1, 2)
        plot.plot(t, reflected)
        plot.subplot(3, 1, 3)
        plot.plot(t1, c1)
        plot.show(block=True)

        # want you to save data?
        save_data(reference, reflected)
        
        print("Press Enter to continue or q to quit.")
        wait_for_key()

    oscilloscope.close()
    generator.close()
