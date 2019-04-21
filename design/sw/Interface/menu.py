#!/usr/bin/python
# -*- coding:utf-8 -*-

# TODO LICENCE
#------------------------------------------------------------------------------#
# imports
import os
import sys
import math
import logging
import numpy as np
import matplotlib.pyplot as plot

from PyQt5.QtCore import QFile, QObject, QSocketNotifier, QTextStream, QIODevice
from diagmod import DiagMod

class Menu(QObject):

    def __init__(self, comm, app):
        QObject.__init__(self)
        x = QSocketNotifier(0, 0, self)
        x.activated.connect(self.menu_handler)

        self.order = 8
        self.bitrate = 5
        self.repeat = 3
        self.status = 0
        self.cable_len = '--'
        self.cal_stat = '--'
        self.meas_stat = '--'
        self.stored = '--'
        self.data = []
        self.cal_data = []
        self.refl_data =[]
        self.comm = comm
        self.app = app
        self.create()
        self.display()
        self.send_setup()

    def menu_handler(self):
        l = sys.stdin.readline()
        self.display()
        self.run(l)

    def header(self):
        return ('host: {0}, port: {1}\n'
                'Setup: \n'
                '       Order [-]: {2}\n'
                '       Bitrate [Mhz]: {3}\n'
                '       Repetitions [x]: {4}\n\n'
                'Calibration status: {5}\n'
                'Measure status: {6}\n'
                'Data stored: {7}\n'
                'First discontinuity [m]: {8}'.format(self.comm.address, 
                                                  self.comm.port,
                                                  self.order,
                                                  self.bitrate,
                                                  self.repeat,
                                                  self.cal_stat,
                                                  self.meas_stat,
                                                  self.stored,
                                                  self.cable_len))

    def create(self):
        self.menu = {'Calibration' :  self.calibration,
                     'Setup'       :  self.setup,
                     'Measure'     :  self.measure_opt,
                     'Chart'       :  self.plot,
                     'Save data'   :  self.save_data,
                     'Load data'   :  self.load,
                     'Quit'        :  self.quit}

    def calibration(self): 
        print("Please match your transmission line and press Enter")
        sys.stdin.readline()
        self.status = 1
        tmp = self.repeat
        self.repeat = 1
        self.send_setup()
        self.repeat = tmp
        self.measure()
        self.send_setup()

    def setup(self):
        print("\nSet bitrate [MHz]\n", end='')
        self.bitrate = int(sys.stdin.readline().rstrip())
        print("\nSet order (6-13)\n", end='')
        self.order = int(sys.stdin.readline().rstrip())
        self.meas_stat = '--'
        self.cal_stat = '--'
        self.cal_data = []
        self.refl_data = []
        self.stored = '--'
        self.send_setup()
        self.display()

    def send_setup(self):
        packet = '{0}\n{1}\n{2}\n{3}\n'.format(str(1), 
                self.bitrate, self.order, self.repeat)
        self.comm.send(packet)

    def measure(self):
        packet = '{0}\n'.format(str(2))
        self.comm.send(packet)

    def measure_opt(self): # menu option
        self.status = 2
        self.measure()

    def plot(self):
        self.module.signal_chart()
        self.module.xcorr_chart()
        plot.show(block=True)

    def save_data(self):
        np.savetxt("reference_sig.txt", self.module.reference, '%f')
        np.savetxt("reflected_sig.txt", self.module.reflected, '%f')
        self.stored = 'Done'
        self.display()

    def load(self):
        self.cal_data = list(np.loadtxt("reference_sig.txt", delimiter='\n'))
        self.refl_data = list(np.loadtxt("reflected_sig.txt", delimiter='\n'))
        self.module = DiagMod(self.cal_data, self.refl_data, 9, 20)
        # sem prijdou vyhodnoceni (jen pro test)
        self.cable_len = self.module.get_cable_len()

    def quit(self):
        self.comm.disconnect()
        self.app.exit()

    def read(self):
        self.comm.read()
        self.data = self.comm.get_data()
        if(self.data): 
            if(self.status == 1):
                print('Calibration ...')
                self.cal_data = self.data
                self.cal_stat = 'Done'
            elif(self.status == 2):
                print('Measuring ...')
                self.refl_data = self.data
                self.meas_stat = 'Done'
            self.module = DiagMod(self.cal_data, self.refl_data, self.order, self.bitrate)
            self.cable_len = self.module.get_cable_len()
            self.status = 0
            self.data = [] #clear buffer
            # self.display()

    def box(self, header):
        d = '-' * 40
        return ('{0}\n'
                '{1}\n'
                '{0}'.format(d, header))

    def display(self):
        os.system('clear')
        print(self.box(self.header()))
        for num, label in enumerate(self.menu):
            print('[{0}] : {1}'.format(num, label));

    def run(self, option):
        #TODO if not number
        option = int(option)
        
        if(option >= 0 and option < len(self.menu)):
            list(self.menu.values())[option]()
        
#------------------------------------------------------------------------------#
