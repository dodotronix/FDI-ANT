/*------------------------------------------------------------------------------
 -- main.c

 -- TODO LICENCE

 -- creator: dodotronix | BUT | 2019

 -- description:
 -----------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <math.h>
#include <sys/mman.h>
#include <time.h>

#define BUFFER_SIZE 2*8192

uint32_t buffer[BUFFER_SIZE]; //size of memory

//--
typedef struct siggen {
  uint8_t bitrate;
  uint8_t repeat;
  uint8_t order;
  void *memory;
} sgen_t;

typedef struct daq {
  void *constat;
  void *bram;
} daq_t;

//--
int daq_init(daq_t *instance)
{
  int fd;
  char *name = "/dev/mem";

  if((fd = open(name, O_RDWR)) < 0) {
    perror("open");
    return EXIT_FAILURE;
  }

  instance->constat = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x42000000); 
  instance->bram = mmap(NULL, BUFFER_SIZE*4, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);

  for(int i=0; i<BUFFER_SIZE; ++i){ 
    (*((uint16_t *)(instance->bram + 2*i))) = 0;
  }

  return 0;
}

//--
void read_daq(daq_t *instance)
{
  uint16_t buffer[BUFFER_SIZE];

  // open file
  FILE *f = fopen("data.txt", "w");
  if (f == NULL) {
      printf("Error opening file!\n");
      exit(1);
  }

  for(int i=0; i<BUFFER_SIZE; ++i){ 
    buffer[i] = ((*((uint16_t *)(instance->bram + 2*i))) & 0x3fff);
    fprintf(f, "%u\n", buffer[i]);
  }

  fclose(f);
}

//--
int sg_init(sgen_t *cfg)
{
  int fd;
  char *name = "/dev/mem";

  if((fd = open(name, O_RDWR)) < 0) {
    perror("open");
    return EXIT_FAILURE;
  }

  cfg->memory = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, 
                     MAP_SHARED, fd, 0x41200000);
  return 0;
}

//--
void sg_setup(sgen_t *cfg)
{
  int32_t result;

  result = cfg->bitrate | (cfg->repeat<<8) | (cfg->order<<11);
  *((int32_t *)cfg->memory) = result; 
}

// main
int main(void)
{
  //[bitrate, repeat, order]
  sgen_t sg_cfg = {125, 7, 6};
  daq_t daq_inst;

  //Initialize
  sg_init(&sg_cfg);
  daq_init(&daq_inst);

  //Device setup
  sg_setup(&sg_cfg);


  //activate DAQ
  (*((int32_t *)(daq_inst.constat + 0))) = 0; 
  (*((int32_t *)(daq_inst.constat + 0))) |= 1; 

  printf("%d\n", (*((uint32_t *)(daq_inst.constat + 8))));
  printf("%d\n", (*((uint32_t *)(daq_inst.constat + 0))));

  //enable signal generator
  *(int32_t *)sg_cfg.memory |= (1<<14); 
  usleep(4);
  *(int32_t *)sg_cfg.memory &= ~(1<<14); 

  //wait for daq flag
  while(((*((int32_t *)(daq_inst.constat + 8))) & 1) == 0);

  printf("%d\n", (*((uint32_t *)(daq_inst.constat + 8))));
  printf("%d\n", (*((uint32_t *)(daq_inst.constat + 0))));

  // read memory
  read_daq(&daq_inst);

  //continue by writing zero to control register
  //vytvor si makra na adresy v pameti

  return 0;
}
