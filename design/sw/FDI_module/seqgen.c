/*------------------------------------------------------------------------------
 -- seqgen.c

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
#include "seqgen.h"


/*------------------------------------------------------------------------------
-- Statics
------------------------------------------------------------------------------*/

/*
 * coder for setup translation
*/
static uint32_t coder(uint8_t bitrate, uint8_t repeat, uint8_t order)
{
  // masks are controlling option bit width
  uint8_t br = ((125 / bitrate) & 0xff); //ADC @ DAC (f_smp = 125Mhz)
  uint8_t ord = ((order - 6) & 0x07);
  uint8_t rep = (repeat & 0x07);

  if(order < 6)
    ord = 0;

  return ((uint32_t)(rep << REPEATE_Pos) | 
          (uint32_t)(ord << ORDER_Pos) | 
          (uint32_t)(br << BITRATE_Pos));
}

/*------------------------------------------------------------------------------
-- Functions
------------------------------------------------------------------------------*/

/*
 * Initialize sequence generator
*/
int sg_init(volatile uint32_t **control_reg)
{
  int fd;
  if((fd = open("/dev/mem", O_RDWR)) < 0) {
    perror("open");
    return EXIT_FAILURE;
  }

  *control_reg = mmap(NULL, sysconf(_SC_PAGESIZE), 
                      PROT_READ|PROT_WRITE, 
                      MAP_SHARED, fd, SEQGEN_BASE);

  return 0;
}

/*
 * sequence generator setup
*/
void sg_setup(volatile uint32_t *control_reg, uint8_t bitrate, uint8_t repeat, uint8_t order)
{
  uint32_t result = coder(bitrate, repeat, order);
  WRITE_REG(control_reg, result); 
}

/*
 * launch sequence generator
*/
void sg_start(volatile uint32_t *control_reg)
{
  SET_BIT(control_reg, SEQENA_Msk);
  usleep(4);
  CLEAR_BIT(control_reg, SEQENA_Msk);
}

/*
 * reset sequence generator
*/
void sg_reset(volatile uint32_t *control_reg)
{
  SET_BIT(control_reg, SEQRST_Msk);
  usleep(4);
  CLEAR_BIT(control_reg, SEQRST_Msk);
}
