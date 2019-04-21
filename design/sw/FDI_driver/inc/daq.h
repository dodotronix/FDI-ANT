/*------------------------------------------------------------------------------
 -- daq.h

 -- TODO LICENCE

 -- creator: dodotronix | BUT | 2019

 -- description:
 -----------------------------------------------------------------------------*/

#ifndef DAQ_H
#define DAQ_H

/*------------------------------------------------------------------------------
-- Defines
------------------------------------------------------------------------------*/
#define BUFFER_SIZE 32768 //memory size (32-bit)

#define DAQ_BASE (0x42000000)
#define MEM_BASE (0x40000000)

#define DAQ_DONE_Pos (0U)
#define DAQ_DONE_Msk (0x01U << DAQ_DONE_Pos)

/*------------------------------------------------------------------------------
-- Externs
------------------------------------------------------------------------------*/

extern int daq_init(uint32_t **daq_stat, uint32_t **daq_memory);
extern void read_daq(uint32_t *memory, char *to_send);

#endif //DAQ_H
