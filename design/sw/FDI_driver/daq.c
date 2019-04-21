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
int daq_init(uint32_t **daq_stat, uint32_t **daq_memory)
{
  int fd;
  if((fd = open("/dev/mem", O_RDWR)) < 0) {
    perror("open");
    return EXIT_FAILURE;
  }

  *daq_stat = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x42000000); 
  *daq_stat = *daq_stat + 2;
  *daq_memory = mmap(NULL, BUFFER_SIZE*4, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);

  return 0;
}

/*
 * read data from memory to file
*/
void read_daq(uint32_t *memory, char *to_send)
{
  int32_t buffer[BUFFER_SIZE];
  memset(to_send, 0, 200*BUFFER_SIZE);
  int n = 0;

  for(int i=0; i<BUFFER_SIZE; ++i){ 
    buffer[i] = (READ_REG(memory + i));

    //32-bit number consist of two 16-bit values
    n += snprintf(to_send + n, 50, "%i\n", buffer[i] >> 16);
    n += snprintf(to_send + n, 50, "%i\n", (int16_t)buffer[i]);
  }

  snprintf(to_send + n, 6, "%c", 'x');
}
