#!/usr/bin/python
# -*- coding:utf-8 -*-

# TODO LICENCE
#------------------------------------------------------------------------------#
# imports
import os
import sys
import math
import time

import matplotlib.pyplot as plot
from PyQt5.QtWidgets import QApplication
from PyQt5.QtCore import QTimer

# custom imports
from menu import Menu
from comm import Comm

#------------------------------------------------------------------------------#

if __name__ == '__main__':

    # initializes the Qt event loop (without this nothing from Qt
    #   will work)
    app = QApplication( sys.argv )
    # comm = Comm("localhost", 15000)
    comm = Comm("10.0.4.41", 15000)
    menu = Menu(comm, app)

    timer = QTimer()
    timer.timeout.connect( lambda: None )
    timer.start( 100 )  # miliseconds

    # connect signals
    comm.socket.readyRead.connect(
            menu.read)

    sys.exit( app.exec_() )
    
#------------------------------------------------------------------------------#
