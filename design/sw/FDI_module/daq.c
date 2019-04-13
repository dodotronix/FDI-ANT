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
void read_daq(volatile uint16_t *memory)
{
  uint16_t buffer[BUFFER_SIZE];

  // open file
  FILE *f = fopen("data.txt", "w");
  if (f == NULL) {
      printf("Error opening file!\n");
      exit(1);
  }

  for(int i=0; i<BUFFER_SIZE; ++i){ 
    buffer[i] = (READ_REG(memory + 2*i) & 0x3fff);
    fprintf(f, "%u\n", buffer[i]);
  }

  fclose(f);
}


/*
 * activate DAQ
*/
void daq_start(volatile uint32_t *control_reg)
{
 CLEAR_BIT(control_reg, DAQ_ENA_Msk);
 SET_BIT(control_reg, DAQ_ENA_Msk);
}
