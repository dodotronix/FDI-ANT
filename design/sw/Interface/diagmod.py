#!/usr/bin/python
# -*- coding:utf-8 -*-

# do correlation, peak exploration

# TODO LICENCE
#------------------------------------------------------------------------------#
# imports
import sys
import numpy as np
import matplotlib.pyplot as plot
import scipy.signal as signal

class DiagMod:
    def __init__(self, reference, reflected):
        self.fsmp = 125e6
        self.uref = 1
        self.threshold = 1000
        self.v_c = 3e8
        self.v_factor = 0.695
        self.adc_res = 14
        self.reference = reference
        self.reflected = reflected
        # self.correlation()
    
    #TODO not tested yet
    def convert_real(self, data):
        for i,num in enumerate(data):
            if(not(num & (1 << self.adc_res))):
                data[i] = num - 2**self.adc_res 
        return np.array(data) / (2**adc_res)*self.uref

    def correlation(self):
        self.xcorr = np.correlate(self.reflected, self.reference, "full")
        self.dist = np.arange(len(self.xcorr))/(self.v_c*self.v_factor/2) 

    def signal_chart(self): 
        t1 = np.arange(len(self.reference))/self.fsmp
        t2 = np.arange(len(self.reflected))/self.fsmp

        plot.figure(1)
        plot.subplot(2, 1, 1)
        plot.plot(self.reference)
        plot.subplot(2, 1, 2)
        plot.plot( self.reflected)

    def xcorr_chart(self):
        plot.figure(2)
        plot.plot(self.dist, self.xcorr)

    def get_cable_len(self):
        self.peaks, _ = signal.find_peaks(self.xcorr, self.threshold)
        return self.peaks
        # self.p = np.polyfit()

#------------------------------------------------------------------------------#
