#
# Makefile - FDI_module
# creator: dodotronix | BUT | 2019
#

TARGET = fdi_driver

# Path
PROJECT_DIR = .

# Variables
CC       =  gcc
CFLAGS   =  -g -Wall
OBJS     =  main.o seqgen.o daq.o
INCLUDES =  -I $(PROJECT_DIR)/inc/


all:$(TARGET)

%.o:%.c
	@echo $(OBJS)
	$(CC) -c $< $(CFLAGS) $(INCLUDES)

$(TARGET): $(OBJS)
	@echo $(OBJS)
	$(CC) -o $@ $(OBJS) $(CFLAGS) $(INCLUDES)

clean:
	rm -rf *.o
	rm -rf $(TARGET)
