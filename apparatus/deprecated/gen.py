#!/usr/bin/python
# -*- coding:utf-8 -*-

import sys
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
    elif samples == '52k':
        return 2**19
    else:
        return 2**14 # 16k

if __name__ == '__main__':

    addr_s = "10.0.0.39"
    addr_g = "10.0.0.9"

    bitrate = 10000
    samples = get_samples('52k')
    frequency = 100
    
    # connect to devices
    generator = GenComm(addr_g)

    # oscilloscope = ScopeComm(addr_s)

    # test_data = wf.get_square_signal(0.1, 0, wf.samples)

    # prbs signal generation
    # prbs = wf.generate_prbs_sequence(1, 7)
    prbs = [1, -1, 1, -1, 1]
    signal = wf.get_bit_signal(prbs, samples, bitrate)
    size = len(signal)

    # plot.plot(test_data)
    # plot.show()

    data = generator.prepare_wave_data(signal) 
    # set signal on generator
    generator.send_data_and_set('1', '2.5', '0', '0', 'lama', data)
    # generator.enable_external_osc()
    generator.set_true_arb('1', frequency, size)
    generator.activate_custom_signal('1', 'lama')
    
    # enable sync signal on second channel + enable external clock
    generator.enable_output('1', '50')

    generator.close()
