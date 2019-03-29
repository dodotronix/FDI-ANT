#!/usr/bin/python
# -*- coding:utf-8 -*-

# PRBS
# https://www.xilinx.com/support/documentation/application_notes/xapp052.pdf

import numpy as np
import scipy.signal as signal
import matplotlib.pyplot as plot

class WaveForm():

    @classmethod
    def __get_prbs_next_state(self, order, n):
        if(order == 3):
            newbit = (((n >> 2) ^ (n >> 1)) & 1) 
            return ((n << 1) | newbit) & 0x7
        elif(order == 4):
            newbit = (((n >> 3) ^ (n >> 2)) & 1)
            return ((n << 1) | newbit) & 0xf
        elif(order == 5):
            newbit = (((n >> 4) ^ (n >> 2)) & 1)
            return ((n << 1) | newbit) & 0x1f
        elif(order == 6):
            newbit = (((n >> 5) ^ (n >> 4)) & 1)
            return ((n << 1) | newbit) & 0x3f
        elif(order == 7):
            newbit = (((n >> 6) ^ (n >> 5)) & 1)
            return ((n << 1) | newbit) & 0x7f
        elif(order == 8):
            newbit = (((n >> 7) ^ (n >> 5) ^ (n >> 4) ^ (n >> 3)) & 1)
            return ((n << 1) | newbit) & 0xff
        elif(order == 9):
            newbit = (((n >> 8) ^ (n >> 4)) & 1)
            return ((n << 1) | newbit) & 0x1ff
        elif(order == 10):
            newbit = (((n >> 9) ^ (n >> 6)) & 1)
            return ((n << 1) | newbit) & 0x3ff
        elif(order == 11):
            newbit = (((n >> 10) ^ (n >> 8)) & 1)
            return ((n << 1) | newbit) & 0x7ff
        elif(order == 12):
            newbit = (((n >> 11) ^ (n >> 5) ^ (n >> 3) ^ n) & 1)
            return ((n << 1) | newbit) & 0xfff

    @classmethod
    def generate_prbs_sequence(self, seed, order):
        num = self.__get_prbs_next_state(order, seed)
        seq = [num & 1]
        
        # minimal possible size of lfsr
        if (order < 3):
            return -1
        while(num != seed):
            num = self.__get_prbs_next_state(order, num)
            seq.append(num & 1)
        return 2*(np.array(seq) - 0.5)

    @classmethod
    def get_bit_signal(self, bit_array, samples, bitrate):
        """
        function calculate size of whole signal which could
        be sent into generator
        """
        seq_length = len(bit_array)

        bit_w = np.floor(samples/(seq_length)).astype(int) 
        pulse = np.ones(bit_w)

        signal = np.concatenate([pulse*s for s in bit_array])
        # zero = np.zeros(len(signal))
        return signal
        # return np.concatenate([signal, zero])
    
    @classmethod
    def get_sinus_signal(self, delay, samples):
        return np.sin(np.linspace(0, 2*np.pi + 2 * np.pi * delay, samples))

    @classmethod
    def get_square_signal(self, duty, delay, samples):
        t = np.linspace(0, 1, samples)
        return signal.square(2*np.pi*1*t + 2*np.pi*delay, duty=duty)

    @classmethod
    def show_wave(self, data):
        plot.plot(data)
        plot.show(block=True)

