#!/usr/bin/python
# -*- coding:utf-8 -*-

# TODO LICENCE
#------------------------------------------------------------------------------#
# imports
import os
import sys
import math
import matplotlib.pyplot as plot

# custom imports
from diagmod import DiagMod

#------------------------------------------------------------------------------#
# TODO calibration, measure single, continuous, plot chart, save chart and data

if __name__ == '__main__':
    stimul = 'stimul.txt'
    measured = 'measured.txt'

    fdi_module = DiagMod(stimul, measured)

    plot.plot(fdi_module.xcorr)
    plot.show(block=True)

#------------------------------------------------------------------------------#
