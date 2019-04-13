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
#define BUFFER_SIZE 2*8192 //memory size

#define DAQ_BASE (0x42000000)
#define MEM_BASE (0x40000000)

#define DAQ_ENA_Pos (0U)
#define DAQ_ENA_Msk (0x01U << DAQ_ENA_Pos)

#define DAQ_DONE_Pos (0U)
#define DAQ_DONE_Msk (0x01U << DAQ_DONE_Pos)

/*------------------------------------------------------------------------------
-- Externs
------------------------------------------------------------------------------*/

extern int daq_init(volatile uint32_t **daq_ctrl, volatile  uint32_t **daq_stat, volatile uint16_t **daq_memory);
extern void read_daq(volatile uint16_t *memory);
extern void daq_start(volatile uint32_t *control_reg);

#endif //DAQ_H
