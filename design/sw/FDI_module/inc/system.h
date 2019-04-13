/*------------------------------------------------------------------------------
 -- system.h

 -- TODO LICENCE

 -- creator: dodotronix | BUT | 2019

 -- description:
 -----------------------------------------------------------------------------*/

#ifndef SYSTEM_H
#define SYSTEM_H


/*------------------------------------------------------------------------------
-- System defines
------------------------------------------------------------------------------*/
#define SET_BIT(REG, BIT)    (*(REG) |=  (BIT))
#define CLEAR_BIT(REG, BIT)  (*(REG) &= ~(BIT))

#define WRITE_REG(REG, VAL)  (*(REG) =   (VAL))
#define READ_BIT(REG, BIT)   (*(REG) &   (BIT))
#define CLEAR_REG(REG)       (*(REG) =   (0x0))
#define READ_REG(REG)        (*(REG)          )
#define IS_BIT_SET(REG, BIT) ((*(REG) &  (BIT)) == 0)

#endif //SYSTEM_H
