#!/usr/bin/python
# -*- coding:utf-8 -*-

import sys
import visa
import time as tm
import numpy as np
import matplotlib.pyplot as plot

sys.path.append('..')

from modules.labdev import GenComm, ScopeComm
from modules.wafo import WaveForm # prbs, sin, square

if __name__ == '__main__':

    size = 2**16
    addr_s = "10.0.0.39"
    addr_g = "10.0.0.9"

    
    # oscilloscope init values
    fsmp = '500E+6' 
    bw = 'B200' 
    t_scale = '1E-5' 
    amp_scale = '0.5'
    imp = '50' 
    l_trig = '0.5'
    
    # connect to devices
    generator = GenComm(addr_g)
    oscilloscope = ScopeComm(addr_s)
    wf = WaveForm()

    def save_data(data1, data2):
        print("Do you want to save reference and reflected signal data?")
        if(input('') == 'y'):
            np.savetxt("reference_sig.txt", data1, '%f')
            np.savetxt("reflected_sig.txt", data2, '%f')

    def wait_for_key():
        key = input('')
        if (key == ''):
            pass
        if (key == 'q'):
            sys.exit()

    # create prbs signal
    test_data = wf.get_prbs_signal(size, 1, 7)
    print(wf.seq_length)
    # plot.plot(test_data)
    # plot.show(block=True)

    generator.prepare_wave_data(test_data, "test1") 

    # set signal on generator
    generator.setup('1', '250000', '2', '0', '0')
    oscilloscope.setup(fsmp, bw, t_scale, amp_scale, imp, l_trig)

    # enable sync signal on second channel + enable external clock
    generator.enable_sync_signal('2', '250000')
    generator.enable_external_osc()

    generator.enable_output('1', '50')

    oscilloscope.get_error_list()
    print("Connect load (press Enter to continue).")
    wait_for_key()

    # get signal from oscilloscope
    scope_data0 = oscilloscope.get_wave_data() 

    while(1):
        print("Connect cabel, which you want to measure (press Enter to continue).")
        wait_for_key()

        scope_data1 = oscilloscope.get_wave_data() 
        
        # cut one period of signal

        # shift signal to begin in zero point

        # reference signal substraction 
        reflect_sig = scope_data1 - scope_data0

        # correlation
        print("Correlation ...")
        c = np.correlate(reflect_sig, scope_data0, "full")
        print(c.max())

        # show
        buffer_size = oscilloscope.size
        h_scale = float(oscilloscope.h_scale)/2 * 1e9 # convert time to ns
        t = np.linspace(-1*h_scale, h_scale, buffer_size)
        t1 = np.linspace(-2*h_scale, 2*h_scale, 2*buffer_size -1)

        plot.subplot(3, 1, 1)
        plot.plot(t, scope_data0)
        plot.subplot(3, 1, 2)
        plot.plot(t, reflect_sig)
        plot.subplot(3, 1, 3)
        plot.plot(t1, c)
        plot.show(block=True)

        # want you to save data?
        save_data(scope_data0, scope_data1)
        
        print("Press Enter to continue or q to quit.")
        wait_for_key()

    oscilloscope.close()
    generator.close()

