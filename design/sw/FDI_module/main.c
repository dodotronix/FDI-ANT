/*------------------------------------------------------------------------------
 -- main.c

 -- TODO LICENCE

 -- creator: dodotronix | BUT | 2019

 -- description:
 -----------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <math.h>
#include <sys/mman.h>
#include <time.h>

#include "system.h"
#include "seqgen.h"
#include "daq.h"

/*------------------------------------------------------------------------------
-- Registers
------------------------------------------------------------------------------*/
volatile uint32_t *seqgen_ctrl;
volatile uint32_t *daq_ctrl;
volatile uint32_t *daq_stat;
volatile uint16_t *daq_memory;

/*------------------------------------------------------------------------------
-- Main
------------------------------------------------------------------------------*/
int main(void)
{
  //Initialize
  sg_init(&seqgen_ctrl);
  daq_init(&daq_ctrl, &daq_stat, &daq_memory);

  //Device setup
  sg_setup(seqgen_ctrl, 255, 3, 2); //[bitrate, repeat, order]
  sg_start(seqgen_ctrl);

  //activate DAQ
  daq_start(daq_ctrl);
  printf("%d\n", READ_REG(daq_ctrl));
  printf("%d\n", READ_REG(daq_stat));

  //enable signal generator
  sg_start(seqgen_ctrl);

  //wait for daq flag
  while(IS_BIT_SET(daq_stat, DAQ_DONE_Msk));

  printf("%d\n", READ_REG(daq_ctrl));
  printf("%d\n", READ_REG(daq_stat));

  // read memory
  read_daq(daq_memory);

  return 0;
}
