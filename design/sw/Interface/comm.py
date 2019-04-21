#!/usr/bin/python
# -*- coding:utf-8 -*-

# communication module for FDI module

# TODO LICENCE
#------------------------------------------------------------------------------#
# modules
import sys
import numpy as np

from PyQt5.QtNetwork import QAbstractSocket, QTcpSocket
from PyQt5.QtCore import QByteArray, QDataStream, QIODevice

class Comm():

    def __init__(self, address, port):
        self.block = 0
        self.port = port
        self.delimiter = bytes('x', 'utf-8')
        self.address = address
        self.block = bytearray()
        self.initialize(address, port)
    
    def initialize(self, address, port):
        self.socket = QTcpSocket()
        self.socket.connectToHost(self.address, self.port)

    def decode(self, data):
        return data.decode('utf-8').replace('\x00', '').rsplit()

    def read(self):
        self.size = self.socket.bytesAvailable()
        self.block += self.socket.read(self.size)

    def get_data(self):
        if(self.delimiter in self.block):
            data = self.block[0:self.block.index(self.delimiter)]
            data = list(map(int, self.decode(data)))
            self.block = self.block[self.block.index(self.delimiter)+1:-1]
            return data

    def send(self, data):
        self.socket.write(bytearray( data, 'utf-8' ))

    def disconnect(self):
        self.socket.close()

#------------------------------------------------------------------------------#
