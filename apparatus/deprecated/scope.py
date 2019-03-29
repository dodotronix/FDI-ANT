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
    addr_s = "10.0.0.39"
    
    # vygeneruj sinusovku a navzorkuj ji osciloskopem a snaz se zjistit, zda
    # osciliskop neupravuje vzorkovani

    # oscilloscope init values
    fsmp = '500E+6' 
    bw = 'B200' 
    period = 20e-3 
    amp = 1 + 0.6 # generation of 1Vpp is not accurate -> 0.6 overlap
    imp = '50' 
    l_trig = '0'
    
    # connect to devices
    oscilloscope = ScopeComm(addr_s)

    # set signal on generator
    oscilloscope.setup(fsmp, bw, period, amp, imp, l_trig)

    # check if everything setup
    oscilloscope.check_setup()
    oscilloscope.get_error_list()

    # get signal from oscilloscope
    scope_data0 = oscilloscope.get_wave_data() 
    print(len(scope_data0))

    # show
    # TODO calibrate sample rate on scope
    # buffer_size = oscilloscope.size
    # h_scale = float(oscilloscope.h_scale)/2 * 1e9 # convert time to ns
    # t = np.linspace(-1*h_scale, h_scale, buffer_size)

    plot.plot(scope_data0)
    plot.show(block=True)

    oscilloscope.close()
