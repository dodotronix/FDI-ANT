/*------------------------------------------------------------------------------
 -- daq.c

 -- TODO LICENCE

 -- creator: dodotronix | BUT | 2019

 -- description:
 -----------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
-- Includes
------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <sys/mman.h>
#include <string.h>

#include "system.h"
#include "daq.h"

/*------------------------------------------------------------------------------
-- Functions
------------------------------------------------------------------------------*/

/*
 * DAQ initialization 
*/
int daq_init(volatile uint32_t **daq_ctrl, volatile  uint32_t **daq_stat, volatile uint16_t **daq_memory)
{
  int fd;
  if((fd = open("/dev/mem", O_RDWR)) < 0) {
    perror("open");
    return EXIT_FAILURE;
  }

  *daq_ctrl = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x42000000); 
  *daq_stat = *daq_ctrl + 2;
  *daq_memory = mmap(NULL, BUFFER_SIZE*4, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);

  return 0;
}

/*
 * read data from memory to file
*/
void read_daq(volatile uint16_t *memory, char *to_send)
{
  uint16_t buffer[BUFFER_SIZE];
  memset(to_send, 0, 20*BUFFER_SIZE);
  int n = 0;

  for(int i=0; i<BUFFER_SIZE; ++i){ 
    buffer[i] = (READ_REG(memory + 2*i));
    n += snprintf(to_send + n, 20, "%u\n", buffer[i]);
  }

  snprintf(to_send + n, 6, "%c", 'x');
}

/*
 * activate DAQ
*/
void daq_start(volatile uint32_t *control_reg)
{
 CLEAR_BIT(control_reg, DAQ_ENA_Msk);
 SET_BIT(control_reg, DAQ_ENA_Msk);
}
