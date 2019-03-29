#!/usr/bin/python
# -*- coding:utf-8 -*-

import visa
import numpy as np
import time as tm

class GenComm():
    def __init__(self, address):
        self.saddr = 'TCPIP::{0}::INSTR'.format(address)
        self.rm = visa.ResourceManager()
        self.dev = self.rm.open_resource(self.saddr)

        # required endings
        self.dev.write_termination = ''
        self.dev.read_termination = ''

    def get_generator_id(self):
        return self.dev.query("*IDN?")

    def reset(self):
        self.dev.write('*RST\n')

    def send_data_and_set(self, chann, freq, amp, ofst, ph, name, data):
        message = ('C{0}:WVDT '
                   'FREQ,{1},'
                   'AMPL,{2},'
                   'OFST,{3},'
                   'PHASE,{4},'
                   'WVNM,{5},'
                   'WAVEDATA,'.format(chann, freq, amp, ofst, ph, name))
        self.dev.write_binary_values(message, data, datatype='h')
        self.dev.write('\n')

    def set_true_arb(self, chann):
        self.dev.write('C{0}:SRATE MODE,TARB'.format(chann))
        self.dev.write('\n')

    def set_dds(self, chann):
        self.dev.write('C{0}:SRATE MODE,DDS'.format(chann))
        self.dev.write('\n')

    def activate_custom_signal(self, chann, name):
        self.dev.write('C{0}:ARWV NAME,{1}'.format(chann, name))
        self.dev.write('\n')

    def enable_output(self, chann, load):
        self.dev.write('C{0}:OUTP ON,LOAD,{1}'.format(chann, load))
        self.dev.write('\n')

    def disable_output(self, chann):
        self.dev.write('C{0}:OUTP OFF'.format(chann))
        self.dev.write('\n')

    def prepare_wave_data(self, data):
        return np.round(data*(2**15-1)).astype(int)
    
    def open_channel(chann):
        self.dev.write('C{0}:OUTP ON\n'.format(chann))

    def enable_sync_signal(self, chann, frequency):
        message = ('C{0}:BSWV '
                   'WVTP,SQUARE,'
                   'FRQ,{1},'
                   'AMPL,2,'
                   'OFST,0,'
                   'PHASE,0,'
                   'DUTY,0.1'.format(chann, frequency))
        self.dev.write(message)
        self.enable_output(chann, '50')

    def enable_external_osc(self):
        self.dev.write('ROSC EXT')

    def close(self):
        self.dev.close()

class ScopeComm():
    def __init__(self, address):
        self.saddr = 'TCPIP::{0}::5025::SOCKET'.format(address)
        self.rm = visa.ResourceManager()
        self.dev = self.rm.open_resource(self.saddr)
        self.dev.write_termination = '\n'
        self.dev.read_termination = '\n'

    def __wait_until_complete(self):
        self.dev.query("*OPC?") # wait until is previous op completed

    def setup(self, fsmp, bw, freq, amp, imp, l_trig):
        """
        all parameters should be string
        fsmp - sampling rate
        bw - bandwidth
        t_scale - time scale per div
        amp_scale - amplitude scale per div
        imp - impedance of chanel
        l_trig - trigger level
        """

        self.dev.write("*RST")
        # read data in ascii
        self.dev.write("FORM:DATA ASCii,0")
        self.__wait_until_complete()
        # meassurement impedance
        self.dev.write("CHAN1:IMP " + str(imp))
        self.__wait_until_complete()
        # channel impedance
        self.dev.write("CHAN1:COUP DCLimit")
        self.__wait_until_complete()
        self.dev.write("CHAN1:BAND " + bw) # BW 200 MHz (square risetime 3.5 ns)
        self.__wait_until_complete()
        self.dev.write("CHAN1:SCAL " + str(amp/10)) # vertical - 10 grid parts
        self.__wait_until_complete()
        self.dev.write('TIM:RANG ' + str(1/freq)) # horizontal scale (1 ms)
        self.__wait_until_complete()
        # acquire options (page 447)
        # moznosti: scale 10 ms, 20GHz, BW FULL;
        self.dev.write("ACQ:POIN:AUTO RES")
        self.__wait_until_complete()
        self.dev.write("ACQ:SRAT " + str(fsmp)) # 500E+6 -> 500 Msa/s
        self.__wait_until_complete()
        self.dev.write("ACQ:MODE ITIM") # real-time mode
        self.__wait_until_complete()
        # shift zero point left (default 50)
        self.dev.write("TIM:REF 0")
        self.__wait_until_complete()
        # set trigger
        self.dev.write("TRIG1:SOUR CHAN4") # trigger source
        self.dev.write("TRIG1:TYPE EDGE") # edge sensitive
        self.dev.write("TRIG1:EDGE:SLOP POS") # rising edge
        self.dev.write("TRIG1:LEV1:VAL " + str(l_trig)) # trigger level
        # activate channel 1
        self.dev.write("CHAN1:STAT ON")
        # start acquisition
        self.dev.write("RUNC")

    def change_h_scale(self, scale):
        self.dev.write('TIM:RANG ' + str(scale)) # horizontal scale (1 ms)
        self.__wait_until_complete()

    def check_setup(self):
        # get sample rate of ADC
        self.adc_r = self.dev.query("ACQ:POIN:ARAT?") 
        print('ADC sample rate [Sa/s]: ' + self.adc_r)
        # get number of samples
        self.samples = self.dev.query("ACQ:POIN:VAL?")
        print('Number of samples [-]: ' + self.samples)
        # get resolution
        self.resol = self.dev.query("ACQ:RES?")
        print('Resolution [s]: ' + self.resol)
        # get vertical scale
        self.v_scal = self.dev.query("CHAN1:SCAL?")
        print('Vertical scale [V]: ' + self.v_scal)
        # get horizontal scale
        self.h_rang = self.dev.query("TIM:RANG?")
        print('Horizontal range [s]: ' + self.h_rang)
        # get time shift
        self.pos = self.dev.query("TIM:REF?")
        print('Reference position [%]: ' + self.pos)

    def stop_meassure(self):
        self.dev.write("STOP")

    def get_wave_data(self):
        data = self.dev.query("CHAN1:WAV1:DATA?")
        data = np.array(data.split(','))
        return data.astype(np.float) 

    def get_error_list(self):
        print(self.dev.query("SYST:ERR:ALL?"))

    def get_id(self):
        return self.dev.query("*IDN?")

    def close(self):
        self.dev.close()
