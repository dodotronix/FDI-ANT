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
        self.refl_data = []
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
                     'Quit'        :  self.quit}

    def calibration(self): 
        print("Please match your transmission line and press Enter")
        sys.stdin.readline()
        self.status = 1
        self.measure()

    def setup(self):
        print("\nSet bitrate [MHz]\n", end='')
        self.bitrate = sys.stdin.readline().rstrip()
        print("\nSet order (6-13)\n", end='')
        self.order = sys.stdin.readline().rstrip()
        print("\nSet repetition (0-7)\n", end='')
        self.repeat = sys.stdin.readline().rstrip()
        self.meas_stat = '--'
        self.cal_stat = '--'
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

    def measure_opt(self):
        self.status = 2
        self.measure()

    def plot(self):
        self.module = DiagMod(self.cal_data, self.refl_data)
        self.module.signal_chart()
        # self.module.xcorr_chart()
        plot.show(block=True)

    def save_data(self):
        np.savetxt("reference_sig.txt", self.cal_data, '%u')
        np.savetxt("reflected_sig.txt", self.refl_data, '%u')
        self.stored = 'Done'
        self.display()

    def quit(self):
        self.comm.disconnect()
        self.app.exit()

    def read(self):
        self.comm.read()
        self.data = self.comm.get_data()
        if(self.data): 
            if(self.status == 1):
                print('kalibrace')
                self.cal_data = self.data
                self.cal_stat = 'Done'
            elif(self.status == 2):
                print('mereni')
                self.refl_data = self.data
                self.meas_stat = 'Done'
                # self.cable_len = self.module.get_cable_len()
                #oriznuti na potrebnou velikost
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
