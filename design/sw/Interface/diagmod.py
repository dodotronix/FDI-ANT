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
    def __init__(self, reference, reflected, order, bitrate):
        self.fsmp = 125e6
        self.uref = 1         #  V
        self.threshold = 0.4  #  % (from maximal peak hight)
        self.v_c = 3e8        #  m/s
        self.v_factor = 0.695
        self.adc_res = 14     #  bit
        self.repeat = 3
        self.atten = 9        #  dB/km
        self.amp = 0.5        #  V
        self.allowance = 0.1  #  %

        self.order = order
        self.bitrate = bitrate*1e6
        self.reference = self.cut_signal(reference)
        self.reflected = self.cut_signal(reflected)
        self.convert_real() # convert signals to voltage
        self.filter() # filter data
        self.correlation()
        self.estimation()

    def convert_real(self):
        uref_step = self.uref/np.power(2, 13)
        self.reference = list(np.array(self.reference)*uref_step) 
        self.reflected = list(np.array(self.reflected)*uref_step)

    def cut_signal(self, data):
        if(data):
            data = [x for x in data if x != 0x7fff]
        return data

    def correlation(self):
        self.xcorr = []
        self.xdist = []
        if(list(self.reflected) and list(self.reflected)):
            delta = len(self.reference)
            bitw = int(self.fsmp/self.bitrate)
            self.xcorr = np.correlate(self.reflected, self.reference, "full")
            self.xcorr = self.xcorr[delta-2*bitw:2*delta-bitw]
            k = self.v_c*self.v_factor
            self.xdist = (np.arange(delta+bitw)-2*bitw+1)/self.fsmp*k/2

    def signal_chart(self): 
        t1 = list(np.arange(len(self.reference))/self.fsmp)
        t2 = list(np.arange(len(self.reflected))/self.fsmp)

        plot.figure(1)
        # reference signal
        plot.subplot(2, 1, 1)
        plot.plot(t1, self.reference)
        plot.ylabel("voltage [V]")
        plot.xlabel("Time [s]")
        plot.grid()
        # reflected signal
        plot.subplot(2, 1, 2)
        plot.plot(t2, self.reflected)
        plot.ylabel("Voltage [V]")
        plot.xlabel("Time [s]")
        plot.grid()

    def xcorr_chart(self):
        plot.figure(2)
        plot.plot(self.d_aprox, self.estim)
        plot.plot(self.xdist, self.xcorr)
        plot.ylabel("Correlation amplitude")
        plot.xlabel("Distance [m]")
        plot.xlim(-50, 100)
        plot.grid()

    def get_cable_len(self):
        if(list(self.reflected) and list(self.reflected)):
            theor_peak = np.power(self.amp, 2)*(np.power(2, self.order)-2)*self.fsmp/self.bitrate

            self.peaks, _ = signal.find_peaks(self.xcorr, self.threshold*theor_peak)
            self.peak_widths = signal.peak_widths(self.xcorr, self.peaks, rel_height=0.9)[0]
            self.interpol2()

            bitw_m = (1/self.bitrate)*self.v_c*self.v_factor
            w_bound_up = (1 + self.allowance)*bitw_m
            peak_h = self.xcorr[self.peaks[0]]

            if(len(self.peaks) > 1):
                return "{0:.2f}".format(self.int_x[1]-self.int_x[0])

            # check height of reference peak
            if(peak_h >= 0.9*theor_peak):
                print("presalh vysku")
                return " < {0:.2f}".format(bitw_m/2)

            # check width of reference peak
            if(self.peak_widths[0] > w_bound_up):
                print("presalh sirku")
                return " < {0:.2f}".format(bitw_m/2)


    def filter(self):
        if(list(self.reflected) and list(self.reflected)):
            b, a = signal.butter(6, 20e6/self.fsmp, 'low')
            self.reference = signal.filtfilt(b, a, self.reference)
            self.reflected = signal.filtfilt(b, a, self.reflected)

    def estimation(self):
        a = np.power(self.amp, 2)*(np.power(2, self.order)-2)*self.fsmp/self.bitrate
        self.d_aprox = np.arange(0,len(self.xcorr));
        self.estim = a*np.power(10, self.d_aprox*-self.atten/1000);

    def interpol2(self):
        """
        interpolation - second order
        """
        self.int_x = []
        self.int_y = []
        xcorr = np.array(self.xcorr)
        xdist = np.array(self.xdist)

        for i in self.peaks:
            v_y = xcorr[i-1:i+2] # get y-vals around peak point
            v_x = xdist[i-1:i+2] # get x-vals around peak point 

            # interpolation
            pp = np.polyfit(v_x, v_y, 2)
            rx = np.roots(np.polyder(pp))[0]
            self.int_x.append(rx)
            self.int_y.append(np.polyval(pp, rx))

#------------------------------------------------------------------------------#
