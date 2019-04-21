/*------------------------------------------------------------------------------
 -- seqgen.h

 -- TODO LICENCE

 -- creator: dodotronix | BUT | 2019

 -- description:
 -----------------------------------------------------------------------------*/

#ifndef SEQGEN_H
#define SEQGEN_H

/*------------------------------------------------------------------------------
-- Defines
------------------------------------------------------------------------------*/
#define SEQGEN_BASE (0x41200000U)

#define BITRATE_Pos  (0U)
#define BITRATE_Msk  (0xFFU << BITRATE_Pos)

#define REPEATE_Pos  (8U)
#define REPEATE_Msk  (0x03U << REPEATE_Pos)

#define ORDER_Pos    (11U)
#define ORDER_Msk    (0x03U << ORDER_Pos)

#define SEQENA_Pos   (14U)
#define SEQENA_Msk   (0x01U << SEQENA_Pos)

#define SEQRST_Pos   (15U)
#define SEQRST_Msk   (0x01U << SEQRST_Pos)


/*------------------------------------------------------------------------------
-- Externs
------------------------------------------------------------------------------*/
extern int sg_init(uint32_t **control_reg);
extern void sg_setup(uint32_t *control_reg, uint8_t bitrate, uint8_t repeat, uint8_t order);
extern void sg_start(uint32_t *control_reg);
extern void sg_reset(uint32_t *control_reg);

#endif //SEQGEN_H
