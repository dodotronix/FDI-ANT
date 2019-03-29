#!/usr/bin/python
# -*- coding:utf-8 -*-

# do correlation, peak exploration

# modules
import sys
import numpy as np
import matplotlib.pyplot as plot


class DiagMod:
    def __init__(self, stimul, measured):
        self.load_data(stimul, measured)
        self.correlation()

    def load_data(self, stimul, measured):
        """
        loads initial data
        """
        # read stimulus data
        self.stimul = np.fromfile(stimul, sep='\n')
        # read measured data
        self.measured = np.fromfile(measured, sep='\n')

    def correlation(self):
        """
        calculate cross-correlation
        """
        self.xcorr = np.correlate(self.measured, self.stimul, "full")
    
